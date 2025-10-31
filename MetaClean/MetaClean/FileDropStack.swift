import SwiftUI
import AppKit
import QuickLookThumbnailing
import UniformTypeIdentifiers


@MainActor
struct FileDropStack: View {
    @State private var files: [File] = []

    private let dropTypes = [
        UTType.fileURL.identifier,
        UTType.image.identifier,
        UTType.movie.identifier,
        UTType.audio.identifier,
        UTType.data.identifier
    ]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6]))
                .background(Color.gray.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            ForEach(Array(files.enumerated()), id: \.element.id) { index, file in
                FilePreviewCard(file: file, index: index)
            }

            if files.isEmpty {
                Text("Drop files here").foregroundStyle(.secondary)
            }
        }
        .frame(width: 360, height: 260)
        .padding()
        .contentShape(Rectangle())
        .onDrop(of: dropTypes, isTargeted: nil) { providers in
            handleDrop(providers); return true
        }
    }
    
    private func handleDrop(_ providers: [NSItemProvider]) {
        for p in providers {
            if p.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                p.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { obj, _ in
                    if let d = obj as? Data, let url = URL(dataRepresentation: d, relativeTo: nil) {
                        Task { await appendFromURL(url) }
                    } else if let url = obj as? URL {
                        Task { await appendFromURL(url) }
                    }
                }
                continue
            }

            if let type = [UTType.image, .movie, .audio, .data]
                .first(where: { p.hasItemConformingToTypeIdentifier($0.identifier) }) {

                p.loadItem(forTypeIdentifier: type.identifier, options: nil) { obj, _ in
                    if let url = obj as? URL, let d = try? Data(contentsOf: url) {
                        Task { await append(File(filename: url.lastPathComponent, data: d)) }
                    } else if let d = obj as? Data {
                        let ext = type.preferredFilenameExtension ?? "bin"
                        Task { await append(File(filename: "dropped.\(ext)", data: d)) }
                    }
                }
            }
        }
    }

    private func appendFromURL(_ url: URL) async {
        if let d = try? Data(contentsOf: url) {
            await append(File(filename: url.lastPathComponent, data: d))
        }
    }

    private func append(_ f: File) async {
        files.append(f)
    }
}

#Preview {
    return FileDropStack()
}
