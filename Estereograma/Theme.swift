import SwiftUI

enum Ink {
    static let paper = Color(red: 0.957, green: 0.933, blue: 0.878)
    static let paperDeep = Color(red: 0.91, green: 0.87, blue: 0.78)
    static let ink = Color(red: 0.110, green: 0.098, blue: 0.082)
    static let muted = Color(red: 0.541, green: 0.514, blue: 0.463)
    static let line = Color(red: 0.824, green: 0.769, blue: 0.675)
    static let improper = Color(red: 0.651, green: 0.239, blue: 0.196)
    static let card = Color(red: 0.98, green: 0.96, blue: 0.92)
}

extension Font {
    static func placa(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}
