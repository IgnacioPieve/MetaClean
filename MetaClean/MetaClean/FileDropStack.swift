import SwiftUI
import AppKit
import QuickLookThumbnailing
import UniformTypeIdentifiers


@MainActor
struct FileDropStack: View {
    @State private var files: [File] = []
    @State private var thumbs: [UUID: NSImage] = [:]

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

            ForEach(Array(files.enumerated()), id: \.element.id) { i, f in
                Image(nsImage: thumbs[f.id] ?? NSImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 200)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .rotationEffect(.degrees(Double(i) * 4 - 4))
                    .offset(x: Double(i) * 6, y: Double(i) * 6)
                    .task { await genThumb(for: f) }
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

    private func genThumb(for file: File) async {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent(file.id.uuidString)
            .appendingPathExtension(URL(filePath: file.filename).pathExtension)
        try? file.data.write(to: tmp, options: .atomic)

        let req = QLThumbnailGenerator.Request(
            fileAt: tmp, size: CGSize(width: 600, height: 400),
            scale: 2, representationTypes: .all
        )
        if let rep = try? await QLThumbnailGenerator.shared.generateBestRepresentation(for: req) {
            thumbs[file.id] = NSImage(cgImage: rep.cgImage, size: .zero)
        }
    }
}

#Preview {
    return FileDropStack()
}
