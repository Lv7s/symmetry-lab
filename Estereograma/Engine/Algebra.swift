import Foundation

struct Lin: Equatable {
    var x: Double
    var y: Double
    var z: Double

    static let i = Lin(x: 1, y: 0, z: 0)
    static let j = Lin(x: 0, y: 1, z: 0)
    static let k = Lin(x: 0, y: 0, z: 1)

    subscript(_ v: AxisLetter) -> Double {
        get {
            switch v {
            case .x: return x
            case .y: return y
            case .z: return z
            }
        }
        set {
            switch v {
            case .x: x = newValue
            case .y: y = newValue
            case .z: z = newValue
            }
        }
    }
}

enum AxisLetter: String, CaseIterable {
    case x, y, z
}

struct PointSym: Equatable {
    var x: Lin
    var y: Lin
    var z: Lin

    static let identity = PointSym(x: .i, y: .j, z: .k)
}

struct Vec3: Equatable {
    var x: Double
    var y: Double
    var z: Double

    static let zero = Vec3(x: 0, y: 0, z: 0)

    static func + (a: Vec3, b: Vec3) -> Vec3 { Vec3(x: a.x + b.x, y: a.y + b.y, z: a.z + b.z) }
    static func * (a: Vec3, s: Double) -> Vec3 { Vec3(x: a.x * s, y: a.y * s, z: a.z * s) }
}

enum CrystalSystem: String, CaseIterable, Identifiable {
    case triclinico, monoclinico, ortorrombico, trigonal, tetragonal, hexagonal, cubico
    var id: String { rawValue }

    var label: String {
        switch self {
        case .triclinico: return "Triclínico"
        case .monoclinico: return "Monoclínico"
        case .ortorrombico: return "Ortorrómbico"
        case .trigonal: return "Trigonal"
        case .tetragonal: return "Tetragonal"
        case .hexagonal: return "Hexagonal"
        case .cubico: return "Cúbico"
        }
    }

    var isHexFamily: Bool { self == .trigonal || self == .hexagonal }
}

enum ViewAxis: String {
    case z, y
}

let EPS_SYM = 1e-9

func parseExpr(_ expr: String) -> Lin {
    let t = expr.replacingOccurrences(of: " ", with: "")
    var out = Lin(x: 0, y: 0, z: 0)
    var i = t.startIndex
    while i < t.endIndex {
        var sign = 1.0
        if t[i] == "+" {
            i = t.index(after: i)
        } else if t[i] == "-" {
            sign = -1
            i = t.index(after: i)
        }
        guard i < t.endIndex else { break }
        let v = t[i]
        switch v {
        case "x": out.x += sign
        case "y": out.y += sign
        case "z": out.z += sign
        default: break
        }
        i = t.index(after: i)
    }
    return out
}

func parseXyz(_ xyz: String) -> PointSym {
    let parts = xyz.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    precondition(parts.count == 3, "XYZ inválido: \(xyz)")
    return PointSym(x: parseExpr(parts[0]), y: parseExpr(parts[1]), z: parseExpr(parts[2]))
}

func linEq(_ a: Lin, _ b: Lin, eps: Double = EPS_SYM) -> Bool {
    abs(a.x - b.x) < eps && abs(a.y - b.y) < eps && abs(a.z - b.z) < eps
}

func compose(_ a: PointSym, _ b: PointSym) -> PointSym {
    /// Apply b first, then a: a ∘ b
    func mapRow(_ row: Lin) -> Lin {
        Lin(
            x: row.x * b.x.x + row.y * b.y.x + row.z * b.z.x,
            y: row.x * b.x.y + row.y * b.y.y + row.z * b.z.y,
            z: row.x * b.x.z + row.y * b.y.z + row.z * b.z.z
        )
    }
    return PointSym(x: mapRow(a.x), y: mapRow(a.y), z: mapRow(a.z))
}

func applySym(_ op: PointSym, _ p: Vec3) -> Vec3 {
    Vec3(
        x: op.x.x * p.x + op.x.y * p.y + op.x.z * p.z,
        y: op.y.x * p.x + op.y.y * p.y + op.y.z * p.z,
        z: op.z.x * p.x + op.z.y * p.y + op.z.z * p.z
    )
}

func mat3(_ op: PointSym) -> [[Double]] {
    [
        [op.x.x, op.x.y, op.x.z],
        [op.y.x, op.y.y, op.y.z],
        [op.z.x, op.z.y, op.z.z],
    ]
}

func det3(_ m: [[Double]]) -> Double {
    let a = m[0], b = m[1], c = m[2]
    return a[0] * (b[1] * c[2] - b[2] * c[1])
        - a[1] * (b[0] * c[2] - b[2] * c[0])
        + a[2] * (b[0] * c[1] - b[1] * c[0])
}

func trace3(_ m: [[Double]]) -> Double {
    m[0][0] + m[1][1] + m[2][2]
}

func detOf(_ op: PointSym) -> Double { det3(mat3(op)) }

func invert3(_ m: [[Double]]) -> [[Double]] {
    let d = det3(m)
    let a = m[0], b = m[1], c = m[2]
    let A00 = b[1] * c[2] - b[2] * c[1]
    let A01 = b[2] * c[0] - b[0] * c[2]
    let A02 = b[0] * c[1] - b[1] * c[0]
    let A10 = a[2] * c[1] - a[1] * c[2]
    let A11 = a[0] * c[2] - a[2] * c[0]
    let A12 = a[1] * c[0] - a[0] * c[1]
    let A20 = a[1] * b[2] - a[2] * b[1]
    let A21 = a[2] * b[0] - a[0] * b[2]
    let A22 = a[0] * b[1] - a[1] * b[0]
    return [
        [A00 / d, A10 / d, A20 / d],
        [A01 / d, A11 / d, A21 / d],
        [A02 / d, A12 / d, A22 / d],
    ]
}

func inverseSym(_ op: PointSym) -> PointSym {
    let inv = invert3(mat3(op))
    return PointSym(
        x: Lin(x: inv[0][0], y: inv[0][1], z: inv[0][2]),
        y: Lin(x: inv[1][0], y: inv[1][1], z: inv[1][2]),
        z: Lin(x: inv[2][0], y: inv[2][1], z: inv[2][2])
    )
}

func isIdentity(_ op: PointSym) -> Bool { op == .identity }

func formatExpr(_ l: Lin) -> String {
    var bits: [String] = []
    for v in AxisLetter.allCases {
        let c = l[v]
        if abs(c) < EPS_SYM { continue }
        let mag = abs(c) == 1 ? v.rawValue : "\(abs(c) == 0.5 ? "½" : String(abs(c)))\(v.rawValue)"
        if c > 0 {
            bits.append(bits.isEmpty ? mag : "+\(mag)")
        } else {
            bits.append("-\(mag)")
        }
    }
    return bits.isEmpty ? "0" : bits.joined()
}

func formatXyz(_ op: PointSym) -> String {
    "\(formatExpr(op.x)),\(formatExpr(op.y)),\(formatExpr(op.z))"
}

func closeGroup(_ generators: [PointSym]) -> [PointSym] {
    var ops: [PointSym] = [.identity]
    var seen: Set<String> = [formatXyz(.identity)]
    let gens = generators.filter { !isIdentity($0) }
    var queue = ops
    while !queue.isEmpty {
        let a = queue.removeFirst()
        for g in gens {
            for prod in [compose(g, a), compose(a, g)] {
                let key = formatXyz(prod)
                if seen.contains(key) { continue }
                seen.insert(key)
                ops.append(prod)
                queue.append(prod)
            }
        }
    }
    return ops
}

func crystalToCart(_ p: Vec3, _ system: CrystalSystem) -> Vec3 {
    guard system.isHexFamily else { return p }
    return Vec3(x: p.x - p.y / 2, y: p.y * (sqrt(3) / 2), z: p.z)
}

func cartToCrystal(_ p: Vec3, _ system: CrystalSystem) -> Vec3 {
    guard system.isHexFamily else { return p }
    let y = p.y / (sqrt(3) / 2)
    return Vec3(x: p.x + y / 2, y: y, z: p.z)
}

func applyOpCart(_ op: PointSym, _ pCart: Vec3, _ system: CrystalSystem) -> Vec3 {
    crystalToCart(applySym(op, cartToCrystal(pCart, system)), system)
}

/// Normales covariantes: n_cart = C^{-T} n_crystal.
func normalToCart(_ n: Vec3, _ system: CrystalSystem) -> Vec3 {
    guard system.isHexFamily else { return normalize(n) }
    return normalize(Vec3(
        x: n.x,
        y: n.x / sqrt(3) + (n.y * 2) / sqrt(3),
        z: n.z
    ))
}

func dot(_ a: Vec3, _ b: Vec3) -> Double { a.x * b.x + a.y * b.y + a.z * b.z }

func cross(_ a: Vec3, _ b: Vec3) -> Vec3 {
    Vec3(
        x: a.y * b.z - a.z * b.y,
        y: a.z * b.x - a.x * b.z,
        z: a.x * b.y - a.y * b.x
    )
}

func norm(_ a: Vec3) -> Double { hypot(a.x, hypot(a.y, a.z)) }

func normalize(_ a: Vec3) -> Vec3 {
    let n = norm(a)
    if n < EPS_SYM { return .zero }
    return a * (1 / n)
}

func lerp(_ a: Vec3, _ b: Vec3, _ t: Double) -> Vec3 {
    Vec3(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t, z: a.z + (b.z - a.z) * t)
}

func rotZCart(_ p: Vec3, _ rad: Double) -> Vec3 {
    let c = cos(rad), s = sin(rad)
    return Vec3(x: c * p.x - s * p.y, y: s * p.x + c * p.y, z: p.z)
}

func invertThrough(_ p: Vec3) -> Vec3 { Vec3(x: -p.x, y: -p.y, z: -p.z) }
