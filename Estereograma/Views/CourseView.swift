import SwiftUI

struct CourseView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("16 clases de Richard C. Garratt. El visor practica; el curso explica. Transcrito manda sobre las notas.")
                        .font(.placa(13))
                        .foregroundStyle(Ink.muted)
                        .listRowBackground(Ink.paper)
                }
                ForEach(CourseCatalog.all) { lesson in
                    NavigationLink {
                        LessonDetail(lesson: lesson)
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(lesson.id)")
                                .font(.placa(18, weight: .bold))
                                .foregroundStyle(Ink.improper)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lesson.title)
                                    .font(.placa(16, weight: .semibold))
                                    .foregroundStyle(Ink.ink)
                                Text(lesson.idea)
                                    .font(.placa(13))
                                    .foregroundStyle(Ink.muted)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Ink.paper)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Ink.paper)
            .navigationTitle("Curso")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct LessonDetail: View {
    @EnvironmentObject var model: AppModel
    var lesson: Lesson

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(lesson.title)
                    .font(.placa(26, weight: .bold))
                meta("Idea", lesson.idea)
                meta("Figura clave", lesson.figure)
                meta("Objetivo", lesson.objective)
                meta("Qué mueve el alumno", lesson.studentMoves)
                meta("Error típico", lesson.typicalError)

                HStack(spacing: 8) {
                    if let g = lesson.openGroup {
                        Button("Abrir \(PointGroupCatalog.byId(g).hm) en el visor") {
                            model.openGroup(g)
                        }
                        .buttonStyle(PaperButton())
                    }
                    if let p = lesson.openPlane {
                        Button("Abrir \(p) en Redes") {
                            model.openPlane(p)
                        }
                        .buttonStyle(PaperButton())
                    }
                    if lesson.openTriangle {
                        Button("Abrir laboratorio C3/D3") {
                            model.openTriangle()
                        }
                        .buttonStyle(PaperButton())
                    }
                    if let n = lesson.openSpace {
                        Button("Abrir \(SpaceGroupCatalog.byN(n).hm) en Redes") {
                            model.openSpace(n)
                        }
                        .buttonStyle(PaperButton())
                    }
                }

                Divider().overlay(Ink.line)

                Text(lesson.body)
                    .font(.placa(16))
                    .foregroundStyle(Ink.ink)
                    .lineSpacing(5)
            }
            .padding(18)
        }
        .background(Ink.paper)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func meta(_ k: String, _ v: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(k.uppercased())
                .font(.placa(11, weight: .bold))
                .foregroundStyle(Ink.muted)
            Text(v)
                .font(.placa(15))
        }
    }
}

struct PaperButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.placa(14, weight: .semibold))
            .foregroundStyle(Ink.paper)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Ink.ink.opacity(configuration.isPressed ? 0.7 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
