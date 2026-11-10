import Foundation

enum OpKind: String {
    case identity, rotation, reflection, inversion, rotoinversion
}

struct Operation: Identifiable, Equatable {
    var id: String { xyz }
    var xyz: String
    var sym: PointSym
    var det: Int
    var proper: Bool
    var kind: OpKind
    var order: Int
    var angle: Double
    var label: String
    var axis: Vec3?
}

struct PointGroup: Identifiable, Equatable {
    var id: String
    var hm: String
    var schoenflies: String
    var system: CrystalSystem
    var view: ViewAxis
    var chiral: Bool
    var polar: Bool
    var centrosymmetric: Bool
    var hasImproper: Bool
    var order: Int
    var ops: [Operation]
    var generators: [String]
    var notes: [String]
    var equivalent: String?

    var systemLabel: String { system.label }
}

private struct Def {
    var id: String
    var hm: String
    var sch: String
    var system: CrystalSystem
    var gens: [String]
    var view: ViewAxis
    var polar: Bool
    var equivalent: String? = nil
    var notes: [String] = []
}

/// Generators in crystal coordinates (hexagonal axes for trigonal/hexagonal).
/// Unique monoclinic axis is y, as in the course (ITA unique-b).
private let DEFS: [Def] = [
    Def(id: "1", hm: "1", sch: "C₁", system: .triclinico, gens: [], view: .z, polar: true, notes: [
        "Solo la identidad. Un punto general (GEP xyz) y nada más.",
        "Grupo quiral y polar: una proteína puede cristalizar en P1.",
    ]),
    Def(id: "-1", hm: "1̄", sch: "Cᵢ", system: .triclinico, gens: ["-x,-y,-z"], view: .z, polar: false, notes: [
        "Centro de inversión: si hay algo en (x,y,z) hay otro en (x̄,ȳ,z̄).",
        "La coma marca la mano opuesta. Operación impropia.",
    ]),
    Def(id: "2", hm: "2", sch: "C₂", system: .monoclinico, gens: ["-x,y,-z"], view: .z, polar: true, notes: [
        "Pizarra clase 3: el 2 va en y, dibujado como diámetro vertical. X a la derecha. xyz → x̄ y z̄ (sigue la misma mano).",
        "Unique-b: el eje único es y. En 2/m se mira a lo largo de ese eje (rombo al centro).",
    ]),
    Def(id: "m", hm: "m", sch: "Cₛ", system: .monoclinico, gens: ["x,-y,z"], view: .y, polar: true, notes: [
        "Un solo espejo, perpendicular al eje único y.",
        "Polar: la dirección del espejo no se invierte.",
    ]),
    Def(id: "2/m", hm: "2/m", sch: "C₂ₕ", system: .monoclinico, gens: ["-x,y,-z", "x,-y,z"], view: .y, polar: false, notes: [
        "Eje 2 en y (rombo al centro) y espejo ⊥ en el plano del papel: círculo más grueso.",
        "El espejo apila + y − en el mismo sitio: óvalo partido, coma en el − (mano opuesta). 2 × m = 1̄.",
    ]),
    Def(id: "222", hm: "222", sch: "D₂", system: .ortorrombico, gens: ["-x,-y,z", "-x,y,-z"], view: .z, polar: false, notes: [
        "Tres ejes 2 mutuamente perpendiculares. Quiral: sin espejos.",
    ]),
    Def(id: "mm2", hm: "mm2", sch: "C₂ᵥ", system: .ortorrombico, gens: ["-x,y,z", "x,-y,z"], view: .z, polar: true, notes: [
        "m ⊥ x (plano yz) y m ⊥ y (plano xz) generan el 2 a lo largo de z.",
        "Grupo polar: las cuatro GEP quedan del mismo lado de z (todas +).",
    ]),
    Def(id: "mmm", hm: "mmm", sch: "D₂ₕ", system: .ortorrombico, gens: ["-x,y,z", "x,-y,z", "x,y,-z"], view: .z, polar: false, notes: []),
    Def(id: "4", hm: "4", sch: "C₄", system: .tetragonal, gens: ["-y,x,z"], view: .z, polar: true, notes: []),
    Def(id: "-4", hm: "4̄", sch: "S₄", system: .tetragonal, gens: ["y,-x,-z"], view: .z, polar: false, notes: [
        "4̄¹ = rotación 90° y después inversión por un punto.",
        "No hay 4 propio ni centro de inversión.",
    ]),
    Def(id: "4/m", hm: "4/m", sch: "C₄ₕ", system: .tetragonal, gens: ["-y,x,z", "x,y,-z"], view: .z, polar: false, notes: []),
    Def(id: "422", hm: "422", sch: "D₄", system: .tetragonal, gens: ["-y,x,z", "-x,y,-z"], view: .z, polar: false, notes: []),
    Def(id: "4mm", hm: "4mm", sch: "C₄ᵥ", system: .tetragonal, gens: ["-y,x,z", "-x,y,z"], view: .z, polar: true, notes: [
        "n par → dos familias de espejos: de ahí el doble m (4mm).",
    ]),
    Def(id: "-42m", hm: "4̄2m", sch: "D₂d", system: .tetragonal, gens: ["y,-x,-z", "-x,y,-z"], view: .z, polar: false, notes: []),
    Def(id: "4/mmm", hm: "4/mmm", sch: "D₄ₕ", system: .tetragonal, gens: ["-y,x,z", "-x,y,z", "x,y,-z"], view: .z, polar: false, notes: []),
    Def(id: "3", hm: "3", sch: "C₃", system: .trigonal, gens: ["-y,x-y,z"], view: .z, polar: true, notes: []),
    Def(id: "-3", hm: "3̄", sch: "C₃ᵢ", system: .trigonal, gens: ["y,-x+y,-z"], view: .z, polar: false, notes: [
        "3̄ ≡ 3 + centro de inversión. 3̄³ = 1̄.",
    ]),
    Def(id: "32", hm: "32", sch: "D₃", system: .trigonal, gens: ["-y,x-y,z", "x-y,-y,-z"], view: .z, polar: false, notes: [
        "Pariente 3D del D3 del triángulo: rotaciones 3 y tres ejes 2 perpendiculares.",
    ]),
    Def(id: "3m", hm: "3m", sch: "C₃ᵥ", system: .trigonal, gens: ["-y,x-y,z", "x-y,-y,z"], view: .z, polar: true, notes: [
        "n impar → una sola familia de espejos: 3m, no 3mm.",
    ]),
    Def(id: "-3m", hm: "3̄m", sch: "D₃d", system: .trigonal, gens: ["y,-x+y,-z", "x-y,-y,z"], view: .z, polar: false, notes: []),
    Def(id: "6", hm: "6", sch: "C₆", system: .hexagonal, gens: ["x-y,x,z"], view: .z, polar: true, notes: []),
    Def(id: "-6", hm: "6̄", sch: "C₃ₕ", system: .hexagonal, gens: ["-x+y,-x,-z"], view: .z, polar: false, equivalent: "3/m", notes: [
        "6̄ = rotación de 60° alrededor del eje y DESPUÉS inversión por un punto sobre el eje.",
        "6̄¹ cambia de piso (z → −z) y de mano.",
        "6̄² = rotación 120° (eje 3).",
        "6̄³ = espejo perpendicular al eje.",
        "6̄⁶ = identidad.",
        "6̄ ≡ 3/m. No hay 3/m en la tabla: es hexagonal.",
    ]),
    Def(id: "6/m", hm: "6/m", sch: "C₆ₕ", system: .hexagonal, gens: ["x-y,x,z", "x,y,-z"], view: .z, polar: false, notes: []),
    Def(id: "622", hm: "622", sch: "D₆", system: .hexagonal, gens: ["x-y,x,z", "x-y,-y,-z"], view: .z, polar: false, notes: []),
    Def(id: "6mm", hm: "6mm", sch: "C₆ᵥ", system: .hexagonal, gens: ["x-y,x,z", "x-y,-y,z"], view: .z, polar: true, notes: [
        "n par → dos familias de espejos (6mm).",
    ]),
    Def(id: "-62m", hm: "6̄2m", sch: "D₃ₕ", system: .hexagonal, gens: ["-x+y,-x,-z", "x-y,-y,-z"], view: .z, polar: false, notes: [
        "6̄ más ejes 2 en el plano. La caja del Toblerone es 6̄m2.",
    ]),
    Def(id: "6/mmm", hm: "6/mmm", sch: "D₆ₕ", system: .hexagonal, gens: ["x-y,x,z", "x-y,-y,-z", "x,y,-z"], view: .z, polar: false, notes: []),
    Def(id: "23", hm: "23", sch: "T", system: .cubico, gens: ["-x,-y,z", "z,x,y"], view: .z, polar: false, notes: []),
    Def(id: "m-3", hm: "m3̄", sch: "Tₕ", system: .cubico, gens: ["-x,-y,z", "z,x,y", "-x,-y,-z"], view: .z, polar: false, notes: []),
    Def(id: "432", hm: "432", sch: "O", system: .cubico, gens: ["-y,x,z", "z,x,y"], view: .z, polar: false, notes: []),
    Def(id: "-43m", hm: "4̄3m", sch: "T_d", system: .cubico, gens: ["y,-x,-z", "z,x,y"], view: .z, polar: false, notes: []),
    Def(id: "m-3m", hm: "m3̄m", sch: "Oₕ", system: .cubico, gens: ["-y,x,z", "z,x,y", "-x,-y,-z"], view: .z, polar: false, notes: []),
]

private func rotationAngle(_ sym: PointSym, det: Double) -> (angle: Double, order: Int) {
    let t = trace3(mat3(sym))
    let tR = det > 0 ? t : -t
    let c = (tR - 1) / 2
    if abs(c - 1) < 1e-6 { return (det > 0 ? 0 : 180, det > 0 ? 1 : 2) }
    if abs(c + 1) < 1e-6 { return (180, 2) }
    if abs(c - 0.5) < 1e-6 { return (60, 6) }
    if abs(c) < 1e-6 { return (90, 4) }
    if abs(c + 0.5) < 1e-6 { return (120, 3) }
    let th = (acos(max(-1, min(1, c))) * 180) / .pi
    return (th, max(1, Int((360 / th).rounded())))
}

private func axisOfRotation(_ sym: PointSym) -> Vec3? {
    let m = mat3(sym)
    let det = detOf(sym)
    let A: [[Double]] = det > 0 ? m : m.map { $0.map { -$0 } }
    let r0 = Vec3(x: A[0][0] - 1, y: A[0][1], z: A[0][2])
    let r1 = Vec3(x: A[1][0], y: A[1][1] - 1, z: A[1][2])
    let r2 = Vec3(x: A[2][0], y: A[2][1], z: A[2][2] - 1)
    let candidates = [cross(r0, r1), cross(r1, r2), cross(r2, r0)]
    var best = candidates[0]
    var bestN = 0.0
    for c in candidates {
        let n = norm(c)
        if n > bestN {
            bestN = n
            best = c
        }
    }
    if bestN < 1e-8 { return nil }
    var ax = best * (1 / bestN)
    if ax.z < -1e-8 || (abs(ax.z) < 1e-8 && ax.y < -1e-8) || (abs(ax.z) < 1e-8 && abs(ax.y) < 1e-8 && ax.x < 0) {
        ax = Vec3(x: -ax.x, y: -ax.y, z: -ax.z)
    }
    return ax
}

private func classify(_ sym: PointSym) -> (det: Int, proper: Bool, kind: OpKind, order: Int, angle: Double, axis: Vec3?) {
    let detRaw = detOf(sym)
    let det = detRaw < 0 ? -1 : 1
    let proper = det > 0
    if isIdentity(sym) {
        return (det, proper, .identity, 1, 0, nil)
    }
    let m = mat3(sym)
    let tr = trace3(m)
    if abs(tr + 3) < 1e-6 && det < 0 {
        return (det, proper, .inversion, 2, 180, nil)
    }
    if det < 0 && abs(tr - 1) < 1e-6 {
        return (det, proper, .reflection, 2, 180, axisOfRotation(sym))
    }
    let ra = rotationAngle(sym, det: Double(det))
    return (det, proper, proper ? .rotation : .rotoinversion, ra.order, ra.angle, axisOfRotation(sym))
}

private func toSup(_ n: Int) -> String {
    let map: [Character: Character] = ["0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴", "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹"]
    return String(String(n).map { map[$0] ?? $0 })
}

private func toSub(_ n: Int) -> String {
    let map: [Character] = Array("₀₁₂₃₄₅₆₇₈₉")
    return String(String(n).compactMap { ch -> Character? in
        guard let d = ch.wholeNumberValue else { return ch }
        return map[d]
    })
}

private func powLabel(kind: OpKind, order: Int, angle: Double) -> String {
    if kind == .identity { return "E" }
    if kind == .inversion { return "1̄" }
    if kind == .reflection { return "m" }
    let bar = kind == .rotoinversion
    let base = bar ? "\(order)\u{0304}" : "\(order)"
    let k = Int((angle / (360 / Double(order))).rounded())
    if order == 2 || k <= 1 { return base }
    return "\(base)\(toSup(k))"
}

private func disambiguate(_ labels: inout [Operation]) {
    var counts: [String: Int] = [:]
    for op in labels { counts[op.label, default: 0] += 1 }
    var seen: [String: Int] = [:]
    for i in labels.indices {
        if (counts[labels[i].label] ?? 0) <= 1 { continue }
        let n = (seen[labels[i].label] ?? 0) + 1
        seen[labels[i].label] = n
        if labels[i].kind == .reflection {
            labels[i].label = "m\(toSub(n))"
        } else if labels[i].kind == .rotation && labels[i].order == 2 {
            labels[i].label = "2\(toSub(n))"
        } else {
            labels[i].label = "\(labels[i].label)\(toSub(n))"
        }
    }
}

private func relabelCyclic(_ ops: inout [Operation]) {
    if let bar6 = ops.first(where: { $0.kind == .rotoinversion && $0.order == 6 && abs($0.angle - 60) < 1 }) {
        var cur = bar6.sym
        if let i = ops.firstIndex(where: { $0.xyz == bar6.xyz }) { ops[i].label = "6̄¹" }
        for k in 2...6 {
            cur = compose(bar6.sym, cur)
            let key = formatXyz(cur)
            guard let i = ops.firstIndex(where: { formatXyz($0.sym) == key }) else { break }
            ops[i].label = k == 6 ? "E" : "6̄\(toSup(k))"
        }
        return
    }
    if let r4 = ops.first(where: { $0.kind == .rotation && $0.order == 4 && abs($0.angle - 90) < 1 }) {
        var cur = r4.sym
        if let i = ops.firstIndex(where: { $0.xyz == r4.xyz }) { ops[i].label = "4¹" }
        for k in 2...4 {
            cur = compose(r4.sym, cur)
            let key = formatXyz(cur)
            guard let i = ops.firstIndex(where: { formatXyz($0.sym) == key }) else { break }
            if k == 4 { ops[i].label = "E" }
            else if k == 2 { ops[i].label = "2" }
            else { ops[i].label = "4\(toSup(k))" }
        }
    }
    if let r3 = ops.first(where: { $0.kind == .rotation && $0.order == 3 && abs($0.angle - 120) < 1 }),
       !ops.contains(where: { $0.label.hasPrefix("6̄") }) {
        var cur = r3.sym
        if let i = ops.firstIndex(where: { $0.xyz == r3.xyz }) { ops[i].label = "3¹" }
        for k in 2...3 {
            cur = compose(r3.sym, cur)
            let key = formatXyz(cur)
            guard let i = ops.firstIndex(where: { formatXyz($0.sym) == key }) else { break }
            ops[i].label = k == 3 ? "E" : "3\(toSup(k))"
        }
    }
}

private func buildOps(_ syms: [PointSym]) -> [Operation] {
    var ops: [Operation] = syms.map { sym in
        let xyz = formatXyz(sym)
        let c = classify(sym)
        return Operation(
            xyz: xyz,
            sym: sym,
            det: c.det,
            proper: c.proper,
            kind: c.kind,
            order: c.order,
            angle: c.angle,
            label: powLabel(kind: c.kind, order: c.order, angle: c.angle),
            axis: c.axis
        )
    }
    relabelCyclic(&ops)
    disambiguate(&ops)
    func rank(_ o: Operation) -> Int {
        switch o.kind {
        case .identity: return 0
        case .rotation: return 1
        case .reflection: return 2
        case .rotoinversion: return 3
        case .inversion: return 4
        }
    }
    ops.sort { a, b in
        let ra = rank(a), rb = rank(b)
        if ra != rb { return ra < rb }
        if a.angle != b.angle { return a.angle < b.angle }
        return a.xyz < b.xyz
    }
    return ops
}

private func buildGroup(_ def: Def) -> PointGroup {
    let gens = def.gens.map(parseXyz)
    let closed = closeGroup(gens)
    let ops = buildOps(closed)
    let hasImproper = ops.contains { !$0.proper }
    let centrosymmetric = ops.contains { $0.kind == .inversion }
    return PointGroup(
        id: def.id,
        hm: def.hm,
        schoenflies: def.sch,
        system: def.system,
        view: def.view,
        chiral: !hasImproper,
        polar: def.polar,
        centrosymmetric: centrosymmetric,
        hasImproper: hasImproper,
        order: ops.count,
        ops: ops,
        generators: def.gens,
        notes: def.notes,
        equivalent: def.equivalent
    )
}

enum PointGroupCatalog {
    static let all: [PointGroup] = DEFS.map(buildGroup)

    static let systems: [CrystalSystem] = CrystalSystem.allCases

    static func byId(_ id: String) -> PointGroup {
        guard let g = all.first(where: { $0.id == id }) else {
            fatalError("Grupo desconocido: \(id)")
        }
        return g
    }

    static let defaultSeed = Vec3(x: 0.31, y: 0.12, z: 0.22)

    static let expectedOrders: [String: Int] = [
        "1": 1, "-1": 2, "2": 2, "m": 2, "2/m": 4,
        "222": 4, "mm2": 4, "mmm": 8,
        "4": 4, "-4": 4, "4/m": 8, "422": 8, "4mm": 8, "-42m": 8, "4/mmm": 16,
        "3": 3, "-3": 6, "32": 6, "3m": 6, "-3m": 12,
        "6": 6, "-6": 6, "6/m": 12, "622": 12, "6mm": 12, "-62m": 12, "6/mmm": 24,
        "23": 12, "m-3": 24, "432": 24, "-43m": 24, "m-3m": 48,
    ]

    /// table[row][col] = col ∘ row (fila primero, columna después).
    static func multiplicationTable(_ g: PointGroup) -> [[String]] {
        g.ops.map { rowOp in
            g.ops.map { colOp in
                let prod = compose(colOp.sym, rowOp.sym)
                return g.ops.first(where: { formatXyz($0.sym) == formatXyz(prod) })?.label ?? "?"
            }
        }
    }

    @discardableResult
    static func verify() -> [String] {
        var errors: [String] = []
        for (id, n) in expectedOrders {
            let g = byId(id)
            if g.ops.count != n {
                errors.append("\(id): orden \(g.ops.count) ≠ \(n)")
            }
        }
        if PlaneGroupCatalog.all.count != 17 {
            errors.append("planos: \(PlaneGroupCatalog.all.count) ≠ 17")
        }
        if BravaisLattice.all.count != 14 {
            errors.append("Bravais: \(BravaisLattice.all.count) ≠ 14")
        }
        if SpaceGroupCatalog.all.count != 230 {
            errors.append("espaciales: \(SpaceGroupCatalog.all.count) ≠ 230")
        }
        return errors
    }
}
