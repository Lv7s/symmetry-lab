import SwiftUI

struct TriangleLabView: View {
    @State private var modeC3 = false
    @State private var state: Triple = TriangleLab.initial
    @State private var last: D3El?
    @State private var highlight: (Int, Int)?

    private var elements: [D3El] { modeC3 ? TriangleLab.c3 : D3El.allCases }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("", selection: $modeC3) {
                        Text("C3").tag(true)
                        Text("D3").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: modeC3) { _, _ in reset() }

                    triangleCard
                    buttons
                    table
                    rules
                }
                .padding(16)
                .padding(.bottom, 28)
            }
            .background(Ink.paper)
            .navigationTitle("Triángulo C3 / D3")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") { reset() }
                        .font(.placa(14, weight: .semibold))
                        .foregroundStyle(Ink.ink)
                }
            }
        }
    }

    private var triangleCard: some View {
        VStack(spacing: 8) {
            Text(modeC3 ? "Grupo C3  ·  {E, R, R²}" : "Grupo D3  ·  {E, R, R², m1, m2, m3}")
                .font(.placa(16, weight: .bold))
            TriangleShape(state: state)
                .frame(height: 240)
            Text("(\(state.0.rawValue), \(state.1.rawValue), \(state.2.rawValue))  ·  ápice, derecha, izquierda")
                .font(.placa(13))
                .foregroundStyle(Ink.muted)
            if let last {
                Text(last.isProper ? "\(last.rawValue) · propia (no cambia la mano)" : "\(last.rawValue) · impropia (cambia la mano)")
                    .font(.placa(13, weight: .semibold))
                    .foregroundStyle(last.isProper ? Ink.ink : Ink.improper)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Ink.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var buttons: some View {
        HStack(spacing: 8) {
            ForEach(elements) { el in
                Button {
                    state = TriangleLab.apply(state, el)
                    last = el
                } label: {
                    Text(el.rawValue)
                        .font(.placa(16, weight: .semibold))
                        .foregroundStyle(Ink.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Ink.paperDeep)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    private var table: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tabla de multiplicación  ·  fila primero, columna después")
                .font(.placa(13, weight: .semibold))
            let els = elements
            Grid(horizontalSpacing: 3, verticalSpacing: 3) {
                GridRow {
                    Text("∘").font(.placa(11, weight: .bold)).frame(width: 32)
                    ForEach(els) { c in
                        Text(c.rawValue).font(.placa(11, weight: .bold)).frame(width: 36)
                    }
                }
                ForEach(Array(els.enumerated()), id: \.offset) { i, row in
                    GridRow {
                        Text(row.rawValue).font(.placa(11, weight: .bold)).frame(width: 32)
                        ForEach(Array(els.enumerated()), id: \.offset) { j, col in
                            let v = TriangleLab.compose(first: row, second: col)
                            Text(v.rawValue)
                                .font(.placa(11, weight: .semibold))
                                .frame(width: 36, height: 28)
                                .background(highlight.map { $0 == (i, j) } == true ? Ink.improper.opacity(0.2) : Ink.paperDeep.opacity(0.6))
                                .onTapGesture { highlight = (i, j) }
                        }
                    }
                }
            }
            if !modeC3 {
                Text("Como en la pizarra: 3¹ luego m2 ≡ m3, pero m2 luego 3¹ ≡ m1. No es abeliano.")
                    .font(.placa(12))
                    .foregroundStyle(Ink.improper)
            }
        }
        .padding(12)
        .background(Ink.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var rules: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Propio ∘ propio = propio.")
            Text("Propio ∘ impropio = impropio.")
            Text("Impropio ∘ impropio = propio (cambiaste la mano dos veces).")
            Text("3¹ = R = 120° horario. m1 por el ápice A; m2 por B (derecha); m3 por C (izquierda).")
        }
        .font(.placa(13))
        .foregroundStyle(Ink.ink.opacity(0.85))
    }

    private func reset() {
        state = TriangleLab.initial
        last = nil
        highlight = nil
    }
}

struct TriangleShape: View {
    var state: Triple

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let top = CGPoint(x: w / 2, y: h * 0.12)
            let right = CGPoint(x: w * 0.82, y: h * 0.82)
            let left = CGPoint(x: w * 0.18, y: h * 0.82)
            ZStack {
                Path { p in
                    p.move(to: top); p.addLine(to: right); p.addLine(to: left); p.closeSubpath()
                }
                .stroke(Ink.ink, lineWidth: 2)
                Path { p in
                    p.move(to: top)
                    p.addLine(to: CGPoint(x: (left.x + right.x) / 2, y: (left.y + right.y) / 2))
                }
                .stroke(Ink.muted.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                Text("m1")
                    .font(.placa(11, weight: .semibold))
                    .foregroundStyle(Ink.muted)
                    .position(x: (top.x + (left.x + right.x) / 2) / 2 + 18, y: (top.y + (left.y + right.y) / 2) / 2)
                Text("m2")
                    .font(.placa(11, weight: .semibold))
                    .foregroundStyle(Ink.muted)
                    .position(x: right.x + 22, y: right.y - 8)
                Text("m3")
                    .font(.placa(11, weight: .semibold))
                    .foregroundStyle(Ink.muted)
                    .position(x: (top.x + right.x) / 2 + 16, y: (top.y + right.y) / 2 - 8)
                vertex(state.0, at: top)
                vertex(state.1, at: right)
                vertex(state.2, at: left)
            }
        }
    }

    private func vertex(_ v: Vert, at p: CGPoint) -> some View {
        ZStack {
            Circle().fill(Ink.ink).frame(width: 36, height: 36)
            Text(v.rawValue)
                .font(.placa(16, weight: .bold))
                .foregroundStyle(Ink.paper)
        }
        .position(p)
    }
}
