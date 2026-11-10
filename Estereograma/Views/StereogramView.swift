import SwiftUI

struct StereogramView: View {
    @EnvironmentObject var model: AppModel
    @State private var show3d = false

    var body: some View {
        let g = model.group
        NavigationStack {
            VStack(spacing: 0) {
                groupStrip
                ZStack {
                    if show3d {
                        SphereCanvas(group: g, seed: model.seed, highlight: model.highlightXyz)
                    } else {
                        StereogramCanvas(
                            group: g,
                            seed: model.seed,
                            highlight: model.highlightXyz,
                            onSeedChange: { model.seed = $0 },
                            onHighlight: { model.highlightXyz = $0 }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Ink.paper)

                infoPanel(g)
            }
            .background(Ink.paper)
            .navigationTitle("Estereograma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(show3d ? "2D" : "3D") { show3d.toggle() }
                        .font(.placa(14, weight: .semibold))
                        .foregroundStyle(Ink.ink)
                }
            }
        }
    }

    private var groupStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(PointGroupCatalog.all) { g in
                    Button {
                        model.groupId = g.id
                        model.highlightXyz = nil
                    } label: {
                        Text(g.hm)
                            .font(.placa(15, weight: model.groupId == g.id ? .bold : .regular))
                            .foregroundStyle(model.groupId == g.id ? Ink.paper : Ink.ink)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(model.groupId == g.id ? Ink.ink : Ink.paperDeep.opacity(0.5))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Ink.paper)
    }

    private func infoPanel(_ g: PointGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(g.hm)
                    .font(.placa(28, weight: .bold))
                Text(g.schoenflies)
                    .font(.placa(16))
                    .foregroundStyle(Ink.muted)
                Spacer()
                Text(g.systemLabel)
                    .font(.placa(13, weight: .semibold))
                    .foregroundStyle(Ink.muted)
            }
            HStack(spacing: 8) {
                chip("\(g.order) operaciones")
                if g.hasImproper { chip("con impropios", tint: Ink.improper) }
                if g.centrosymmetric { chip("centro 1̄") }
                if g.polar { chip("polar") }
                if g.chiral { chip("quiral") }
                if let eq = g.equivalent { chip("≡ \(eq)") }
            }
            if let note = g.notes.first {
                Text(note)
                    .font(.placa(13))
                    .foregroundStyle(Ink.ink.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(g.ops) { op in
                        Button {
                            model.highlightXyz = op.xyz
                        } label: {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(op.label)
                                    .font(.placa(13, weight: .semibold))
                                Text(op.xyz)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(Ink.muted)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(model.highlightXyz == op.xyz ? Ink.improper.opacity(0.15) : Ink.paperDeep.opacity(0.55))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(op.proper ? Ink.line : Ink.improper.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            Text("Arrastrá un GEP. Círculo grueso = mh (espejo en el papel). Óvalo partido = + y − apilados. Coma = mano cambiada.")
                .font(.placa(11))
                .foregroundStyle(Ink.muted)
        }
        .padding(14)
        .background(Ink.card)
    }

    private func chip(_ t: String, tint: Color = Ink.ink) -> some View {
        Text(t)
            .font(.placa(11, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct SphereCanvas: View {
    var group: PointGroup
    var seed: Vec3
    var highlight: String?
    @State private var yaw: Double = 0.45
    @State private var pitch: Double = 0.35
    @State private var dragStart: CGSize = .zero

    var body: some View {
        Canvas { ctx, size in
            let scene = buildScene3d(group, seed: seed)
            let cx = size.width / 2
            let cy = size.height / 2
            let S = min(size.width, size.height) * 0.32
            func proj(_ p: Vec3) -> (CGPoint, Double) {
                var q = rotateY(p, yaw)
                q = rotateX(q, pitch)
                return (CGPoint(x: cx + CGFloat(q.x) * S, y: cy - CGFloat(q.y) * S), q.z)
            }

            let r = CGFloat(scene.sphereR) * S
            ctx.fill(Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)), with: .color(Ink.paperDeep.opacity(0.45)))
            var ring = Path()
            ring.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
            ctx.stroke(ring, with: .color(Ink.ink), lineWidth: 1.2)

            var eq = Path()
            eq.addEllipse(in: CGRect(x: cx - r, y: cy - r * 0.22, width: r * 2, height: r * 0.44))
            ctx.stroke(eq, with: .color(Ink.muted.opacity(0.7)), lineWidth: 0.8)

            for pl in scene.planes {
                let pts = greatCircle(pl.normal, radius: scene.sphereR)
                guard let first = pts.first else { continue }
                var path = Path()
                path.move(to: proj(first).0)
                for p in pts.dropFirst() {
                    path.addLine(to: proj(p).0)
                }
                ctx.stroke(path, with: .color(Ink.improper.opacity(0.85)), lineWidth: 1.8)
            }

            for ax in scene.crystalAxes {
                let a = proj(ax.dir * (scene.sphereR * 1.12))
                let b = proj(ax.dir * (-scene.sphereR * 1.12))
                var p = Path()
                p.move(to: a.0)
                p.addLine(to: b.0)
                if ax.cartesian {
                    ctx.stroke(p, with: .color(Ink.ink), lineWidth: 1.45)
                } else {
                    ctx.stroke(p, with: .color(Ink.muted), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                }
                let tip = proj(ax.dir * (scene.sphereR * 1.28)).0
                ctx.draw(
                    Text(ax.label)
                        .font(.placa(ax.cartesian ? 13 : 11, weight: .bold))
                        .foregroundColor(ax.cartesian ? Ink.ink : Ink.muted),
                    at: CGPoint(x: tip.x + 10, y: tip.y)
                )
            }

            for ax in scene.axes {
                let a = proj(ax.dir * scene.sphereR)
                let b = proj(ax.dir * -scene.sphereR)
                var p = Path()
                p.move(to: a.0)
                p.addLine(to: b.0)
                ctx.stroke(p, with: .color(Ink.ink.opacity(0.4)), lineWidth: 1)
            }

            let copies = scene.copies.sorted { proj($0.center).1 < proj($1.center).1 }
            for c in copies {
                let pr = proj(c.center)
                let rad: CGFloat = 8
                let rect = CGRect(x: pr.0.x - rad, y: pr.0.y - rad * 0.65, width: rad * 2, height: rad * 1.3)
                var oval = Path()
                oval.addEllipse(in: rect)
                ctx.stroke(oval, with: .color(c.op.xyz == highlight ? Ink.improper : Ink.ink), lineWidth: 1.4)
                if !c.op.proper {
                    ctx.fill(Path(ellipseIn: CGRect(x: pr.0.x - 2, y: pr.0.y + 4, width: 4, height: 6)), with: .color(Ink.improper))
                }
                let sign = c.upper ? "+" : "−"
                ctx.draw(Text(sign).font(.placa(10, weight: .bold)).foregroundColor(Ink.ink), at: CGPoint(x: pr.0.x + 12, y: pr.0.y))
            }
        }
        .background(Ink.paper)
        .gesture(
            DragGesture()
                .onChanged { v in
                    yaw += Double(v.translation.width - dragStart.width) * 0.01
                    pitch = min(1.2, max(-1.2, pitch + Double(v.translation.height - dragStart.height) * 0.01))
                    dragStart = v.translation
                }
                .onEnded { _ in dragStart = .zero }
        )
        .overlay(alignment: .bottom) {
            Text("Triedro x y z  ·  rojo = espejo  ·  arrastrá para girar")
                .font(.placa(11))
                .foregroundStyle(Ink.muted)
                .padding(8)
        }
    }
}
