import SwiftUI
import UIKit

struct Net2DCanvas: UIViewRepresentable {
    var group: PlaneGroup
    var showRed: Bool
    var showPuntual: Bool
    var showEspacial: Bool

    func makeUIView(context: Context) -> Net2DUIView {
        let v = Net2DUIView()
        v.backgroundColor = UIColor(Ink.paper)
        v.payload = (group, showRed, showPuntual, showEspacial)
        return v
    }

    func updateUIView(_ uiView: Net2DUIView, context: Context) {
        uiView.payload = (group, showRed, showPuntual, showEspacial)
        uiView.setNeedsDisplay()
    }
}

final class Net2DUIView: UIView {
    var payload: (group: PlaneGroup, showRed: Bool, showPuntual: Bool, showEspacial: Bool) = (
        PlaneGroupCatalog.byId("pgg"), true, true, true
    )

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let paper = UIColor(Ink.paper)
        let ink = UIColor(Ink.ink)
        let muted = UIColor(Ink.muted)
        let line = UIColor(Ink.line)
        paper.setFill()
        ctx.fill(bounds)

        let group = payload.group
        let axes = cellAxes(group.cell)
        let S = min(bounds.width, bounds.height) * 0.26
        let o = CGPoint(x: bounds.width * 0.18, y: bounds.height * 0.72)
        func xy(_ u: Double, _ v: Double) -> CGPoint {
            CGPoint(
                x: o.x + CGFloat(u * axes.ax.0 + v * axes.ay.0) * S,
                y: o.y - CGFloat(u * axes.ax.1 + v * axes.ay.1) * S
            )
        }

        var tiles: [(Int, Int)] = []
        for i in -1...3 { for j in -1...3 { tiles.append((i, j)) } }

        if payload.showRed {
            ctx.setStrokeColor(line.cgColor)
            ctx.setLineWidth(1)
            for (i, j) in tiles {
                let p00 = xy(Double(i), Double(j))
                let p10 = xy(Double(i + 1), Double(j))
                let p01 = xy(Double(i), Double(j + 1))
                ctx.move(to: p00); ctx.addLine(to: p10); ctx.strokePath()
                ctx.move(to: p00); ctx.addLine(to: p01); ctx.strokePath()
            }
            ink.setFill()
            for (i, j) in tiles {
                let p = xy(Double(i), Double(j))
                ctx.fill(CGRect(x: p.x - 2.2, y: p.y - 2.2, width: 4.4, height: 4.4))
            }
            ctx.setStrokeColor(ink.cgColor)
            ctx.setLineWidth(1.8)
            let c00 = xy(0, 0), c10 = xy(1, 0), c11 = xy(1, 1), c01 = xy(0, 1)
            ctx.move(to: c00); ctx.addLine(to: c10); ctx.addLine(to: c11); ctx.addLine(to: c01); ctx.closePath()
            ctx.strokePath()
            drawText("a", at: CGPoint(x: (c00.x + c10.x) / 2, y: c00.y + 16), font: 13, color: ink)
            drawText("b", at: CGPoint(x: c00.x - 16, y: (c00.y + c01.y) / 2), font: 13, color: ink)
        }

        if group.id == "pgg" && payload.showEspacial {
            drawPggGlides(ctx, xy: xy, ink: ink)
        }

        let ops: [Op2]
        if payload.showEspacial { ops = group.ops }
        else if payload.showPuntual { ops = group.ops.filter(isPurePoint) }
        else { ops = [] }
        let seed: (Double, Double) = (0.28, 0.19)
        let useTiles = payload.showRed ? tiles : [(0, 0)]
        if !ops.isEmpty {
            for (i, j) in useTiles {
                for o in ops {
                    let q = applyOp2(o, seed.0, seed.1)
                    let p = xy(q.0 + Double(i), q.1 + Double(j))
                    if p.x < 16 || p.y < 16 || p.x > bounds.width - 16 || p.y > bounds.height - 16 { continue }
                    drawOval(ctx, at: p, improper: o.det < 0, paper: paper, ink: ink)
                }
            }
        }

        drawText(group.id, at: CGPoint(x: bounds.width - 28, y: 18), font: 12, color: muted)
    }

    /// ITA pgg: glides g ∥ a at y = ¼, ¾ and g ∥ b at x = ¼, ¾ (dashed arrows).
    private func drawPggGlides(_ ctx: CGContext, xy: (Double, Double) -> CGPoint, ink: UIColor) {
        ctx.setStrokeColor(ink.cgColor)
        ctx.setLineWidth(1.25)
        ctx.setLineDash(phase: 0, lengths: [5, 4])
        let yGlides: [Double] = [0.25, 0.75]
        for y in yGlides {
            let a = xy(-0.05, y)
            let b = xy(1.05, y)
            ctx.move(to: a); ctx.addLine(to: b); ctx.strokePath()
        }
        let xGlides: [Double] = [0.25, 0.75]
        for x in xGlides {
            let a = xy(x, -0.05)
            let b = xy(x, 1.05)
            ctx.move(to: a); ctx.addLine(to: b); ctx.strokePath()
        }
        ctx.setLineDash(phase: 0, lengths: [])
        drawText("g", at: xy(0.52, 0.25), font: 11, color: ink)
        drawText("g", at: xy(0.25, 0.52), font: 11, color: ink)
    }

    private func drawOval(_ ctx: CGContext, at p: CGPoint, improper: Bool, paper: UIColor, ink: UIColor) {
        let rect = CGRect(x: p.x - 11, y: p.y - 6.4, width: 22, height: 12.8)
        paper.setFill()
        ctx.fillEllipse(in: rect)
        ink.setStroke()
        ctx.setLineWidth(1.2)
        ctx.strokeEllipse(in: rect)
        drawText("+", at: p, font: 9, color: ink)
        if improper {
            UIColor(Ink.improper).setStroke()
            ctx.strokeEllipse(in: CGRect(x: p.x + 2, y: p.y + 4, width: 5, height: 7))
        }
    }

    private func drawText(_ s: String, at p: CGPoint, font: CGFloat, color: UIColor) {
        let f = UIFont.systemFont(ofSize: font, weight: .semibold)
        let size = (s as NSString).size(withAttributes: [.font: f])
        (s as NSString).draw(at: CGPoint(x: p.x - size.width / 2, y: p.y - size.height / 2), withAttributes: [
            .font: f, .foregroundColor: color,
        ])
    }
}

struct BravaisCanvas: View {
    var lattice: BravaisLattice
    @State private var yaw: Double = 0.7
    @State private var pitch: Double = 0.4
    @State private var dragStart: CGSize = .zero

    var body: some View {
        Canvas { ctx, size in
            let B = basisFor(lattice.id)
            let cx = size.width / 2
            let cy = size.height / 2
            let S = min(size.width, size.height) * 0.28
            func cart(_ f: [Double]) -> Vec3 {
                let c = fracToCart(f, B)
                return Vec3(x: c[0], y: c[1], z: c[2])
            }
            func proj(_ p: Vec3) -> CGPoint {
                var q = rotateY(p, yaw)
                q = rotateX(q, pitch)
                return CGPoint(x: cx + CGFloat(q.x) * S, y: cy - CGFloat(q.y) * S)
            }
            let corners: [[Double]] = [
                [0, 0, 0], [1, 0, 0], [1, 1, 0], [0, 1, 0],
                [0, 0, 1], [1, 0, 1], [1, 1, 1], [0, 1, 1],
            ]
            let edges = [(0, 1), (1, 2), (2, 3), (3, 0), (4, 5), (5, 6), (6, 7), (7, 4), (0, 4), (1, 5), (2, 6), (3, 7)]
            for e in edges {
                var p = Path()
                p.move(to: proj(cart(corners[e.0])))
                p.addLine(to: proj(cart(corners[e.1])))
                ctx.stroke(p, with: .color(Ink.ink), lineWidth: 1.3)
            }
            func dot(_ f: [Double], extra: Bool) {
                let pt = proj(cart(f))
                let r: CGFloat = extra ? 5 : 6
                ctx.fill(Path(ellipseIn: CGRect(x: pt.x - r, y: pt.y - r, width: r * 2, height: r * 2)), with: .color(extra ? Ink.improper : Ink.ink))
            }
            for c in corners { dot(c, extra: false) }
            for e in lattice.extra { dot(e, extra: true) }
        }
        .background(Ink.paper)
        .gesture(DragGesture()
            .onChanged { v in
                yaw += Double(v.translation.width - dragStart.width) * 0.01
                pitch = min(1.1, max(-0.2, pitch + Double(v.translation.height - dragStart.height) * 0.01))
                dragStart = v.translation
            }
            .onEnded { _ in dragStart = .zero }
        )
    }
}

/// P2 (nº 3), pizarra 4-up: unique-b, 2 macizos, dos GEP propios +. Polar, sin m.
struct P2CellCanvas: View {
    var body: some View {
        Canvas { ctx, size in
            let g = MonoGeom(size: size)
            g.strokeCell(ctx)
            g.dashHalf(ctx)
            g.twos(ctx, hole: false)
            g.plusGep(ctx, at: g.xy(0.22, 0.28))
            g.plusGep(ctx, at: g.xy(0.78, 0.72))
            g.plusGep(ctx, at: g.xy(-0.06, -0.10))
            g.axisLetters(ctx)
            g.triad(ctx)
        }
        .background(Ink.paper)
    }
}

/// Pm (nº 6), pizarra 4-up: solo m paralelo al papel (⌝ 0, 1/2). Un GEP con coma. Polar.
struct PmCellCanvas: View {
    var body: some View {
        Canvas { ctx, size in
            let g = MonoGeom(size: size)
            g.strokeCell(ctx)
            g.dashHalf(ctx)
            g.splitGep(ctx, at: g.xy(0.22, 0.28), plus: "+", minus: "", comma: true)
            g.mirrorMark(ctx, heights: "0, 1/2")
            g.axisLetters(ctx)
            g.triad(ctx)
        }
        .background(Ink.paper)
    }
}

/// P2/m (nº 10), pizarra 4-up: 2 con hueco (= 1-bar), m a 0 y 1/2, GEP partidos +/−.
struct P2mCellCanvas: View {
    var body: some View {
        Canvas { ctx, size in
            let g = MonoGeom(size: size)
            g.strokeCell(ctx)
            g.dashHalf(ctx)
            g.twos(ctx, hole: true)
            g.splitGep(ctx, at: g.xy(0.22, 0.28))
            g.splitGep(ctx, at: g.xy(0.78, 0.72))
            g.plusGep(ctx, at: g.xy(-0.06, -0.10))
            g.mirrorMark(ctx, heights: "0, 1/2")
            g.axisLetters(ctx)
            g.triad(ctx)
        }
        .background(Ink.paper)
    }
}

/// P2_1/m (nº 11), pizarra 4-up: 2_1 con pata, m a 1/4 y 3/4 (Bellow), GEP 1/2+ y 1/2- apilados.
struct P21mCellCanvas: View {
    var body: some View {
        Canvas { ctx, size in
            let g = MonoGeom(size: size)
            g.strokeCell(ctx)
            g.dashHalf(ctx)
            g.screws(ctx)
            g.splitGep(ctx, at: g.xy(0.22, 0.28), plus: "1/2+", minus: "1/2-", comma: true)
            g.splitGep(ctx, at: g.xy(0.78, 0.72), plus: "1/2+", minus: "1/2-", comma: true)
            g.simpleGep(ctx, at: g.xy(-0.08, -0.12), text: "1/2+", comma: false)
            g.mirrorMark(ctx, heights: "1/4, 3/4")
            g.axisLetters(ctx)
            g.triad(ctx)
        }
        .background(Ink.paper)
    }
}

/// Cc (nº 9), pizarra clase 9: C + glide c. Cuatro GEP. Isogonal m.
struct CcCellCanvas: View {
    var body: some View {
        Canvas { ctx, size in
            let g = MonoGeom(size: size)
            g.strokeCell(ctx)
            g.dashHalf(ctx)
            g.simpleGep(ctx, at: g.xy(0.22, 0.22), text: "+", comma: false)
            g.simpleGep(ctx, at: g.xy(0.72, 0.22), text: "1/2+", comma: false)
            g.simpleGep(ctx, at: g.xy(0.22, 0.72), text: "-", comma: true)
            g.simpleGep(ctx, at: g.xy(0.72, 0.72), text: "1/2-", comma: false)
            g.axisLetters(ctx)
            g.triad(ctx)
            ctx.draw(
                Text("Cc -> m").font(.placa(13, weight: .bold)),
                at: CGPoint(x: g.origin.x + 70, y: 14)
            )
            ctx.draw(
                Text("o = 1/2").font(.placa(11)).foregroundColor(Ink.muted),
                at: CGPoint(x: g.xy(1, 0).x + 36, y: g.xy(1, 0.5).y)
            )
        }
        .background(Ink.paper)
    }
}

/// P222 (nº 16), pizarra clase 11: se mira a lo largo de a (punto), c abajo, b a la derecha.
struct P222CellCanvas: View {
    var body: some View {
        Canvas { ctx, size in
            let pad: CGFloat = 28
            let o = CGPoint(x: pad + 28, y: pad + 8)
            let A: CGFloat = size.width * 0.52
            let C: CGFloat = size.height * 0.58
            func xy(_ u: CGFloat, _ v: CGFloat) -> CGPoint {
                CGPoint(x: o.x + u * A, y: o.y + v * C)
            }
            var cell = Path()
            cell.addRect(CGRect(x: o.x, y: o.y, width: A, height: C))
            ctx.stroke(cell, with: .color(Ink.ink), lineWidth: 2)

            var dash = Path()
            dash.move(to: xy(0, 0.5)); dash.addLine(to: xy(1, 0.5))
            dash.move(to: xy(0.5, 0)); dash.addLine(to: xy(0.5, 1))
            ctx.stroke(dash, with: .color(Ink.improper.opacity(0.45)), style: StrokeStyle(lineWidth: 1.1, dash: [5, 4]))

            let sites: [(CGFloat, CGFloat)] = [
                (0, 0), (1, 0), (0, 1), (1, 1), (0.5, 0), (0.5, 1), (0, 0.5), (1, 0.5), (0.5, 0.5),
            ]
            for s in sites {
                let p = xy(s.0, s.1)
                var loz = Path()
                loz.addEllipse(in: CGRect(x: p.x - 3.2, y: p.y - 6.5, width: 6.4, height: 13))
                ctx.fill(loz, with: .color(Ink.ink))
            }

            func arrow(_ from: CGPoint, _ to: CGPoint) {
                var p = Path()
                p.move(to: from)
                p.addLine(to: to)
                ctx.stroke(p, with: .color(Ink.ink), lineWidth: 1.3)
                let dx = to.x - from.x, dy = to.y - from.y
                let len = max(1, sqrt(dx * dx + dy * dy))
                let ux = dx / len, uy = dy / len
                var h = Path()
                h.move(to: to)
                h.addLine(to: CGPoint(x: to.x - ux * 8 + uy * 4, y: to.y - uy * 8 - ux * 4))
                h.move(to: to)
                h.addLine(to: CGPoint(x: to.x - ux * 8 - uy * 4, y: to.y - uy * 8 + ux * 4))
                ctx.stroke(h, with: .color(Ink.ink), lineWidth: 1.3)
            }
            arrow(xy(1, 0), CGPoint(x: xy(1, 0).x + 16, y: xy(1, 0).y))
            arrow(xy(1, 1), CGPoint(x: xy(1, 1).x + 16, y: xy(1, 1).y))
            arrow(xy(0, 1), CGPoint(x: xy(0, 1).x - 16, y: xy(0, 1).y))
            arrow(xy(0, 0), CGPoint(x: xy(0, 0).x, y: xy(0, 0).y - 14))
            arrow(xy(0, 1), CGPoint(x: xy(0, 1).x, y: xy(0, 1).y + 14))
            arrow(xy(1, 0), CGPoint(x: xy(1, 0).x, y: xy(1, 0).y - 14))
            arrow(xy(1, 1), CGPoint(x: xy(1, 1).x, y: xy(1, 1).y + 14))

            func gep(_ u: CGFloat, _ v: CGFloat, _ s: String) {
                let p = xy(u, v)
                var oval = Path()
                oval.addEllipse(in: CGRect(x: p.x - 9, y: p.y - 6, width: 18, height: 12))
                ctx.stroke(oval, with: .color(Ink.ink), lineWidth: 1.3)
                ctx.draw(Text(s).font(.placa(11, weight: .bold)), at: CGPoint(x: p.x + 14, y: p.y))
            }
            gep(0.16, 0.16, "+")
            gep(0.16, 0.07, "-")
            gep(0.84, 0.16, "-")
            gep(0.16, 0.84, "+")
            gep(0.84, 0.84, "+")

            let t0 = CGPoint(x: 18, y: o.y + 10)
            var bdot = Path()
            bdot.addEllipse(in: CGRect(x: t0.x - 6, y: t0.y - 6, width: 12, height: 12))
            ctx.stroke(bdot, with: .color(Ink.ink), lineWidth: 1.2)
            ctx.fill(Path(ellipseIn: CGRect(x: t0.x - 1.6, y: t0.y - 1.6, width: 3.2, height: 3.2)), with: .color(Ink.ink))
            ctx.draw(Text("a").font(.placa(11, weight: .bold)), at: CGPoint(x: t0.x - 14, y: t0.y))
            var bb = Path(); bb.move(to: t0); bb.addLine(to: CGPoint(x: t0.x + 22, y: t0.y))
            ctx.stroke(bb, with: .color(Ink.ink), lineWidth: 1.2)
            ctx.draw(Text("b").font(.placa(11, weight: .bold)), at: CGPoint(x: t0.x + 30, y: t0.y))
            var cc = Path(); cc.move(to: t0); cc.addLine(to: CGPoint(x: t0.x, y: t0.y + 22))
            ctx.stroke(cc, with: .color(Ink.ink), lineWidth: 1.2)
            ctx.draw(Text("c").font(.placa(11, weight: .bold)), at: CGPoint(x: t0.x, y: t0.y + 32))

            let lx = o.x + A + 18
            ctx.draw(Text("G.E.P.").font(.placa(12, weight: .bold)), at: CGPoint(x: lx + 24, y: o.y + 8))
            ctx.draw(Text("x y z").font(.placa(11)), at: CGPoint(x: lx + 24, y: o.y + 28))
            ctx.draw(Text("x y- z-").font(.placa(11)), at: CGPoint(x: lx + 28, y: o.y + 46))
            ctx.draw(Text("x- y z-").font(.placa(11)), at: CGPoint(x: lx + 28, y: o.y + 64))
            ctx.draw(Text("x- y- z").font(.placa(11)), at: CGPoint(x: lx + 28, y: o.y + 82))
        }
        .background(Ink.paper)
    }
}

/// P2_1/c (nº 14), pizarra clase 10: unique-b. 2_1 en bordes // c. Glide c a 1/4, 3/4.
/// Los GEP no se apilan (eso es P21/m): el glide los corre 1/2 c. Centro en rojo.
struct P21cCellCanvas: View {
    var body: some View {
        Canvas { ctx, size in
            let g = MonoGeom(size: size, origin: CGPoint(x: 48, y: 30), aScale: 0.40, cScale: 0.52)
            g.strokeCell(ctx)
            g.dashHalf(ctx)
            g.screws(ctx, sites: [
                (0, 0), (0, 0.5), (0, 1),
                (1, 0), (1, 0.5), (1, 1),
            ])
            g.inversion(ctx, at: 0.5, 0.5)
            g.simpleGep(ctx, at: g.xy(0.22, 0.20), text: "+", comma: false)
            g.simpleGep(ctx, at: g.xy(-0.12, 0.42), text: "1/2+", comma: false)
            g.simpleGep(ctx, at: g.xy(0.22, 0.72), text: "1/2-", comma: true)
            g.simpleGep(ctx, at: g.xy(0.72, 0.38), text: "1/2+", comma: false)
            g.simpleGep(ctx, at: g.xy(0.78, 0.82), text: "-", comma: true)
            g.mirrorMark(ctx, heights: "1/4, 3/4")
            g.axisLetters(ctx)
            g.triad(ctx)
            bellowInset(ctx, size: size)
        }
        .background(Ink.paper)
    }

    /// Vista de lado (pizarra): b vertical, glide a 1/4, inversion a 1/2, GEP y y 1/2-y.
    private func bellowInset(_ ctx: GraphicsContext, size: CGSize) {
        let ox = size.width - 108
        let oy = size.height - 118
        let h: CGFloat = 88
        var axes = Path()
        axes.move(to: CGPoint(x: ox, y: oy + h))
        axes.addLine(to: CGPoint(x: ox, y: oy))
        axes.move(to: CGPoint(x: ox, y: oy + h))
        axes.addLine(to: CGPoint(x: ox + 64, y: oy + h))
        ctx.stroke(axes, with: .color(Ink.ink), lineWidth: 1.2)
        ctx.draw(Text("b").font(.placa(10, weight: .bold)), at: CGPoint(x: ox, y: oy - 8))
        ctx.draw(Text("0").font(.placa(9)), at: CGPoint(x: ox - 10, y: oy + h))
        ctx.draw(Text("b/2").font(.placa(9)), at: CGPoint(x: ox - 16, y: oy + 4))

        let y0 = oy + h
        let yHalf = oy + 8
        let y14 = oy + h * 0.75
        ctx.fill(Path(ellipseIn: CGRect(x: ox - 3.5, y: y0 - 3.5, width: 7, height: 7)), with: .color(Ink.improper))
        ctx.fill(Path(ellipseIn: CGRect(x: ox - 3.5, y: yHalf - 3.5, width: 7, height: 7)), with: .color(Ink.improper))

        var glide = Path()
        glide.move(to: CGPoint(x: ox + 4, y: y14))
        glide.addLine(to: CGPoint(x: ox + 70, y: y14))
        ctx.stroke(glide, with: .color(Ink.improper), style: StrokeStyle(lineWidth: 1.1, dash: [3, 3]))
        ctx.draw(Text("1/4").font(.placa(9, weight: .bold)).foregroundColor(Ink.improper), at: CGPoint(x: ox + 82, y: y14))

        var oval0 = Path()
        oval0.addEllipse(in: CGRect(x: ox + 10, y: y0 - 16, width: 18, height: 12))
        ctx.stroke(oval0, with: .color(Ink.ink), lineWidth: 1.1)
        ctx.draw(Text("y +").font(.placa(9)), at: CGPoint(x: ox + 48, y: y0 - 10))
        var comma = Path()
        comma.addEllipse(in: CGRect(x: ox + 8, y: y0 - 6, width: 4, height: 6))
        ctx.fill(comma, with: .color(Ink.ink))

        var ovalH = Path()
        ovalH.addEllipse(in: CGRect(x: ox + 10, y: yHalf + 4, width: 18, height: 12))
        ctx.stroke(ovalH, with: .color(Ink.ink), lineWidth: 1.1)
        ctx.draw(Text("1/2-y").font(.placa(9)), at: CGPoint(x: ox + 54, y: yHalf + 10))

        var arr = Path()
        arr.move(to: CGPoint(x: ox + 58, y: y0 - 20))
        arr.addLine(to: CGPoint(x: ox + 58, y: yHalf + 18))
        ctx.stroke(arr, with: .color(Ink.ink), lineWidth: 1.0)
        ctx.draw(Text("21").font(.placa(9, weight: .bold)), at: CGPoint(x: ox + 72, y: (y0 + yHalf) / 2))
    }
}

/// P222_1 (nº 17), pizarra clase 11: se mira a lo largo de c. 2_1 // c; 2 // a y 2 // b a z = 1/4.
struct P2221CellCanvas: View {
    var body: some View {
        Canvas { ctx, size in
            let pad: CGFloat = 26
            let o = CGPoint(x: pad + 36, y: pad + 10)
            let B: CGFloat = size.width * 0.58
            let A: CGFloat = size.height * 0.52
            func xy(_ u: CGFloat, _ v: CGFloat) -> CGPoint {
                CGPoint(x: o.x + u * B, y: o.y + v * A)
            }
            var cell = Path()
            cell.addRect(CGRect(x: o.x, y: o.y, width: B, height: A))
            ctx.stroke(cell, with: .color(Ink.ink), lineWidth: 2)

            func screw(at p: CGPoint) {
                let r: CGFloat = 6
                var loz = Path()
                loz.addEllipse(in: CGRect(x: p.x - r * 0.4, y: p.y - r, width: r * 0.8, height: r * 2))
                ctx.fill(loz, with: .color(Ink.ink))
                var tail = Path()
                tail.move(to: CGPoint(x: p.x + r * 0.15, y: p.y + r * 0.15))
                tail.addLine(to: CGPoint(x: p.x + r * 1.15, y: p.y + r * 0.95))
                ctx.stroke(tail, with: .color(Ink.ink), lineWidth: 1.3)
            }
            let screws: [(CGFloat, CGFloat)] = [
                (0, 0), (1, 0), (0, 1), (1, 1),
                (0.5, 0), (0.5, 1), (0, 0.5), (1, 0.5), (0.5, 0.5),
            ]
            for s in screws { screw(at: xy(s.0, s.1)) }

            func arrow(_ from: CGPoint, _ to: CGPoint) {
                var p = Path()
                p.move(to: from); p.addLine(to: to)
                ctx.stroke(p, with: .color(Ink.ink), lineWidth: 1.3)
                let dx = to.x - from.x, dy = to.y - from.y
                let len = max(1, sqrt(dx * dx + dy * dy))
                let ux = dx / len, uy = dy / len
                var h = Path()
                h.move(to: to)
                h.addLine(to: CGPoint(x: to.x - ux * 8 + uy * 4, y: to.y - uy * 8 - ux * 4))
                h.move(to: to)
                h.addLine(to: CGPoint(x: to.x - ux * 8 - uy * 4, y: to.y - uy * 8 + ux * 4))
                ctx.stroke(h, with: .color(Ink.ink), lineWidth: 1.3)
            }
            arrow(xy(1, 0), CGPoint(x: xy(1, 0).x + 18, y: xy(1, 0).y))
            arrow(xy(1, 1), CGPoint(x: xy(1, 1).x + 18, y: xy(1, 1).y))
            arrow(xy(0, 1), CGPoint(x: xy(0, 1).x - 16, y: xy(0, 1).y))
            arrow(xy(0, 0), CGPoint(x: xy(0, 0).x, y: xy(0, 0).y - 12))
            arrow(xy(0, 1), CGPoint(x: xy(0, 1).x, y: xy(0, 1).y + 12))
            arrow(xy(1, 0), CGPoint(x: xy(1, 0).x, y: xy(1, 0).y - 12))
            arrow(xy(1, 1), CGPoint(x: xy(1, 1).x, y: xy(1, 1).y + 12))
            ctx.draw(Text("1/4").font(.placa(11, weight: .bold)), at: CGPoint(x: xy(1, 0).x + 32, y: xy(1, 0).y))
            ctx.draw(Text("1/4").font(.placa(11, weight: .bold)), at: CGPoint(x: xy(1, 1).x + 32, y: xy(1, 1).y))

            func gep(_ u: CGFloat, _ v: CGFloat, _ s: String) {
                let p = xy(u, v)
                var oval = Path()
                oval.addEllipse(in: CGRect(x: p.x - 9, y: p.y - 6, width: 18, height: 12))
                ctx.stroke(oval, with: .color(Ink.ink), lineWidth: 1.3)
                ctx.draw(Text(s).font(.placa(10, weight: .bold)), at: CGPoint(x: p.x + 16, y: p.y))
            }
            gep(0.14, 0.14, "+")
            gep(0.14, 0.04, "1/2-")
            gep(-0.08, 0.10, "1/2+")
            gep(0.78, 0.10, "1/2+")
            gep(0.72, 0.22, "-")
            gep(0.14, 0.86, "1/2+")
            gep(0.28, 0.90, "1/2-")
            gep(0.78, 0.86, "1/2+")

            let t0 = CGPoint(x: 16, y: o.y + 8)
            var cdot = Path()
            cdot.addEllipse(in: CGRect(x: t0.x - 6, y: t0.y - 6, width: 12, height: 12))
            ctx.stroke(cdot, with: .color(Ink.ink), lineWidth: 1.2)
            ctx.fill(Path(ellipseIn: CGRect(x: t0.x - 1.6, y: t0.y - 1.6, width: 3.2, height: 3.2)), with: .color(Ink.ink))
            ctx.draw(Text("c").font(.placa(11, weight: .bold)), at: CGPoint(x: t0.x - 14, y: t0.y))
            var bb = Path(); bb.move(to: t0); bb.addLine(to: CGPoint(x: t0.x + 22, y: t0.y))
            ctx.stroke(bb, with: .color(Ink.ink), lineWidth: 1.2)
            ctx.draw(Text("b").font(.placa(11, weight: .bold)), at: CGPoint(x: t0.x + 30, y: t0.y))
            var aa = Path(); aa.move(to: t0); aa.addLine(to: CGPoint(x: t0.x, y: t0.y + 20))
            ctx.stroke(aa, with: .color(Ink.ink), lineWidth: 1.2)
            ctx.draw(Text("a").font(.placa(11, weight: .bold)), at: CGPoint(x: t0.x, y: t0.y + 30))
        }
        .background(Ink.paper)
    }
}

/// P2_1 2_1 2_1 (nº 19), pizarra clase 11: se mira a lo largo de c. Ningun 2_1 se corta. Origen en ninguno.
struct P212121CellCanvas: View {
    var body: some View {
        Canvas { ctx, size in
            let g = OrthoC(size: size)
            g.strokeCell(ctx)
            g.dashHalf(ctx)
            g.lookC(ctx)
            // 2_1 // a (baja): corrido 1/4 en b. No pasa por el origen.
            g.screwInPlane(ctx, from: g.xy(0.25, 0.05), to: g.xy(0.25, 0.95))
            g.screwInPlane(ctx, from: g.xy(0.75, 0.05), to: g.xy(0.75, 0.95))
            // 2_1 // b (derecha): a z = 1/4.
            g.screwInPlane(ctx, from: g.xy(0.08, 0.50), to: g.xy(0.92, 0.50))
            // 2_1 // c (sale): corrido 1/4 en a.
            g.screwOut(ctx, at: g.xy(0.00, 0.25))
            g.screwOut(ctx, at: g.xy(1.00, 0.25))
            g.screwOut(ctx, at: g.xy(0.00, 0.75))
            g.screwOut(ctx, at: g.xy(1.00, 0.75))
            g.originDot(ctx)
            g.gep(ctx, 0.14, 0.14, "+")
            g.gep(ctx, -0.06, 0.48, "1/2+")
            g.gep(ctx, 0.48, -0.08, "1/2-")
            g.gep(ctx, 0.72, 0.48, "1/2+")
            g.gep(ctx, 0.42, 0.62, "-")
            g.gep(ctx, 0.55, 0.92, "1/2-")
            g.label14(ctx)
        }
        .background(Ink.paper)
    }
}

/// I222 (nº 23), pizarra clase 12: P222 + (1/2,1/2,1/2). Los 2 se cortan en 000; los 2_1 se cortan en 1/4,1/4,1/4. 8 GEP.
struct I222CellCanvas: View {
    var body: some View {
        Canvas { ctx, size in
            let g = OrthoC(size: size, box: 0.50)
            g.strokeCell(ctx)
            g.dashHalf(ctx)
            g.lookC(ctx)
            let twos: [(CGFloat, CGFloat)] = [
                (0, 0), (1, 0), (0, 1), (1, 1), (0.5, 0), (0.5, 1), (0, 0.5), (1, 0.5),
            ]
            for s in twos { g.twoOut(ctx, at: g.xy(s.0, s.1)) }
            g.arrows(ctx)
            // 2_1 que se cortan en 1/4,1/4,1/4
            g.screwOut(ctx, at: g.xy(0.25, 0.25))
            g.screwOut(ctx, at: g.xy(0.75, 0.25))
            g.screwOut(ctx, at: g.xy(0.25, 0.75))
            g.screwOut(ctx, at: g.xy(0.75, 0.75))
            g.screwInPlane(ctx, from: g.xy(0.25, 0.08), to: g.xy(0.25, 0.92))
            g.screwInPlane(ctx, from: g.xy(0.08, 0.25), to: g.xy(0.92, 0.25))
            ctx.draw(Text("1/4").font(.placa(10, weight: .bold)).foregroundColor(Ink.improper),
                     at: CGPoint(x: g.xy(0.25, 0.25).x - 16, y: g.xy(0.25, 0.25).y + 14))
            // 4 de P222
            g.gep(ctx, -0.08, -0.08, "+")
            g.gep(ctx, 0.14, 0.08, "-")
            g.gep(ctx, -0.08, 0.14, "-")
            g.gep(ctx, 0.86, 0.14, "-")
            g.gep(ctx, 0.12, 0.86, "-")
            g.gep(ctx, 0.86, 0.86, "+")
            // 4 del centramiento I
            g.gep(ctx, 0.18, 0.22, "+")
            g.gep(ctx, 0.38, 0.42, "1/2+")
            g.gep(ctx, 0.58, 0.42, "1/2-")
            g.gep(ctx, 0.38, 0.58, "1/2-")
            g.gep(ctx, 0.58, 0.58, "1/2+")
            g.label14(ctx)
            let lx = g.origin.x + g.B + 10
            ctx.draw(Text("2  en 000").font(.placa(10, weight: .bold)), at: CGPoint(x: lx + 36, y: g.origin.y + 8))
            ctx.draw(Text("21 en 1/4 1/4 1/4").font(.placa(10, weight: .bold)), at: CGPoint(x: lx + 48, y: g.origin.y + 26))
            ctx.draw(Text("8 GEP").font(.placa(11, weight: .bold)), at: CGPoint(x: lx + 24, y: g.origin.y + 48))
        }
        .background(Ink.paper)
    }
}

/// I2_1 2_1 2_1 (nº 24): misma receta I sobre P212121. 2 y 2_1 en a,b,c PERO no se cortan.
struct I212121CellCanvas: View {
    var body: some View {
        Canvas { ctx, size in
            let g = OrthoC(size: size)
            g.strokeCell(ctx)
            g.dashHalf(ctx)
            g.lookC(ctx)
            g.screwInPlane(ctx, from: g.xy(0.25, 0.05), to: g.xy(0.25, 0.95))
            g.screwInPlane(ctx, from: g.xy(0.75, 0.05), to: g.xy(0.75, 0.95))
            g.screwInPlane(ctx, from: g.xy(0.08, 0.50), to: g.xy(0.92, 0.50))
            g.screwOut(ctx, at: g.xy(0.00, 0.25))
            g.screwOut(ctx, at: g.xy(1.00, 0.25))
            g.screwOut(ctx, at: g.xy(0.00, 0.75))
            g.screwOut(ctx, at: g.xy(1.00, 0.75))
            // 2 que aparecen con I: tampoco se cortan (corridos 1/4).
            g.twoOut(ctx, at: g.xy(0.50, 0.25))
            g.twoOut(ctx, at: g.xy(0.50, 0.75))
            g.twoOut(ctx, at: g.xy(0.25, 0.50))
            g.twoOut(ctx, at: g.xy(0.75, 0.50))
            g.originDot(ctx)
            g.gep(ctx, 0.14, 0.14, "+")
            g.gep(ctx, -0.06, 0.48, "1/2+")
            g.gep(ctx, 0.48, -0.08, "1/2-")
            g.gep(ctx, 0.72, 0.48, "1/2+")
            g.gep(ctx, 0.42, 0.62, "-")
            g.gep(ctx, 0.55, 0.92, "1/2-")
            g.gep(ctx, 0.64, 0.14, "1/2+")
            g.gep(ctx, 0.22, 0.78, "1/2-")
            g.label14(ctx)
        }
        .background(Ink.paper)
    }
}

private struct OrthoC {
    var size: CGSize
    var origin: CGPoint
    var B: CGFloat
    var A: CGFloat

    init(size: CGSize, box: CGFloat = 0.54) {
        self.size = size
        origin = CGPoint(x: 44, y: 22)
        B = size.width * box
        A = size.height * 0.58
    }

    func xy(_ u: CGFloat, _ v: CGFloat) -> CGPoint {
        CGPoint(x: origin.x + u * B, y: origin.y + v * A)
    }

    func strokeCell(_ ctx: GraphicsContext) {
        var cell = Path()
        cell.addRect(CGRect(x: origin.x, y: origin.y, width: B, height: A))
        ctx.stroke(cell, with: .color(Ink.ink), lineWidth: 2)
    }

    func dashHalf(_ ctx: GraphicsContext) {
        var p = Path()
        p.move(to: xy(0, 0.5)); p.addLine(to: xy(1, 0.5))
        p.move(to: xy(0.5, 0)); p.addLine(to: xy(0.5, 1))
        ctx.stroke(p, with: .color(Ink.improper.opacity(0.45)), style: StrokeStyle(lineWidth: 1.1, dash: [5, 4]))
    }

    func lookC(_ ctx: GraphicsContext) {
        let t0 = CGPoint(x: 16, y: origin.y + 6)
        var cdot = Path()
        cdot.addEllipse(in: CGRect(x: t0.x - 5.5, y: t0.y - 5.5, width: 11, height: 11))
        ctx.stroke(cdot, with: .color(Ink.ink), lineWidth: 1.15)
        ctx.fill(Path(ellipseIn: CGRect(x: t0.x - 1.5, y: t0.y - 1.5, width: 3, height: 3)), with: .color(Ink.ink))
        ctx.draw(Text("c").font(.placa(10, weight: .bold)), at: CGPoint(x: t0.x - 13, y: t0.y))
        var bb = Path(); bb.move(to: t0); bb.addLine(to: CGPoint(x: t0.x + 18, y: t0.y))
        ctx.stroke(bb, with: .color(Ink.ink), lineWidth: 1.1)
        ctx.draw(Text("b").font(.placa(10, weight: .bold)), at: CGPoint(x: t0.x + 26, y: t0.y))
        var aa = Path(); aa.move(to: t0); aa.addLine(to: CGPoint(x: t0.x, y: t0.y + 16))
        ctx.stroke(aa, with: .color(Ink.ink), lineWidth: 1.1)
        ctx.draw(Text("a").font(.placa(10, weight: .bold)), at: CGPoint(x: t0.x, y: t0.y + 26))
    }

    func twoOut(_ ctx: GraphicsContext, at p: CGPoint) {
        var loz = Path()
        loz.addEllipse(in: CGRect(x: p.x - 3.2, y: p.y - 6.4, width: 6.4, height: 12.8))
        ctx.fill(loz, with: .color(Ink.ink))
    }

    func screwOut(_ ctx: GraphicsContext, at p: CGPoint) {
        twoOut(ctx, at: p)
        var tail = Path()
        tail.move(to: CGPoint(x: p.x + 1.2, y: p.y + 1.2))
        tail.addLine(to: CGPoint(x: p.x + 7.5, y: p.y + 6.2))
        ctx.stroke(tail, with: .color(Ink.ink), lineWidth: 1.25)
    }

    func screwInPlane(_ ctx: GraphicsContext, from: CGPoint, to: CGPoint) {
        var p = Path()
        p.move(to: from); p.addLine(to: to)
        ctx.stroke(p, with: .color(Ink.ink), lineWidth: 1.2)
        let mx = (from.x + to.x) / 2, my = (from.y + to.y) / 2
        let dx = to.x - from.x, dy = to.y - from.y
        let len = max(1, sqrt(dx * dx + dy * dy))
        let ux = dx / len, uy = dy / len
        var hook = Path()
        hook.move(to: CGPoint(x: mx - ux * 6, y: my - uy * 6))
        hook.addLine(to: CGPoint(x: mx + ux * 6 + uy * 5, y: my + uy * 6 - ux * 5))
        ctx.stroke(hook, with: .color(Ink.ink), lineWidth: 1.35)
        var h = Path()
        h.move(to: to)
        h.addLine(to: CGPoint(x: to.x - ux * 7 + uy * 3.5, y: to.y - uy * 7 - ux * 3.5))
        ctx.stroke(h, with: .color(Ink.ink), lineWidth: 1.2)
    }

    func arrows(_ ctx: GraphicsContext) {
        func arrow(_ from: CGPoint, _ to: CGPoint) {
            var p = Path(); p.move(to: from); p.addLine(to: to)
            ctx.stroke(p, with: .color(Ink.ink), lineWidth: 1.2)
            let dx = to.x - from.x, dy = to.y - from.y
            let len = max(1, sqrt(dx * dx + dy * dy))
            let ux = dx / len, uy = dy / len
            var h = Path()
            h.move(to: to)
            h.addLine(to: CGPoint(x: to.x - ux * 7 + uy * 3.5, y: to.y - uy * 7 - ux * 3.5))
            h.move(to: to)
            h.addLine(to: CGPoint(x: to.x - ux * 7 - uy * 3.5, y: to.y - uy * 7 + ux * 3.5))
            ctx.stroke(h, with: .color(Ink.ink), lineWidth: 1.2)
        }
        arrow(xy(1, 0), CGPoint(x: xy(1, 0).x + 14, y: xy(1, 0).y))
        arrow(xy(1, 1), CGPoint(x: xy(1, 1).x + 14, y: xy(1, 1).y))
        arrow(xy(0, 0), CGPoint(x: xy(0, 0).x, y: xy(0, 0).y - 10))
        arrow(xy(0, 1), CGPoint(x: xy(0, 1).x, y: xy(0, 1).y + 10))
        arrow(xy(1, 0), CGPoint(x: xy(1, 0).x, y: xy(1, 0).y - 10))
        arrow(xy(1, 1), CGPoint(x: xy(1, 1).x, y: xy(1, 1).y + 10))
    }

    func originDot(_ ctx: GraphicsContext) {
        ctx.fill(Path(ellipseIn: CGRect(x: xy(0, 0).x - 3.2, y: xy(0, 0).y - 3.2, width: 6.4, height: 6.4)), with: .color(Ink.improper))
    }

    func gep(_ ctx: GraphicsContext, _ u: CGFloat, _ v: CGFloat, _ s: String) {
        let p = xy(u, v)
        var oval = Path()
        oval.addEllipse(in: CGRect(x: p.x - 8, y: p.y - 5.5, width: 16, height: 11))
        ctx.stroke(oval, with: .color(Ink.ink), lineWidth: 1.2)
        ctx.draw(Text(s).font(.placa(9, weight: .bold)), at: CGPoint(x: p.x + 14, y: p.y))
    }

    func label14(_ ctx: GraphicsContext) {
        ctx.draw(Text("1/4").font(.placa(10, weight: .bold)), at: CGPoint(x: xy(1, 0).x + 22, y: xy(1, 0).y))
        ctx.draw(Text("1/4").font(.placa(10, weight: .bold)), at: CGPoint(x: xy(1, 0.5).x + 22, y: xy(1, 0.5).y))
        ctx.draw(Text("1/4").font(.placa(10, weight: .bold)), at: CGPoint(x: xy(1, 1).x + 22, y: xy(1, 1).y))
    }
}

enum SpaceSketch {
    @ViewBuilder
    static func canvas(_ n: Int) -> some View {
        switch n {
        case 3: P2CellCanvas()
        case 6: PmCellCanvas()
        case 9: CcCellCanvas()
        case 10: P2mCellCanvas()
        case 11: P21mCellCanvas()
        case 14: P21cCellCanvas()
        case 16: P222CellCanvas()
        case 17: P2221CellCanvas()
        case 19: P212121CellCanvas()
        case 23: I222CellCanvas()
        case 24: I212121CellCanvas()
        default: EmptyView()
        }
    }

    static func caption(_ n: Int) -> String? {
        switch n {
        case 3:
            return "P2 (pizarra): unique-b. 2 macizos, sin espejo. Dos GEP propios +. Polar."
        case 6:
            return "Pm (pizarra): solo m paralelo al papel (0, 1/2). Un GEP con coma. Polar."
        case 9:
            return "Cc -> m: C-centrada + glide c. Cuatro GEP: +, 1/2+, - (coma), 1/2-."
        case 10:
            return "P2/m: 2 con hueco (= centro). m a 0 y 1/2. GEP partidos +/-. 4 = 4 x 1."
        case 11:
            return "P21/m: 2_1 con pata. Bellow: m a 1/4 y 3/4. GEP 1/2+ y 1/2- apilados."
        case 14:
            return "P21/c: unique-b. 2_1 // b. Glide c a 1/4, 3/4. GEP corridos 1/2 c (no apilados). Centro en rojo."
        case 16:
            return "P222: se mira a lo largo de a. 2//a, 2//b y 2//c se cortan. GEP: xyz, x y- z-, x- y z-, x- y- z."
        case 17:
            return "P2221: se mira a lo largo de c. 2_1 // c. Los 2 // a y // b quedan a z = 1/4. GEP 1/2+ / 1/2-."
        case 19:
            return "P212121: se mira a lo largo de c. Ningun 2_1 se corta (Bellow, 1/4). Origen en ninguno. 4 GEP."
        case 23:
            return "I222 = P222 + (1/2,1/2,1/2). 8 GEP. Los 2 se cortan en 000; los 2_1 se cortan en 1/4,1/4,1/4."
        case 24:
            return "I212121 = P212121 + (1/2,1/2,1/2). Tambien 2 y 2_1 en a,b,c, PERO no se cortan. Esa es la diferencia con I222."
        default:
            return nil
        }
    }
}

private struct MonoGeom {
    var size: CGSize
    var origin: CGPoint
    var a: CGVector
    var c: CGVector

    init(size: CGSize, origin: CGPoint? = nil, aScale: CGFloat = 0.58, cScale: CGFloat = 0.58) {
        self.size = size
        self.origin = origin ?? CGPoint(x: 56, y: 28)
        a = CGVector(dx: size.width * aScale, dy: 0)
        c = CGVector(dx: size.width * 0.14 * (aScale / 0.58), dy: size.height * cScale)
    }

    func xy(_ u: CGFloat, _ v: CGFloat) -> CGPoint {
        CGPoint(x: origin.x + u * a.dx + v * c.dx, y: origin.y + u * a.dy + v * c.dy)
    }

    func strokeCell(_ ctx: GraphicsContext) {
        let p00 = xy(0, 0), p10 = xy(1, 0), p11 = xy(1, 1), p01 = xy(0, 1)
        var cell = Path()
        cell.move(to: p00); cell.addLine(to: p10); cell.addLine(to: p11); cell.addLine(to: p01); cell.closeSubpath()
        ctx.stroke(cell, with: .color(Ink.ink), lineWidth: 2)
    }

    func dashHalf(_ ctx: GraphicsContext) {
        var p = Path()
        p.move(to: xy(0, 0.5)); p.addLine(to: xy(1, 0.5))
        p.move(to: xy(0.5, 0)); p.addLine(to: xy(0.5, 1))
        ctx.stroke(p, with: .color(Ink.improper.opacity(0.45)), style: StrokeStyle(lineWidth: 1.1, dash: [5, 4]))
    }

    func twos(_ ctx: GraphicsContext, hole: Bool) {
        let sites: [(CGFloat, CGFloat)] = [
            (0, 0), (1, 0), (0, 1), (1, 1), (0.5, 0), (0.5, 1), (0, 0.5), (1, 0.5), (0.5, 0.5),
        ]
        for s in sites {
            let p = xy(s.0, s.1)
            let r: CGFloat = (s.0 == 0.5 && s.1 == 0.5) ? 7 : 6
            var loz = Path()
            loz.addEllipse(in: CGRect(x: p.x - r * 0.45, y: p.y - r, width: r * 0.9, height: r * 2))
            ctx.fill(loz, with: .color(Ink.ink))
            if hole {
                var h = Path()
                h.addEllipse(in: CGRect(x: p.x - r * 0.18, y: p.y - r * 0.35, width: r * 0.36, height: r * 0.7))
                ctx.fill(h, with: .color(Ink.paper))
            }
        }
    }

    func inversion(_ ctx: GraphicsContext, at u: CGFloat, _ v: CGFloat) {
        let p = xy(u, v)
        ctx.fill(Path(ellipseIn: CGRect(x: p.x - 3.6, y: p.y - 3.6, width: 7.2, height: 7.2)), with: .color(Ink.improper))
    }

    func screws(_ ctx: GraphicsContext, sites: [(CGFloat, CGFloat)]? = nil) {
        let sites = sites ?? [
            (0, 0), (1, 0), (0, 1), (1, 1), (0.5, 0), (0.5, 1), (0, 0.5), (1, 0.5), (0.5, 0.5),
        ]
        for s in sites {
            let p = xy(s.0, s.1)
            let r: CGFloat = 6
            var loz = Path()
            loz.addEllipse(in: CGRect(x: p.x - r * 0.4, y: p.y - r, width: r * 0.8, height: r * 2))
            ctx.fill(loz, with: .color(Ink.ink))
            var tail = Path()
            tail.move(to: CGPoint(x: p.x + r * 0.15, y: p.y + r * 0.15))
            tail.addLine(to: CGPoint(x: p.x + r * 1.15, y: p.y + r * 0.95))
            ctx.stroke(tail, with: .color(Ink.ink), lineWidth: 1.3)
        }
    }

    func plusGep(_ ctx: GraphicsContext, at p: CGPoint) {
        simpleGep(ctx, at: p, text: "+", comma: false)
    }

    func simpleGep(_ ctx: GraphicsContext, at p: CGPoint, text: String, comma: Bool) {
        var oval = Path()
        oval.addEllipse(in: CGRect(x: p.x - 11, y: p.y - 7, width: 22, height: 14))
        ctx.stroke(oval, with: .color(Ink.ink), lineWidth: 1.3)
        ctx.draw(Text(text).font(.placa(11, weight: .bold)), at: CGPoint(x: p.x + 22, y: p.y))
        if comma {
            var c = Path()
            c.addEllipse(in: CGRect(x: p.x - 5, y: p.y + 4, width: 5, height: 7))
            ctx.fill(c, with: .color(Ink.ink))
        }
    }

    func splitGep(_ ctx: GraphicsContext, at p: CGPoint, plus: String = "+", minus: String = "-", comma: Bool = true) {
        let rx: CGFloat = 16, ry: CGFloat = 8
        var oval = Path()
        oval.addEllipse(in: CGRect(x: p.x - rx, y: p.y - ry, width: rx * 2, height: ry * 2))
        ctx.stroke(oval, with: .color(Ink.ink), lineWidth: 1.4)
        var bar = Path()
        bar.move(to: CGPoint(x: p.x, y: p.y - ry))
        bar.addLine(to: CGPoint(x: p.x, y: p.y + ry))
        ctx.stroke(bar, with: .color(Ink.ink), lineWidth: 1.1)
        if !minus.isEmpty {
            ctx.draw(Text(minus).font(.placa(10, weight: .bold)), at: CGPoint(x: p.x - rx - 12, y: p.y))
        }
        ctx.draw(Text(plus).font(.placa(10, weight: .bold)), at: CGPoint(x: p.x + rx + 14, y: p.y))
        if comma {
            var c = Path()
            c.addEllipse(in: CGRect(x: p.x - 6, y: p.y + ry - 2, width: 5, height: 7))
            ctx.fill(c, with: .color(Ink.ink))
        }
    }

    func mirrorMark(_ ctx: GraphicsContext, heights: String) {
        let p10 = xy(1, 0)
        var mark = Path()
        mark.move(to: CGPoint(x: p10.x + 8, y: p10.y + 16))
        mark.addLine(to: CGPoint(x: p10.x + 8, y: p10.y - 5))
        mark.addLine(to: CGPoint(x: p10.x + 24, y: p10.y - 5))
        ctx.stroke(mark, with: .color(Ink.ink), lineWidth: 1.7)
        ctx.draw(Text(heights).font(.placa(11, weight: .bold)), at: CGPoint(x: p10.x + 40, y: p10.y - 16))
    }

    func axisLetters(_ ctx: GraphicsContext) {
        let p00 = xy(0, 0), p10 = xy(1, 0), p01 = xy(0, 1)
        ctx.draw(Text("a").font(.placa(13, weight: .semibold)), at: CGPoint(x: (p00.x + p10.x) / 2, y: p00.y - 12))
        ctx.draw(Text("c").font(.placa(13, weight: .semibold)), at: CGPoint(x: p00.x - 14, y: (p00.y + p01.y) / 2))
    }

    func triad(_ ctx: GraphicsContext) {
        let t0 = CGPoint(x: 22, y: 18)
        var ax = Path(); ax.move(to: t0); ax.addLine(to: CGPoint(x: t0.x + 22, y: t0.y))
        ctx.stroke(ax, with: .color(Ink.ink), lineWidth: 1.15)
        ctx.draw(Text("a").font(.placa(10, weight: .bold)), at: CGPoint(x: t0.x + 30, y: t0.y))
        var cz = Path(); cz.move(to: t0); cz.addLine(to: CGPoint(x: t0.x + 7, y: t0.y + 16))
        ctx.stroke(cz, with: .color(Ink.ink), lineWidth: 1.15)
        ctx.draw(Text("c").font(.placa(10, weight: .bold)), at: CGPoint(x: t0.x + 8, y: t0.y + 26))
        var bdot = Path(); bdot.addEllipse(in: CGRect(x: t0.x - 5.5, y: t0.y - 5.5, width: 11, height: 11))
        ctx.stroke(bdot, with: .color(Ink.ink), lineWidth: 1.1)
        ctx.fill(Path(ellipseIn: CGRect(x: t0.x - 1.5, y: t0.y - 1.5, width: 3, height: 3)), with: .color(Ink.ink))
        ctx.draw(Text("b").font(.placa(10, weight: .bold)), at: CGPoint(x: t0.x - 14, y: t0.y - 12))
    }
}
