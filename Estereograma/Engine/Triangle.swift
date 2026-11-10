import Foundation

enum Vert: String, CaseIterable {
    case a, b, c
}

typealias Triple = (Vert, Vert, Vert)

enum D3El: String, CaseIterable, Identifiable {
    case E, R, R2 = "R²", m1, m2, m3
    var id: String { rawValue }
    var isProper: Bool {
        switch self {
        case .E, .R, .R2: return true
        case .m1, .m2, .m3: return false
        }
    }
}

/// Positions: top, right, left.
/// Initial (a, b, c): a = ápice, b = derecha, c = izquierda.
/// Rotación 3¹ = 120° horario (pizarra clase 1).
/// Espejos según el tablero de Garratt (no las notas 03):
///   m1 por A (vertical), m2 por B (derecha), m3 por C (izquierda).
/// Ejemplo de la clase: 3¹ luego m2 ≡ m3; m2 luego 3¹ ≡ m1.
enum TriangleLab {
    static let initial: Triple = (.a, .b, .c)

    static let perm: [D3El: Triple] = [
        .E: (.a, .b, .c),
        .R: (.c, .a, .b),
        .R2: (.b, .c, .a),
        .m1: (.a, .c, .b), // por A: b ↔ c
        .m2: (.c, .b, .a), // por B: a ↔ c (B fijo a la derecha)
        .m3: (.b, .a, .c), // por C: a ↔ b (C fijo a la izquierda)
    ]

    static func apply(_ state: Triple, _ el: D3El) -> Triple {
        let p = perm[el]!
        let startPos: [Vert: Int] = [.a: 0, .b: 1, .c: 2]
        var dest = [0, 1, 2]
        dest[indexOf(p, .a)] = startPos[.a]!
        dest[indexOf(p, .b)] = startPos[.b]!
        dest[indexOf(p, .c)] = startPos[.c]!
        let s = [state.0, state.1, state.2]
        return (s[dest[0]], s[dest[1]], s[dest[2]])
    }

    static func compose(first: D3El, second: D3El) -> D3El {
        let s = apply(apply(initial, first), second)
        return D3El.allCases.first { eq(perm[$0]!, s) }!
    }

    static let table: [[D3El]] = D3El.allCases.map { row in
        D3El.allCases.map { col in compose(first: row, second: col) }
    }

    static let c3: [D3El] = [.E, .R, .R2]

    private static func indexOf(_ t: Triple, _ v: Vert) -> Int {
        if t.0 == v { return 0 }
        if t.1 == v { return 1 }
        return 2
    }

    private static func eq(_ a: Triple, _ b: Triple) -> Bool {
        a.0 == b.0 && a.1 == b.1 && a.2 == b.2
    }
}
