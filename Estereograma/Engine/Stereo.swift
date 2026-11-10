import Foundation

struct StereoPt: Identifiable {
    var id: String { op.xyz }
    var op: Operation
    var crystal: Vec3
    var cart: Vec3
    var sx: Double
    var sy: Double
    var upper: Bool
    var azimuth: Double
}

struct MirrorEl {
    enum Kind { case vertical, horizontal }
    var kind: Kind
    /// Azimuth of the diameter (radians) for vertical mirrors.
    var azimuth: Double
}

struct AxisEl {
    var order: Int
    var bar: Bool
    /// 0 at center (along view). Equatorial axes sit on the primitive circle.
    var radial: Double
    var azimuth: Double
}

struct StereoModel {
    var group: PointGroup
    var points: [StereoPt]
    var mirrors: [MirrorEl]
    var axes: [AxisEl]
    var inversion: Bool
}

struct ViewBasis {
    var e1: Vec3
    var e2: Vec3
    var e3: Vec3
}

func viewBasis(_ view: ViewAxis) -> ViewBasis {
    if view == .y {
        // Unique-b (ITA): +x right, +z down, +y toward the viewer.
        return ViewBasis(
            e1: Vec3(x: 1, y: 0, z: 0),
            e2: Vec3(x: 0, y: 0, z: -1),
            e3: Vec3(x: 0, y: 1, z: 0)
        )
    }
    return ViewBasis(
        e1: Vec3(x: 1, y: 0, z: 0),
        e2: Vec3(x: 0, y: 1, z: 0),
        e3: Vec3(x: 0, y: 0, z: 1)
    )
}

func projectDirection(_ n: Vec3, _ view: ViewAxis) -> (sx: Double, sy: Double, upper: Bool) {
    let b = viewBasis(view)
    let u = dot(n, b.e1)
    let v = dot(n, b.e2)
    let w = dot(n, b.e3)
    if w >= 0 {
        let d = 1 + w
        return (u / d, v / d, true)
    }
    let d = 1 - w
    return (u / d, v / d, false)
}

func inverseProject(sx: Double, sy: Double, upper: Bool, view: ViewAxis) -> Vec3 {
    let r2 = sx * sx + sy * sy
    let den = 1 + r2
    let u = (2 * sx) / den
    let v = (2 * sy) / den
    var w = (1 - r2) / den
    if !upper { w = -w }
    let b = viewBasis(view)
    return Vec3(
        x: b.e1.x * u + b.e2.x * v + b.e3.x * w,
        y: b.e1.y * u + b.e2.y * v + b.e3.y * w,
        z: b.e1.z * u + b.e2.z * v + b.e3.z * w
    )
}

func heightCoord(_ p: Vec3, _ view: ViewAxis) -> Double {
    view == .y ? p.y : p.z
}

func directedClose(_ a: Double, _ b: Double, _ tol: Double) -> Bool {
    abs(atan2(sin(a - b), cos(a - b))) < tol
}

func angleClose(_ a: Double, _ b: Double, _ tol: Double) -> Bool {
    let d = abs(atan2(sin(a - b), cos(a - b)))
    let d2 = abs(atan2(sin(a - b + .pi), cos(a - b + .pi)))
    return min(d, d2) < tol
}

/// Clase 4: 6̄ se dibuja como hexágono con triángulo (no se reduce a 3).
/// 3 y 3̄ en el mismo sitio → 3̄. 4 y 4̄ → 4. 6 y 6̄ → 6.
func pickDrawnAxis(_ axes: [AxisEl]) -> AxisEl {
    var byKey: [String: AxisEl] = [:]
    for a in axes { byKey["\(a.order):\(a.bar ? 1 : 0)"] = a }
    var uniq = Array(byKey.values)
    uniq.sort { a, b in
        if a.order != b.order { return a.order > b.order }
        if a.order == 3 { return (a.bar ? 1 : 0) > (b.bar ? 1 : 0) }
        return (a.bar ? 1 : 0) < (b.bar ? 1 : 0)
    }
    return uniq[0]
}

private func sameSite(_ a: AxisEl, _ b: AxisEl) -> Bool {
    if a.radial < 0.08 && b.radial < 0.08 { return true }
    return abs(a.radial - b.radial) < 0.07 && directedClose(a.azimuth, b.azimuth, 0.12)
}

func coalesceAxes(_ axes: [AxisEl]) -> [AxisEl] {
    var clusters: [[AxisEl]] = []
    for a in axes {
        if let i = clusters.firstIndex(where: { sameSite($0[0], a) }) {
            clusters[i].append(a)
        } else {
            clusters.append([a])
        }
    }
    return clusters.map(pickDrawnAxis)
}

func reflectionNormal(_ op: Operation) -> Vec3? {
    let m = mat3(op.sym)
    let cols: [Vec3] = [
        Vec3(x: 1 - m[0][0], y: -m[1][0], z: -m[2][0]),
        Vec3(x: -m[0][1], y: 1 - m[1][1], z: -m[2][1]),
        Vec3(x: -m[0][2], y: -m[1][2], z: 1 - m[2][2]),
    ]
    var best = cols[0]
    var bestN = 0.0
    for c in cols {
        let n = norm(c)
        if n > bestN {
            bestN = n
            best = c
        }
    }
    if bestN < 1e-8 { return nil }
    return normalize(best)
}

func buildStereo(_ group: PointGroup, seed: Vec3 = PointGroupCatalog.defaultSeed) -> StereoModel {
    let points: [StereoPt] = group.ops.map { op in
        let crystal = Vec3(
            x: op.sym.x.x * seed.x + op.sym.x.y * seed.y + op.sym.x.z * seed.z,
            y: op.sym.y.x * seed.x + op.sym.y.y * seed.y + op.sym.y.z * seed.z,
            z: op.sym.z.x * seed.x + op.sym.z.y * seed.y + op.sym.z.z * seed.z
        )
        let cart = crystalToCart(crystal, group.system)
        let n = normalize(cart)
        let pr = projectDirection(n, group.view)
        return StereoPt(
            op: op,
            crystal: crystal,
            cart: cart,
            sx: pr.sx,
            sy: pr.sy,
            upper: heightCoord(cart, group.view) >= 0,
            azimuth: atan2(pr.sy, pr.sx)
        )
    }

    var mirrors: [MirrorEl] = []
    var rawAxes: [AxisEl] = []
    let e3 = viewBasis(group.view).e3
    let b = viewBasis(group.view)

    for op in group.ops {
        if op.kind == .reflection, let n = reflectionNormal(op) {
            let along = abs(dot(n, e3))
            if along > 0.85 {
                if !mirrors.contains(where: { $0.kind == .horizontal }) {
                    mirrors.append(MirrorEl(kind: .horizontal, azimuth: 0))
                }
            } else if along < 0.25 {
                let nx = dot(n, b.e1)
                let ny = dot(n, b.e2)
                let az = atan2(ny, nx) + .pi / 2
                var wrap = az.truncatingRemainder(dividingBy: .pi)
                if wrap < 0 { wrap += .pi }
                if !mirrors.contains(where: { $0.kind == .vertical && angleClose($0.azimuth, wrap, 0.08) }) {
                    mirrors.append(MirrorEl(kind: .vertical, azimuth: wrap))
                }
            }
        }

        if (op.kind == .rotation || op.kind == .rotoinversion), let axis = op.axis, op.order >= 2 {
            let ax = crystalToCart(axis, group.system)
            let n = normalize(ax)
            let bar = op.kind == .rotoinversion
            for sign in [1.0, -1.0] {
                let dir = Vec3(x: sign * n.x, y: sign * n.y, z: sign * n.z)
                let along = dot(dir, e3)
                if along < -0.12 { continue }
                let pr = projectDirection(dir, group.view)
                let radial = hypot(pr.sx, pr.sy)
                let az = atan2(pr.sy, pr.sx)
                let dup = rawAxes.contains { a in
                    a.order == op.order && a.bar == bar && abs(a.radial - radial) < 0.07
                        && (radial < 0.08 || directedClose(a.azimuth, az, 0.1))
                }
                if !dup {
                    rawAxes.append(AxisEl(order: op.order, bar: bar, radial: radial, azimuth: az))
                }
            }
        }
    }

    return StereoModel(
        group: group,
        points: points,
        mirrors: mirrors,
        axes: coalesceAxes(rawAxes),
        inversion: group.centrosymmetric
    )
}

func clusterPoints(_ points: [StereoPt], tol: Double = 0.045) -> [[StereoPt]] {
    var clusters: [[StereoPt]] = []
    var used = Set<Int>()
    for i in points.indices {
        if used.contains(i) { continue }
        var group = [points[i]]
        used.insert(i)
        for j in (i + 1)..<points.count {
            if used.contains(j) { continue }
            let d = hypot(points[i].sx - points[j].sx, points[i].sy - points[j].sy)
            if d < tol {
                group.append(points[j])
                used.insert(j)
            }
        }
        clusters.append(group)
    }
    return clusters
}

func seedFromStereoClick(sx: Double, sy: Double, upper: Bool, group: PointGroup, current: Vec3) -> Vec3 {
    let dir = inverseProject(sx: sx, sy: sy, upper: upper, view: group.view)
    let mag = hypot(current.x, hypot(current.y, current.z))
    let useMag = mag > 1e-9 ? mag : 0.4
    let cart = dir * useMag
    if group.system.isHexFamily {
        let y = cart.y / (sqrt(3) / 2)
        return Vec3(x: cart.x + y / 2, y: y, z: cart.z)
    }
    return cart
}

func bar6Sequence(_ seed: Vec3, _ system: CrystalSystem) -> [Vec3] {
    var out: [Vec3] = []
    var p = crystalToCart(seed, system)
    out.append(p)
    for _ in 0..<6 {
        let rotated = rotZCart(p, .pi / 3)
        p = invertThrough(rotated)
        out.append(p)
    }
    return out
}
