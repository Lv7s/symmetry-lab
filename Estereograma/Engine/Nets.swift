import Foundation

enum CellKind {
    case oblique, rect, square, hex
}

struct Op2 {
    var a, b, c, d, tx, ty: Double
    var det: Double { a * d - b * c }
}

struct PlaneGroup: Identifiable {
    var id: String
    var pg: String
    var red: String
    var cell: CellKind
    var ops: [Op2]
    var extra: String
}

struct BravaisLattice: Identifiable {
    var id: String
    var sys: String
    var name: String
    var extra: [[Double]]
}

struct SpaceGroup: Identifiable {
    var n: Int
    var hm: String
    var pgId: String
    var br: String
    var id: Int { n }
}

private func op(_ a: Double, _ b: Double, _ c: Double, _ d: Double, _ tx: Double = 0, _ ty: Double = 0) -> Op2 {
    Op2(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
}

private func withCenter(_ ops: [Op2], _ cents: [[Double]]) -> [Op2] {
    var out: [Op2] = []
    for o in ops {
        for c in cents {
            var n = o
            n.tx += c[0]
            n.ty += c[1]
            out.append(n)
        }
    }
    return out
}

private let P: [[Double]] = [[0, 0]]
private let C: [[Double]] = [[0, 0], [0.5, 0.5]]

enum PlaneGroupCatalog {
    static let all: [PlaneGroup] = [
        PlaneGroup(id: "p1", pg: "1", red: "oblicua p", cell: .oblique, ops: withCenter([op(1, 0, 0, 1)], P), extra: "Solo traslaciones de la red. El puntual es 1."),
        PlaneGroup(id: "p2", pg: "2", red: "oblicua p", cell: .oblique, ops: withCenter([op(1, 0, 0, 1), op(-1, 0, 0, -1)], P), extra: "Ejes 2 en los nodos. Apagar traslaciones deja el puntual 2."),
        PlaneGroup(id: "pm", pg: "m", red: "rectangular p", cell: .rect, ops: withCenter([op(1, 0, 0, 1), op(1, 0, 0, -1)], P), extra: "Espejos paralelos a a. El puntual es m."),
        PlaneGroup(id: "pg", pg: "m", red: "rectangular p", cell: .rect, ops: withCenter([op(1, 0, 0, 1), op(1, 0, 0, -1, 0.5, 0)], P), extra: "Deslizamiento g: espejo + ½a. Sin esa media traslación queda m."),
        PlaneGroup(id: "cm", pg: "m", red: "rectangular c", cell: .rect, ops: withCenter([op(1, 0, 0, 1), op(1, 0, 0, -1)], C), extra: "Red centrada + espejo."),
        PlaneGroup(id: "pmm", pg: "2mm", red: "rectangular p", cell: .rect, ops: withCenter([op(1, 0, 0, 1), op(-1, 0, 0, -1), op(-1, 0, 0, 1), op(1, 0, 0, -1)], P), extra: "2mm puntual sobre red p."),
        PlaneGroup(id: "pmg", pg: "2mm", red: "rectangular p", cell: .rect, ops: withCenter([
            op(1, 0, 0, 1), op(-1, 0, 0, -1), op(-1, 0, 0, 1, 0.5, 0), op(1, 0, 0, -1, 0.5, 0),
        ], P), extra: "2 + deslizamiento. El puntual (sin t) es 2mm."),
        PlaneGroup(id: "pgg", pg: "2mm", red: "rectangular p", cell: .rect, ops: withCenter([
            op(1, 0, 0, 1), op(-1, 0, 0, -1), op(-1, 0, 0, 1, 0.5, 0.5), op(1, 0, 0, -1, 0.5, 0.5),
        ], P), extra: "Dos deslizamientos cruzados. No hay espejo verdadero. Puntual 2mm."),
        PlaneGroup(id: "cmm", pg: "2mm", red: "rectangular c", cell: .rect, ops: withCenter([op(1, 0, 0, 1), op(-1, 0, 0, -1), op(-1, 0, 0, 1), op(1, 0, 0, -1)], C), extra: "2mm + red centrada."),
        PlaneGroup(id: "p4", pg: "4", red: "cuadrada p", cell: .square, ops: withCenter([
            op(1, 0, 0, 1), op(-1, 0, 0, -1), op(0, -1, 1, 0), op(0, 1, -1, 0),
        ], P), extra: "Eje 4 en el origen y en el centro de celda."),
        PlaneGroup(id: "p4mm", pg: "4mm", red: "cuadrada p", cell: .square, ops: withCenter([
            op(1, 0, 0, 1), op(-1, 0, 0, -1), op(0, -1, 1, 0), op(0, 1, -1, 0),
            op(1, 0, 0, -1), op(-1, 0, 0, 1), op(0, 1, 1, 0), op(0, -1, -1, 0),
        ], P), extra: "4mm + red p."),
        PlaneGroup(id: "p4gm", pg: "4mm", red: "cuadrada p", cell: .square, ops: withCenter([
            op(1, 0, 0, 1), op(-1, 0, 0, -1), op(0, -1, 1, 0), op(0, 1, -1, 0),
            op(-1, 0, 0, 1, 0.5, 0.5), op(1, 0, 0, -1, 0.5, 0.5), op(0, 1, 1, 0, 0.5, 0.5), op(0, -1, -1, 0, 0.5, 0.5),
        ], P), extra: "4 + deslizamientos. El puntual es 4mm."),
        PlaneGroup(id: "p3", pg: "3", red: "hexagonal p", cell: .hex, ops: withCenter([
            op(1, 0, 0, 1), op(0, -1, 1, -1), op(-1, 1, -1, 0),
        ], P), extra: "Ejes 3 en 0,0 y en ±(⅓,⅔)."),
        PlaneGroup(id: "p3m1", pg: "3m", red: "hexagonal p", cell: .hex, ops: withCenter([
            op(1, 0, 0, 1), op(0, -1, 1, -1), op(-1, 1, -1, 0),
            op(0, -1, -1, 0), op(-1, 1, 0, 1), op(1, 0, 1, -1),
        ], P), extra: "Espejos que pasan por los ejes 3 (por los nodos). Distinto de p31m."),
        PlaneGroup(id: "p31m", pg: "3m", red: "hexagonal p", cell: .hex, ops: withCenter([
            op(1, 0, 0, 1), op(0, -1, 1, -1), op(-1, 1, -1, 0),
            op(0, 1, 1, 0), op(1, -1, 0, -1), op(-1, 0, -1, 1),
        ], P), extra: "Espejos que no coinciden con a: pasan entre nodos."),
        PlaneGroup(id: "p6", pg: "6", red: "hexagonal p", cell: .hex, ops: withCenter([
            op(1, 0, 0, 1), op(0, -1, 1, -1), op(-1, 1, -1, 0),
            op(-1, 0, 0, -1), op(0, 1, -1, 1), op(1, -1, 1, 0),
        ], P), extra: "Eje 6 en el origen = 3 + 2."),
        PlaneGroup(id: "p6mm", pg: "6mm", red: "hexagonal p", cell: .hex, ops: withCenter([
            op(1, 0, 0, 1), op(0, -1, 1, -1), op(-1, 1, -1, 0),
            op(-1, 0, 0, -1), op(0, 1, -1, 1), op(1, -1, 1, 0),
            op(0, -1, -1, 0), op(-1, 1, 0, 1), op(1, 0, 1, -1),
            op(0, 1, 1, 0), op(1, -1, 0, -1), op(-1, 0, -1, 1),
        ], P), extra: "6mm + red p. Máxima simetría plana."),
    ]

    static func byId(_ id: String) -> PlaneGroup {
        all.first(where: { $0.id == id }) ?? all[7] // pgg
    }
}

func applyOp2(_ o: Op2, _ x: Double, _ y: Double) -> (Double, Double) {
    (o.a * x + o.b * y + o.tx, o.c * x + o.d * y + o.ty)
}

func isPurePoint(_ o: Op2) -> Bool {
    abs(o.tx) < 1e-8 && abs(o.ty) < 1e-8
}

func cellAxes(_ kind: CellKind) -> (ax: (Double, Double), ay: (Double, Double)) {
    switch kind {
    case .square: return ((1, 0), (0, 1))
    case .rect: return ((1.28, 0), (0, 0.82))
    case .hex: return ((1, 0), (-0.5, sqrt(3) / 2))
    case .oblique: return ((1.18, 0.14), (0.22, 0.86))
    }
}

extension BravaisLattice {
    static let all: [BravaisLattice] = [
        BravaisLattice(id: "aP", sys: "triclínico", name: "P primitivas", extra: []),
        BravaisLattice(id: "mP", sys: "monoclínico", name: "P primitivas", extra: []),
        BravaisLattice(id: "mS", sys: "monoclínico", name: "S centrada (C)", extra: [[0.5, 0.5, 0]]),
        BravaisLattice(id: "oP", sys: "ortorrómbico", name: "P primitivas", extra: []),
        BravaisLattice(id: "oS", sys: "ortorrómbico", name: "S centrada", extra: [[0.5, 0.5, 0]]),
        BravaisLattice(id: "oI", sys: "ortorrómbico", name: "I interior", extra: [[0.5, 0.5, 0.5]]),
        BravaisLattice(id: "oF", sys: "ortorrómbico", name: "F caras", extra: [[0.5, 0.5, 0], [0.5, 0, 0.5], [0, 0.5, 0.5]]),
        BravaisLattice(id: "tP", sys: "tetragonal", name: "P primitivas", extra: []),
        BravaisLattice(id: "tI", sys: "tetragonal", name: "I interior", extra: [[0.5, 0.5, 0.5]]),
        BravaisLattice(id: "hP", sys: "hexagonal", name: "P hex / trig", extra: []),
        BravaisLattice(id: "hR", sys: "trigonal", name: "R romboédrica", extra: [[2.0 / 3, 1.0 / 3, 1.0 / 3], [1.0 / 3, 2.0 / 3, 2.0 / 3]]),
        BravaisLattice(id: "cP", sys: "cúbico", name: "P primitivas", extra: []),
        BravaisLattice(id: "cI", sys: "cúbico", name: "I interior", extra: [[0.5, 0.5, 0.5]]),
        BravaisLattice(id: "cF", sys: "cúbico", name: "F caras", extra: [[0.5, 0.5, 0], [0.5, 0, 0.5], [0, 0.5, 0.5]]),
    ]

    static func byId(_ id: String) -> BravaisLattice {
        all.first(where: { $0.id == id }) ?? all[0]
    }
}

struct Basis {
    var a: [Double]
    var b: [Double]
    var c: [Double]
}

func basisFor(_ br: String) -> Basis {
    if br == "cP" || br == "cI" || br == "cF" {
        return Basis(a: [1, 0, 0], b: [0, 1, 0], c: [0, 0, 1])
    }
    if br == "tP" || br == "tI" {
        return Basis(a: [1, 0, 0], b: [0, 1, 0], c: [0, 0, 1.32])
    }
    if br.hasPrefix("o") {
        return Basis(a: [1.18, 0, 0], b: [0, 0.82, 0], c: [0, 0, 1.22])
    }
    if br == "hP" || br == "hR" {
        return Basis(a: [1, 0, 0], b: [-0.5, sqrt(3) / 2, 0], c: [0, 0, 1.28])
    }
    if br.hasPrefix("m") {
        return Basis(a: [1.12, 0, 0], b: [0, 0.88, 0], c: [0.38, 0, 1.12])
    }
    return Basis(a: [1.08, 0.1, 0.06], b: [0.16, 0.84, 0.1], c: [0.08, 0.12, 1.04])
}

func fracToCart(_ f: [Double], _ B: Basis) -> [Double] {
    [
        f[0] * B.a[0] + f[1] * B.b[0] + f[2] * B.c[0],
        f[0] * B.a[1] + f[1] * B.b[1] + f[2] * B.c[1],
        f[0] * B.a[2] + f[1] * B.b[2] + f[2] * B.c[2],
    ]
}

enum SpaceGroupCatalog {
    static let all: [SpaceGroup] = parse()

    static func byN(_ n: Int) -> SpaceGroup {
        all.first(where: { $0.n == n }) ?? all[0]
    }

    static func isogonal(of pgId: String) -> [SpaceGroup] {
        all.filter { $0.pgId == pgId }
    }

    static func describe(_ hm: String) -> String {
        if let n = notes[hm] { return n }
        var bits: [String] = []
        if hm.range(of: "[2-6][₁-₆]", options: .regularExpression) != nil {
            bits.append("Hay tornillo: rotación + traslación a lo largo del eje.")
        }
        let rest = String(hm.dropFirst())
        if rest.range(of: "[abcdne]", options: .regularExpression) != nil {
            bits.append("Hay plano de deslizamiento: espejo + ½ (o ¼) de una traslación.")
        }
        if bits.isEmpty {
            bits.append("Este setting no agrega tornillo ni glide más allá de la red y el puntual.")
        }
        return bits.joined(separator: " ")
    }

    private static let notes: [String: String] = [
        "P1": "Solo la red. El puntual es 1.",
        "P1̄": "Red + centro de inversión.",
        "P2": "Unique-b. 2 macizos (sin hueco) en nudos y a 1/2. GEP propios +. Polar.",
        "P2₁": "Tornillo 2₁: 180° y subida de ½. El puntual que queda es 2.",
        "Pm": "Unique-b. Solo espejo paralelo al papel a y = 0 y 1/2. Un GEP con coma. Polar.",
        "Pc": "Plano c: espejo + ½c. El puntual es m.",
        "Cc": "C-centrada + glide c. Puntual isogonal m. Cuatro GEP: +, 1/2+, -, 1/2-.",
        "P2/m": "Simorfico de 2/m. 2 con hueco (= centro). m a 0 y 1/2. GEP partidos +/-. 4 = 4 x 1.",
        "P2₁/m": "2_1 con pata. Bellow: m corre a 1/4 y 3/4. GEP 1/2+ y 1/2- apilados. Centro no coincide con el 21.",
        "P222": "Simorfico de 222. Se mira a lo largo de a. 2//a, 2//b y 2//c se cortan. GEP: xyz, x y- z-, x- y z-, x- y- z.",
        "P2₁/c": "Unique-b. 2_1 // b, glide c a 1/4 y 3/4. GEP corridos 1/2 c (no apilados). El mas frecuente en molecula pequena. Puntual 2/m.",
        "P222₁": "Se mira a lo largo de c. 2_1 // c; 2 // a y 2 // b a z = 1/4. GEP 1/2+ / 1/2-. Puntual 222.",
        "P2₁2₁2₁": "Se mira a lo largo de c. Ningun 2_1 se corta (Bellow 1/4). Origen en ninguno. 4 GEP: xyz; -x+1/2,-y,z+1/2; -x,y+1/2,-z+1/2; x+1/2,-y+1/2,-z. Proteinas. Puntual 222.",
        "I222": "P222 + (1/2,1/2,1/2). 8 GEP. 2 se cortan en 000; 2_1 se cortan en 1/4,1/4,1/4. xyz; -x,-y,z; x,-y,-z; -x,y,-z; y las cuatro + (1/2,1/2,1/2).",
        "I2₁2₁2₁": "P212121 + (1/2,1/2,1/2). Las 4 GEP de P212121 y las mismas + (1/2,1/2,1/2). 2 y 2_1 en a,b,c, pero no se cortan. Distinto de I222.",
        "Pnma": "mmm con n y a. Muy común en inorgánicos.",
        "P4₁": "Tornillo 4₁: 90° y +¼c. Enantiómorfo de P4₃.",
        "P4₃": "Tornillo 4₃, mano opuesta a P4₁. Mismo puntual 4.",
        "P3₁": "Tornillo 3₁. Enantiómorfo de P3₂.",
        "P6₃": "Tornillo 6₃ ≡ 3 + 2₁ a lo largo de c.",
        "P6̄": "Un solo grupo espacial con puntual 6̄.",
        "P6₃/mmc": "Hexagonal compacto. Puntual 6/mmm.",
        "Fm3̄m": "Cúbico compacto / NaCl. Red F + puntual m3̄m.",
        "Fd3̄m": "Diamante: deslizamiento d. Puntual m3̄m.",
        "R3̄c": "Calcita. Red R + puntual 3̄m.",
    ]

    private static func parse() -> [SpaceGroup] {
        let raw = """
        1|P1|1|aP,2|P1̄|-1|aP,\
        3|P2|2|mP,4|P2₁|2|mP,5|C2|2|mS,\
        6|Pm|m|mP,7|Pc|m|mP,8|Cm|m|mS,9|Cc|m|mS,\
        10|P2/m|2/m|mP,11|P2₁/m|2/m|mP,12|C2/m|2/m|mS,13|P2/c|2/m|mP,14|P2₁/c|2/m|mP,15|C2/c|2/m|mS,\
        16|P222|222|oP,17|P222₁|222|oP,18|P2₁2₁2|222|oP,19|P2₁2₁2₁|222|oP,20|C222₁|222|oS,21|C222|222|oS,22|F222|222|oF,23|I222|222|oI,24|I2₁2₁2₁|222|oI,\
        25|Pmm2|mm2|oP,26|Pmc2₁|mm2|oP,27|Pcc2|mm2|oP,28|Pma2|mm2|oP,29|Pca2₁|mm2|oP,30|Pnc2|mm2|oP,31|Pmn2₁|mm2|oP,32|Pba2|mm2|oP,33|Pna2₁|mm2|oP,34|Pnn2|mm2|oP,35|Cmm2|mm2|oS,36|Cmc2₁|mm2|oS,37|Ccc2|mm2|oS,38|Amm2|mm2|oS,39|Aem2|mm2|oS,40|Ama2|mm2|oS,41|Aea2|mm2|oS,42|Fmm2|mm2|oF,43|Fdd2|mm2|oF,44|Imm2|mm2|oI,45|Iba2|mm2|oI,46|Ima2|mm2|oI,\
        47|Pmmm|mmm|oP,48|Pnnn|mmm|oP,49|Pccm|mmm|oP,50|Pban|mmm|oP,51|Pmma|mmm|oP,52|Pnna|mmm|oP,53|Pmna|mmm|oP,54|Pcca|mmm|oP,55|Pbam|mmm|oP,56|Pccn|mmm|oP,57|Pbcm|mmm|oP,58|Pnnm|mmm|oP,59|Pmmn|mmm|oP,60|Pbcn|mmm|oP,61|Pbca|mmm|oP,62|Pnma|mmm|oP,63|Cmcm|mmm|oS,64|Cmce|mmm|oS,65|Cmmm|mmm|oS,66|Cccm|mmm|oS,67|Cmme|mmm|oS,68|Ccce|mmm|oS,69|Fmmm|mmm|oF,70|Fddd|mmm|oF,71|Immm|mmm|oI,72|Ibam|mmm|oI,73|Ibca|mmm|oI,74|Imma|mmm|oI,\
        75|P4|4|tP,76|P4₁|4|tP,77|P4₂|4|tP,78|P4₃|4|tP,79|I4|4|tI,80|I4₁|4|tI,\
        81|P4̄|-4|tP,82|I4̄|-4|tI,\
        83|P4/m|4/m|tP,84|P4₂/m|4/m|tP,85|P4/n|4/m|tP,86|P4₂/n|4/m|tP,87|I4/m|4/m|tI,88|I4₁/a|4/m|tI,\
        89|P422|422|tP,90|P42₁2|422|tP,91|P4₁22|422|tP,92|P4₁2₁2|422|tP,93|P4₂22|422|tP,94|P4₂2₁2|422|tP,95|P4₃22|422|tP,96|P4₃2₁2|422|tP,97|I422|422|tI,98|I4₁22|422|tI,\
        99|P4mm|4mm|tP,100|P4bm|4mm|tP,101|P4₂cm|4mm|tP,102|P4₂nm|4mm|tP,103|P4cc|4mm|tP,104|P4nc|4mm|tP,105|P4₂mc|4mm|tP,106|P4₂bc|4mm|tP,107|I4mm|4mm|tI,108|I4cm|4mm|tI,109|I4₁md|4mm|tI,110|I4₁cd|4mm|tI,\
        111|P4̄2m|-42m|tP,112|P4̄2c|-42m|tP,113|P4̄2₁m|-42m|tP,114|P4̄2₁c|-42m|tP,115|P4̄m2|-42m|tP,116|P4̄c2|-42m|tP,117|P4̄b2|-42m|tP,118|P4̄n2|-42m|tP,119|I4̄m2|-42m|tI,120|I4̄c2|-42m|tI,121|I4̄2m|-42m|tI,122|I4̄2d|-42m|tI,\
        123|P4/mmm|4/mmm|tP,124|P4/mcc|4/mmm|tP,125|P4/nbm|4/mmm|tP,126|P4/nnc|4/mmm|tP,127|P4/mbm|4/mmm|tP,128|P4/mnc|4/mmm|tP,129|P4/nmm|4/mmm|tP,130|P4/ncc|4/mmm|tP,131|P4₂/mmc|4/mmm|tP,132|P4₂/mcm|4/mmm|tP,133|P4₂/nbc|4/mmm|tP,134|P4₂/nnm|4/mmm|tP,135|P4₂/mbc|4/mmm|tP,136|P4₂/mnm|4/mmm|tP,137|P4₂/nmc|4/mmm|tP,138|P4₂/ncm|4/mmm|tP,139|I4/mmm|4/mmm|tI,140|I4/mcm|4/mmm|tI,141|I4₁/amd|4/mmm|tI,142|I4₁/acd|4/mmm|tI,\
        143|P3|3|hP,144|P3₁|3|hP,145|P3₂|3|hP,146|R3|3|hR,\
        147|P3̄|-3|hP,148|R3̄|-3|hR,\
        149|P312|32|hP,150|P321|32|hP,151|P3₁12|32|hP,152|P3₁21|32|hP,153|P3₂12|32|hP,154|P3₂21|32|hP,155|R32|32|hR,\
        156|P3m1|3m|hP,157|P31m|3m|hP,158|P3c1|3m|hP,159|P31c|3m|hP,160|R3m|3m|hR,161|R3c|3m|hR,\
        162|P3̄1m|-3m|hP,163|P3̄1c|-3m|hP,164|P3̄m1|-3m|hP,165|P3̄c1|-3m|hP,166|R3̄m|-3m|hR,167|R3̄c|-3m|hR,\
        168|P6|6|hP,169|P6₁|6|hP,170|P6₅|6|hP,171|P6₂|6|hP,172|P6₄|6|hP,173|P6₃|6|hP,\
        174|P6̄|-6|hP,\
        175|P6/m|6/m|hP,176|P6₃/m|6/m|hP,\
        177|P622|622|hP,178|P6₁22|622|hP,179|P6₅22|622|hP,180|P6₂22|622|hP,181|P6₄22|622|hP,182|P6₃22|622|hP,\
        183|P6mm|6mm|hP,184|P6cc|6mm|hP,185|P6₃cm|6mm|hP,186|P6₃mc|6mm|hP,\
        187|P6̄m2|-62m|hP,188|P6̄c2|-62m|hP,189|P6̄2m|-62m|hP,190|P6̄2c|-62m|hP,\
        191|P6/mmm|6/mmm|hP,192|P6/mcc|6/mmm|hP,193|P6₃/mcm|6/mmm|hP,194|P6₃/mmc|6/mmm|hP,\
        195|P23|23|cP,196|F23|23|cF,197|I23|23|cI,198|P2₁3|23|cP,199|I2₁3|23|cI,\
        200|Pm3̄|m-3|cP,201|Pn3̄|m-3|cP,202|Fm3̄|m-3|cF,203|Fd3̄|m-3|cF,204|Im3̄|m-3|cI,205|Pa3̄|m-3|cP,206|Ia3̄|m-3|cI,\
        207|P432|432|cP,208|P4₂32|432|cP,209|F432|432|cF,210|F4₁32|432|cF,211|I432|432|cI,212|P4₃32|432|cP,213|P4₁32|432|cP,214|I4₁32|432|cI,\
        215|P4̄3m|-43m|cP,216|F4̄3m|-43m|cF,217|I4̄3m|-43m|cI,218|P4̄3n|-43m|cP,219|F4̄3c|-43m|cF,220|I4̄3d|-43m|cI,\
        221|Pm3̄m|m-3m|cP,222|Pn3̄n|m-3m|cP,223|Pm3̄n|m-3m|cP,224|Pn3̄m|m-3m|cP,225|Fm3̄m|m-3m|cF,226|Fm3̄c|m-3m|cF,227|Fd3̄m|m-3m|cF,228|Fd3̄c|m-3m|cF,229|Im3̄m|m-3m|cI,230|Ia3̄d|m-3m|cI
        """
        return raw.split(separator: ",").compactMap { row in
            let p = row.split(separator: "|").map(String.init)
            guard p.count == 4, let n = Int(p[0]) else { return nil }
            return SpaceGroup(n: n, hm: p[1], pgId: p[2], br: p[3])
        }
    }
}
