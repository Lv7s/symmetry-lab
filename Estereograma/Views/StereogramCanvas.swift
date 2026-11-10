import SwiftUI
import UIKit

struct StereogramCanvas: UIViewRepresentable {
    var group: PointGroup
    var seed: Vec3
    var highlight: String?
    var onSeedChange: (Vec3) -> Void
    var onHighlight: (String?) -> Void

    func makeUIView(context: Context) -> StereogramUIView {
        let v = StereogramUIView()
        v.backgroundColor = UIColor(Ink.paper)
        v.isMultipleTouchEnabled = false
        v.onSeedChange = onSeedChange
        v.onHighlight = onHighlight
        v.model = (group, seed, highlight)
        return v
    }

    func updateUIView(_ uiView: StereogramUIView, context: Context) {
        uiView.onSeedChange = onSeedChange
        uiView.onHighlight = onHighlight
        uiView.model = (group, seed, highlight)
        uiView.setNeedsDisplay()
    }
}

final class StereogramUIView: UIView {
    var model: (group: PointGroup, seed: Vec3, highlight: String?) = (
        PointGroupCatalog.byId("-6"), PointGroupCatalog.defaultSeed, nil
    )
    var onSeedChange: ((Vec3) -> Void)?
    var onHighlight: ((String?) -> Void)?
    private var dragging = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = true
        contentMode = .redraw
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func layoutGeom() -> (cx: CGFloat, cy: CGFloat, R: CGFloat) {
        let w = bounds.width, h = bounds.height
        return (w / 2, h / 2, min(w, h) * 0.30)
    }

    private var hexNet: Bool { model.group.system.isHexFamily }

    /// Hex/trigonal: crystal +x (a₁) down. Display has vertical diameter, no horizontal X.
    private func orient(_ sx: Double, _ sy: Double) -> (Double, Double) {
        hexNet ? (sy, -sx) : (sx, sy)
    }

    private func toxy(_ sx: Double, _ sy: Double, cx: CGFloat, cy: CGFloat, R: CGFloat) -> CGPoint {
        let o = orient(sx, sy)
        return CGPoint(x: cx + CGFloat(o.0) * R, y: cy - CGFloat(o.1) * R)
    }

    private func pointerToStereo(_ p: CGPoint) -> (sx: Double, sy: Double)? {
        let g = layoutGeom()
        let dsx = Double((p.x - g.cx) / g.R)
        let dsy = Double((g.cy - p.y) / g.R)
        if hexNet { return (-dsy, dsx) }
        return (dsx, dsy)
    }

    @objc private func pan(_ g: UIPanGestureRecognizer) {
        let p = g.location(in: self)
        guard let st = pointerToStereo(p) else { return }
        if g.state == .began || g.state == .changed {
            dragging = true
            let n = hypot(st.sx, st.sy)
            if n <= 1.05 {
                let c = n <= 1 || n < 1e-9 ? st : (st.sx / n, st.sy / n)
                onSeedChange?(seedFromStereoClick(sx: c.0, sy: c.1, upper: true, group: model.group, current: model.seed))
            }
            hit(st)
        } else {
            dragging = false
        }
    }

    @objc private func tap(_ g: UITapGestureRecognizer) {
        guard let st = pointerToStereo(g.location(in: self)) else { return }
        hit(st)
    }

    private func hit(_ st: (sx: Double, sy: Double)) {
        if st.sx * st.sx + st.sy * st.sy > 1.2 {
            onHighlight?(nil)
            return
        }
        let stereo = buildStereo(model.group, seed: model.seed)
        var best: StereoPt?
        var bestD = 0.1
        for p in stereo.points {
            let d = hypot(p.sx - st.sx, p.sy - st.sy)
            if d < bestD {
                bestD = d
                best = p
            }
        }
        onHighlight?(best?.op.xyz)
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let paper = UIColor(Ink.paper)
        let ink = UIColor(Ink.ink)
        let muted = UIColor(Ink.muted)
        paper.setFill()
        ctx.fill(bounds)

        let g = layoutGeom()
        let cx = g.cx, cy = g.cy, R = g.R
        let stereo = buildStereo(model.group, seed: model.seed)
        let hasMh = stereo.mirrors.contains { $0.kind == .horizontal }
        // Pizarra 2/m (clase 3): mh = círculo más grueso, no orla/haz.
        // 6̄: círculo fino; el mh se lee en el GEP partido +/−.

        ctx.setStrokeColor(ink.cgColor)
        let lw: CGFloat
        if hasMh && model.group.id != "-6" { lw = max(4.0, R * 0.022) }
        else { lw = max(1.45, R * 0.008) }
        ctx.setLineWidth(lw)
        ctx.strokeEllipse(in: CGRect(x: cx - R, y: cy - R, width: R * 2, height: R * 2))

        if hexNet {
            ctx.setStrokeColor(muted.cgColor)
            ctx.setLineWidth(max(1.05, R * 0.0065))
            for k in 0..<3 {
                let az = Double(k) * .pi / 3
                let a = toxy(cos(az), sin(az), cx: cx, cy: cy, R: R)
                let b = toxy(-cos(az), -sin(az), cx: cx, cy: cy, R: R)
                ctx.move(to: a)
                ctx.addLine(to: b)
                ctx.strokePath()
            }
        } else if model.group.system == .cubico {
            ctx.setStrokeColor(muted.cgColor)
            ctx.setLineWidth(max(1.0, R * 0.0055))
            for k in 0..<4 {
                let az = Double(k) * .pi / 4
                let a = toxy(cos(az), sin(az), cx: cx, cy: cy, R: R)
                let b = toxy(-cos(az), -sin(az), cx: cx, cy: cy, R: R)
                ctx.move(to: a)
                ctx.addLine(to: b)
                ctx.strokePath()
            }
        } else {
            ctx.setStrokeColor(muted.cgColor)
            ctx.setLineWidth(1.2)
            ctx.setLineDash(phase: 0, lengths: [4, 5])
            ctx.move(to: CGPoint(x: cx - R - 4, y: cy))
            ctx.addLine(to: CGPoint(x: cx + R + 4, y: cy))
            ctx.move(to: CGPoint(x: cx, y: cy - R - 4))
            ctx.addLine(to: CGPoint(x: cx, y: cy + R + 4))
            ctx.strokePath()
            ctx.setLineDash(phase: 0, lengths: [])
        }

        ctx.setStrokeColor(ink.cgColor)
        ctx.setLineWidth(max(2.4, R * 0.014))
        for m in stereo.mirrors where m.kind == .vertical {
            let c = cos(m.azimuth), s = sin(m.azimuth)
            let a = toxy(c, s, cx: cx, cy: cy, R: R)
            let b = toxy(-c, -s, cx: cx, cy: cy, R: R)
            ctx.move(to: a)
            ctx.addLine(to: b)
            ctx.strokePath()
        }

        let principal = stereo.axes.first { $0.radial < 0.08 }
        if stereo.inversion && principal == nil {
            ctx.setLineWidth(1.3)
            let r = max(5, R * 0.028)
            ctx.strokeEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        }
        if let p = principal {
            drawAxis(ctx, at: CGPoint(x: cx, y: cy), axis: p, ink: ink, size: max(12, R * 0.07), origin: nil)
        }
        for a in stereo.axes where a.radial >= 0.08 {
            let rr = min(1, a.radial)
            let pt = toxy(cos(a.azimuth) * rr, sin(a.azimuth) * rr, cx: cx, cy: cy, R: R)
            drawAxis(ctx, at: pt, axis: a, ink: ink, size: max(7, R * 0.042), origin: CGPoint(x: cx, y: cy))
        }
        if model.group.id == "2" {
            // Pizarra clase 3: el 2 en y es el diámetro vertical, no un rombo al centro.
            let a = toxy(0, 1, cx: cx, cy: cy, R: R)
            let b = toxy(0, -1, cx: cx, cy: cy, R: R)
            ctx.setStrokeColor(ink.cgColor)
            ctx.setLineWidth(max(2.4, R * 0.014))
            ctx.move(to: a)
            ctx.addLine(to: b)
            ctx.strokePath()
        }

        let markR = max(11, R * 0.055)
        for cl in clusterPoints(stereo.points) {
            let sx = cl.map(\.sx).reduce(0, +) / Double(cl.count)
            let sy = cl.map(\.sy).reduce(0, +) / Double(cl.count)
            let pt = toxy(sx, sy, cx: cx, cy: cy, R: R)
            let active = cl.contains { $0.op.xyz == model.highlight }
            drawCluster(ctx, at: pt, cluster: cl, active: active, r: markR, ink: ink)
        }

        drawRefFrame(ctx, cx: cx, cy: cy, R: R, ink: ink, muted: muted)
    }

    private func drawAxis(_ ctx: CGContext, at p: CGPoint, axis: AxisEl, ink: UIColor, size: CGFloat, origin: CGPoint?) {
        ctx.saveGState()
        ctx.translateBy(x: p.x, y: p.y)
        if axis.order == 2, let o = origin {
            ctx.rotate(by: atan2(p.y - o.y, p.x - o.x))
        }
        ink.setFill()
        ink.setStroke()
        ctx.setLineWidth(1.45)
        if axis.order == 2 {
            ctx.fillEllipse(in: CGRect(x: -size * 0.42, y: -size * 0.88, width: size * 0.84, height: size * 1.76))
            ctx.restoreGState()
            return
        }
        if axis.order == 6 && axis.bar {
            // Clase 4: 6̄ = hexágono con triángulo lleno.
            polygon(ctx, r: size * 1.12, n: 6, rot: .pi / 6)
            ctx.strokePath()
            polygon(ctx, r: size * 0.62, n: 3, rot: -.pi / 2)
            ctx.fillPath()
            ctx.restoreGState()
            return
        }
        if axis.order == 4 && axis.bar {
            polygon(ctx, r: size * 1.05, n: 4, rot: .pi / 4)
            ctx.strokePath()
            ctx.fillEllipse(in: CGRect(x: -size * 0.42, y: -size * 0.2, width: size * 0.84, height: size * 0.4))
            ctx.restoreGState()
            return
        }
        if axis.order == 3 && axis.bar {
            polygon(ctx, r: size, n: 3, rot: -.pi / 2)
            ctx.fillPath()
            let r = size * 0.34
            UIColor(Ink.paper).setFill()
            ctx.fillEllipse(in: CGRect(x: -r, y: -r, width: r * 2, height: r * 2))
            ink.setStroke()
            ctx.setLineWidth(1.1)
            ctx.strokeEllipse(in: CGRect(x: -r, y: -r, width: r * 2, height: r * 2))
            ctx.restoreGState()
            return
        }
        let n = axis.order == 6 ? 6 : axis.order == 4 ? 4 : 3
        let rot: CGFloat = n == 4 ? .pi / 4 : -.pi / 2
        polygon(ctx, r: size, n: n, rot: rot)
        ctx.fillPath()
        ctx.restoreGState()
    }

    private func polygon(_ ctx: CGContext, r: CGFloat, n: Int, rot: CGFloat) {
        ctx.beginPath()
        for i in 0..<n {
            let a = rot + CGFloat(i) * 2 * .pi / CGFloat(n)
            let pt = CGPoint(x: cos(a) * r, y: sin(a) * r)
            if i == 0 { ctx.move(to: pt) } else { ctx.addLine(to: pt) }
        }
        ctx.closePath()
    }

    private func drawCluster(_ ctx: CGContext, at p: CGPoint, cluster: [StereoPt], active: Bool, r: CGFloat, ink: UIColor) {
        var marks: [(proper: Bool, upper: Bool)] = []
        if cluster.contains(where: { $0.op.proper && $0.upper }) { marks.append((true, true)) }
        if cluster.contains(where: { !$0.op.proper && $0.upper }) { marks.append((false, true)) }
        if cluster.contains(where: { $0.op.proper && !$0.upper }) { marks.append((true, false)) }
        if cluster.contains(where: { !$0.op.proper && !$0.upper }) { marks.append((false, false)) }

        if active {
            UIColor(Ink.improper).withAlphaComponent(0.10).setFill()
            ctx.fillEllipse(in: CGRect(x: p.x - r - 9, y: p.y - r - 9, width: (r + 9) * 2, height: (r + 9) * 2))
        }
        let up = marks.first { $0.upper }
        let lo = marks.first { !$0.upper }
        if marks.count == 2, let up, let lo {
            drawSplit(ctx, at: p, r: r * 1.08, left: up, right: lo, active: active, ink: ink)
            return
        }
        if marks.count == 1, let m = marks.first {
            drawSingle(ctx, at: p, r: r, proper: m.proper, upper: m.upper, active: active, ink: ink)
            return
        }
        for (i, m) in marks.enumerated() {
            let dx: CGFloat = (i % 2 == 0 ? -1 : 1) * r * 1.1
            let dy: CGFloat = i < 2 ? -r * 0.9 : r * 0.9
            drawSingle(ctx, at: CGPoint(x: p.x + dx, y: p.y + dy), r: r * 0.8, proper: m.proper, upper: m.upper, active: active, ink: ink)
        }
    }

    private func drawSingle(_ ctx: CGContext, at p: CGPoint, r: CGFloat, proper: Bool, upper: Bool, active: Bool, ink: UIColor) {
        ink.setStroke()
        ctx.setLineWidth(active ? 2.2 : 1.7)
        ctx.strokeEllipse(in: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2))
        if !proper { drawComma(ctx, at: p, r: r, fill: UIColor(Ink.improper)) }
        drawSign(upper ? "+" : "−", at: CGPoint(x: p.x + r + 7, y: p.y), r: r, ink: ink)
    }

    private func drawSplit(_ ctx: CGContext, at p: CGPoint, r: CGFloat, left: (proper: Bool, upper: Bool), right: (proper: Bool, upper: Bool), active: Bool, ink: UIColor) {
        let rx = r * 1.45, ry = r * 0.72
        ink.setStroke()
        ctx.setLineWidth(active ? 2.1 : 1.65)
        ctx.strokeEllipse(in: CGRect(x: p.x - rx, y: p.y - ry, width: rx * 2, height: ry * 2))
        ctx.setLineWidth(1.25)
        ctx.move(to: CGPoint(x: p.x, y: p.y - ry))
        ctx.addLine(to: CGPoint(x: p.x, y: p.y + ry))
        ctx.strokePath()
        if !left.proper { drawComma(ctx, at: CGPoint(x: p.x - rx * 0.35, y: p.y + ry * 0.85), r: r, fill: ink) }
        if !right.proper { drawComma(ctx, at: CGPoint(x: p.x + rx * 0.35, y: p.y + ry * 0.85), r: r, fill: ink) }
        drawSign(left.upper ? "+" : "−", at: CGPoint(x: p.x - rx - 8, y: p.y), r: r, ink: ink)
        drawSign(right.upper ? "+" : "−", at: CGPoint(x: p.x + rx + 8, y: p.y), r: r, ink: ink)
    }

    private func drawComma(_ ctx: CGContext, at p: CGPoint, r: CGFloat, fill: UIColor) {
        fill.setFill()
        let cr = r * 0.14
        ctx.fillEllipse(in: CGRect(x: p.x - cr, y: p.y - cr, width: cr * 2, height: cr * 2))
        ctx.beginPath()
        ctx.move(to: CGPoint(x: p.x + r * 0.06, y: p.y + r * 0.04))
        ctx.addQuadCurve(to: CGPoint(x: p.x, y: p.y + r * 0.42), control: CGPoint(x: p.x + r * 0.16, y: p.y + r * 0.28))
        ctx.addQuadCurve(to: CGPoint(x: p.x - r * 0.1, y: p.y + r * 0.04), control: CGPoint(x: p.x - r * 0.16, y: p.y + r * 0.22))
        ctx.addQuadCurve(to: CGPoint(x: p.x + r * 0.06, y: p.y + r * 0.04), control: CGPoint(x: p.x + r * 0.02, y: p.y + r * 0.16))
        ctx.fillPath()
    }

    private func drawSign(_ s: String, at p: CGPoint, r: CGFloat, ink: UIColor) {
        let font = UIFont.systemFont(ofSize: max(10, r * 0.8), weight: .bold)
        let attr: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: ink]
        let size = (s as NSString).size(withAttributes: attr)
        (s as NSString).draw(at: CGPoint(x: p.x - size.width / 2, y: p.y - size.height / 2), withAttributes: attr)
    }

    private func drawRefFrame(_ ctx: CGContext, cx: CGFloat, cy: CGFloat, R: CGFloat, ink: UIColor, muted: UIColor) {
        let fs = max(14, R * 0.075)
        if model.group.view == .y {
            rimLabel("X", at: toxy(1, 0, cx: cx, cy: cy, R: R), from: CGPoint(x: cx, y: cy), R: R, ink: ink, fs: fs)
            rimLabel("Z", at: toxy(0, -1, cx: cx, cy: cy, R: R), from: CGPoint(x: cx, y: cy), R: R, ink: ink, fs: fs)
            halo("Y", at: CGPoint(x: cx, y: cy + max(20, R * 0.13)), fs: fs, color: ink)
            return
        }
        if hexNet {
            rimLabel("Y", at: toxy(-1, 0, cx: cx, cy: cy, R: R), from: CGPoint(x: cx, y: cy), R: R, ink: ink, fs: fs)
            halo("a₁", at: CGPoint(x: cx, y: cy + R + max(14, R * 0.1)), fs: fs * 0.7, color: muted)
            let a2 = toxy(cos(2 * Double.pi / 3), sin(2 * Double.pi / 3), cx: cx, cy: cy, R: R)
            let a3 = toxy(cos(4 * Double.pi / 3), sin(4 * Double.pi / 3), cx: cx, cy: cy, R: R)
            halo("a₂", at: CGPoint(x: a2.x + 10, y: a2.y - 4), fs: fs * 0.68, color: muted)
            halo("a₃", at: CGPoint(x: a3.x - 10, y: a3.y - 4), fs: fs * 0.68, color: muted)
            halo("Z", at: CGPoint(x: cx, y: cy + max(20, R * 0.13)), fs: fs, color: ink)
            return
        }
        rimLabel("X", at: toxy(1, 0, cx: cx, cy: cy, R: R), from: CGPoint(x: cx, y: cy), R: R, ink: ink, fs: fs)
        rimLabel("Y", at: toxy(0, 1, cx: cx, cy: cy, R: R), from: CGPoint(x: cx, y: cy), R: R, ink: ink, fs: fs)
        halo("Z", at: CGPoint(x: cx, y: cy + max(20, R * 0.13)), fs: fs, color: ink)
    }

    private func rimLabel(_ text: String, at on: CGPoint, from c: CGPoint, R: CGFloat, ink: UIColor, fs: CGFloat) {
        let dx = on.x - c.x, dy = on.y - c.y
        let n = hypot(dx, dy)
        guard n > 1 else { return }
        let ux = dx / n, uy = dy / n
        let a1 = CGPoint(x: c.x + ux * (R + max(20, R * 0.14)), y: c.y + uy * (R + max(20, R * 0.14)))
        ink.setStroke()
        UIGraphicsGetCurrentContext()?.setLineWidth(1.55)
        UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: c.x + ux * (R + 6), y: c.y + uy * (R + 6)))
        UIGraphicsGetCurrentContext()?.addLine(to: a1)
        UIGraphicsGetCurrentContext()?.strokePath()
        halo(text, at: CGPoint(x: a1.x + ux * 8, y: a1.y + uy * 8), fs: fs, color: ink)
    }

    private func halo(_ text: String, at p: CGPoint, fs: CGFloat, color: UIColor) {
        let font = UIFont.systemFont(ofSize: fs, weight: .bold)
        let paper = UIColor(Ink.paper)
        let size = (text as NSString).size(withAttributes: [.font: font])
        let origin = CGPoint(x: p.x - size.width / 2, y: p.y - size.height / 2)
        (text as NSString).draw(at: origin, withAttributes: [
            .font: font,
            .foregroundColor: paper,
            .strokeColor: paper,
            .strokeWidth: -6,
        ])
        (text as NSString).draw(at: origin, withAttributes: [.font: font, .foregroundColor: color])
    }
}
