import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        TabView(selection: $model.tab) {
            CourseView()
                .tabItem { Label("Curso", systemImage: "book.closed") }
                .tag(AppModel.Tab.curso)
            StereogramView()
                .tabItem { Label("Estereograma", systemImage: "circle.circle") }
                .tag(AppModel.Tab.estereograma)
            NetsView()
                .tabItem { Label("Redes", systemImage: "grid") }
                .tag(AppModel.Tab.redes)
            TriangleLabView()
                .tabItem { Label("Triángulo", systemImage: "triangle") }
                .tag(AppModel.Tab.triangulo)
        }
        .tint(Ink.ink)
    }
}

#Preview {
    ContentView().environmentObject(AppModel())
}
