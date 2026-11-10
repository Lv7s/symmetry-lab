import SwiftUI

struct NetsView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $model.netMode) {
                    ForEach(AppModel.NetMode.allCases, id: \.self) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

                switch model.netMode {
                case .plano: planePane
                case .bravais: bravaisPane
                case .espacial: spacePane
                }
            }
            .background(Ink.paper)
            .navigationTitle("Redes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var planePane: some View {
        let g = PlaneGroupCatalog.byId(model.planeId)
        return VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(PlaneGroupCatalog.all) { p in
                        Button {
                            model.planeId = p.id
                        } label: {
                            Text(p.id)
                                .font(.placa(14, weight: model.planeId == p.id ? .bold : .regular))
                                .foregroundStyle(model.planeId == p.id ? Ink.paper : Ink.ink)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(model.planeId == p.id ? Ink.ink : Ink.paperDeep.opacity(0.5))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            Net2DCanvas(group: g, showRed: model.showRed, showPuntual: model.showPuntual, showEspacial: model.showEspacial)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(alignment: .leading, spacing: 8) {
                Text("\(g.id)  ·  puntual \(g.pg)  ·  \(g.red)")
                    .font(.placa(16, weight: .bold))
                Text(g.extra)
                    .font(.placa(13))
                    .foregroundStyle(Ink.ink.opacity(0.85))
                HStack {
                    Toggle("Red", isOn: $model.showRed)
                    Toggle("Puntual", isOn: $model.showPuntual)
                    Toggle("Glides", isOn: $model.showEspacial)
                }
                .font(.placa(12))
                .toggleStyle(.switch)
                Text("Los 17 planos estan en ITA (Alhambra). Richard no los dibuja: dice que es un ejercicio un tanto tonto y no sirve para resolver estructuras. Apagar glides deja el puntual.")
                    .font(.placa(11))
                    .foregroundStyle(Ink.muted)
            }
            .padding(14)
            .background(Ink.card)
        }
    }

    private var bravaisPane: some View {
        let b = BravaisLattice.byId(model.bravaisId)
        return VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(BravaisLattice.all) { x in
                        Button { model.bravaisId = x.id } label: {
                            Text(x.id)
                                .font(.placa(14, weight: model.bravaisId == x.id ? .bold : .regular))
                                .foregroundStyle(model.bravaisId == x.id ? Ink.paper : Ink.ink)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(model.bravaisId == x.id ? Ink.ink : Ink.paperDeep.opacity(0.5))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            BravaisCanvas(lattice: b)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(alignment: .leading, spacing: 6) {
                Text("\(b.id)  ·  \(b.sys)")
                    .font(.placa(16, weight: .bold))
                Text(b.name)
                    .font(.placa(13))
                Text("Solo 14: 7 sistemas × 4 centrados no dan 28. Unique-b en monoclínico. Nodos extra en rojo.")
                    .font(.placa(11))
                    .foregroundStyle(Ink.muted)
            }
            .padding(14)
            .background(Ink.card)
        }
    }

    private var spacePane: some View {
        let sg = SpaceGroupCatalog.byN(model.spaceN)
        return VStack(alignment: .leading, spacing: 0) {
            if let cap = SpaceSketch.caption(sg.n) {
                SpaceSketch.canvas(sg.n)
                    .frame(height: 250)
                Text(cap)
                    .font(.placa(12))
                    .foregroundStyle(Ink.muted)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
            }
            List {
                ForEach(SpaceGroupCatalog.all) { s in
                    Button {
                        model.spaceN = s.n
                    } label: {
                        HStack {
                            Text("\(s.n)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(Ink.muted)
                                .frame(width: 36, alignment: .leading)
                            Text(s.hm)
                                .font(.placa(16, weight: s.n == model.spaceN ? .bold : .regular))
                                .foregroundStyle(Ink.ink)
                            Spacer()
                            Text(s.br)
                                .font(.placa(12))
                                .foregroundStyle(Ink.muted)
                        }
                    }
                    .listRowBackground(s.n == model.spaceN ? Ink.paperDeep : Ink.paper)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            VStack(alignment: .leading, spacing: 6) {
                Text("\(sg.hm)  nº \(sg.n)")
                    .font(.placa(18, weight: .bold))
                Text(SpaceGroupCatalog.describe(sg.hm))
                    .font(.placa(13))
                Button("Abrir puntual isogonal \(sg.pgId) en el estereograma") {
                    model.openGroup(sg.pgId)
                }
                .font(.placa(13, weight: .semibold))
                .foregroundStyle(Ink.improper)
                Text("Richard no dibuja los 230: la lista es ITA. El curso dibuja triclínico–monoclínico–ortorrómbico (P2, Pm, Cc, P2/m, P21/m, P21/c, P222, P2221, P212121, I222, I212121). El resto se lee en las tablas.")
                    .font(.placa(11))
                    .foregroundStyle(Ink.muted)
            }
            .padding(14)
            .background(Ink.card)
        }
    }
}
