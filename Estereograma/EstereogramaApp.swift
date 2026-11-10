import SwiftUI

@main
struct EstereogramaApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .onAppear {
                    let errors = PointGroupCatalog.verify()
                    if !errors.isEmpty {
                        print("Simetría: \(errors.joined(separator: "; "))")
                    }
                }
        }
    }
}

final class AppModel: ObservableObject {
    enum Tab: Hashable {
        case curso, estereograma, redes, triangulo
    }

    @Published var tab: Tab = .curso
    @Published var groupId: String = "-6"
    @Published var planeId: String = "pgg"
    @Published var bravaisId: String = "mP"
    @Published var spaceN: Int = 10
    @Published var seed: Vec3 = PointGroupCatalog.defaultSeed
    @Published var highlightXyz: String?
    @Published var lesson: Int = 1
    @Published var showRed = true
    @Published var showPuntual = true
    @Published var showEspacial = true
    @Published var netMode: NetMode = .plano

    enum NetMode: String, CaseIterable {
        case plano = "2D · 17 planos"
        case bravais = "3D · 14 Bravais"
        case espacial = "230 espaciales"
    }

    var group: PointGroup { PointGroupCatalog.byId(groupId) }

    func openGroup(_ id: String) {
        groupId = id
        tab = .estereograma
    }

    func openSpace(_ n: Int) {
        spaceN = n
        netMode = .espacial
        tab = .redes
    }

    func openPlane(_ id: String) {
        planeId = id
        netMode = .plano
        tab = .redes
    }

    func openTriangle() {
        tab = .triangulo
    }
}
