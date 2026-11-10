import Foundation

struct Copy3d: Identifiable {
    var id: String { op.xyz }
    var op: Operation
    var center: Vec3
    var upper: Bool
}

struct Axis3d {
    var dir: Vec3
    var order: Int
    var bar: Bool
}

struct CrystalAxis {
    var dir: Vec3
    var label: String
    var cartesian: Bool
}

struct Plane3d {
    var normal: Vec3
}

struct Scene3d {
    var copies: [Copy3d]
    var axes: [Axis3d]
    var planes: [Plane3d]
    var crystalAxes: [CrystalAxis]
    var inversion: Bool
    var view: ViewAxis
    var sphereR: Double
}

func planeBasis(_ n: Vec3) -> (u: Vec3, v: Vec3) {
    let helper = abs(n.y) < 0.9 ? Vec3(x: 0, y: 1, z: 0) : Vec3(x: 1, y: 0, z: 0)
    let u = normalize(cross(helper, n))
    let v = normalize(cross(n, u))
    return (u, v)
}

func greatCircle(_ n: Vec3, radius: Double, steps: Int = 72) -> [Vec3] {
    let b = planeBasis(n)
    return (0...steps).map { i in
        let a = Double(i) / Double(steps) * .pi * 2
        return Vec3(
            x: b.u.x * cos(a) * radius + b.v.x * sin(a) * radius,
            y: b.u.y * cos(a) * radius + b.v.y * sin(a) * radius,
            z: b.u.z * cos(a) * radius + b.v.z * sin(a) * radius
        )
    }
}

func crystalAxesOf(_ system: CrystalSystem) -> [CrystalAxis] {
    let hex = system.isHexFamily
    var out: [CrystalAxis] = [
        CrystalAxis(dir: Vec3(x: 1, y: 0, z: 0), label: hex ? "x · a1" : "x", cartesian: true),
        CrystalAxis(dir: Vec3(x: 0, y: 1, z: 0), label: "y", cartesian: true),
        CrystalAxis(dir: Vec3(x: 0, y: 0, z: 1), label: hex ? "z · c" : "z", cartesian: true),
    ]
    if hex {
        out.append(CrystalAxis(dir: normalize(crystalToCart(Vec3(x: 0, y: 1, z: 0), system)), label: "a2", cartesian: false))
        out.append(CrystalAxis(dir: normalize(crystalToCart(Vec3(x: -1, y: -1, z: 0), system)), label: "a3", cartesian: false))
    }
    return out
}

let SPHERE_R = 1.22

func buildScene3d(_ group: PointGroup, seed: Vec3) -> Scene3d {
    let seedCart = crystalToCart(seed, group.system)
    let mag = hypot(seedCart.x, hypot(seedCart.y, seedCart.z))
    let placed = mag < 1e-9 ? Vec3(x: 0, y: 0, z: SPHERE_R) : seedCart * (SPHERE_R / mag)

    let copies: [Copy3d] = group.ops.map { op in
        let center = applyOpCart(op.sym, placed, group.system)
        let height = group.view == .y ? center.y : center.z
        return Copy3d(op: op, center: center, upper: height >= 0)
    }

    var axes: [Axis3d] = []
    for op in group.ops {
        guard (op.kind == .rotation || op.kind == .rotoinversion), let axis = op.axis, op.order >= 2 else { continue }
        let dir = normalize(crystalToCart(axis, group.system))
        let bar = op.kind == .rotoinversion
        if let i = axes.firstIndex(where: { abs(dot($0.dir, dir)) > 0.97 }) {
            if op.order > axes[i].order || (op.order == axes[i].order && bar && !axes[i].bar) {
                axes[i].order = op.order
                axes[i].bar = bar
                axes[i].dir = dir
            }
        } else {
            axes.append(Axis3d(dir: dir, order: op.order, bar: bar))
        }
    }

    var planes: [Plane3d] = []
    for op in group.ops {
        guard op.kind == .reflection, let n0 = reflectionNormal(op) else { continue }
        let n = normalToCart(n0, group.system)
        if !planes.contains(where: { abs(dot($0.normal, n)) > 0.97 }) {
            planes.append(Plane3d(normal: n))
        }
    }

    return Scene3d(
        copies: copies,
        axes: axes,
        planes: planes,
        crystalAxes: crystalAxesOf(group.system),
        inversion: group.centrosymmetric,
        view: group.view,
        sphereR: SPHERE_R
    )
}

func rotateY(_ p: Vec3, _ a: Double) -> Vec3 {
    let c = cos(a), s = sin(a)
    return Vec3(x: c * p.x + s * p.z, y: p.y, z: -s * p.x + c * p.z)
}

func rotateX(_ p: Vec3, _ a: Double) -> Vec3 {
    let c = cos(a), s = sin(a)
    return Vec3(x: p.x, y: c * p.y - s * p.z, z: s * p.y + c * p.z)
}
