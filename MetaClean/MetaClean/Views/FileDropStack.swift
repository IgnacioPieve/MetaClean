import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct FileDropStack: View {
    @State private var files: [File] = []

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray.opacity(0.4), style: StrokeStyle(lineWidth: 2, dash: [6]))
                .background(Color.gray.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            if files.isEmpty {
                Text("Drop files here").foregroundStyle(.secondary)
            } else {
                FileStackView(files: files)
            }
        }
        .frame(minWidth: 360, maxWidth: .infinity, minHeight: 260, maxHeight: .infinity)
        .padding()
        .contentShape(Rectangle())
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: files.count)
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: nil) { providers in
            handleDrop(providers)
            return true
        }
    }
    
    private func handleDrop(_ providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { obj, _ in
                guard let url = (obj as? Data).flatMap({ URL(dataRepresentation: $0, relativeTo: nil) }) ?? obj as? URL,
                      let data = try? Data(contentsOf: url) else { return }
                
                Task { await append(File(filename: url.lastPathComponent, data: data)) }
            }
        }
    }

    private func append(_ file: File) async {
        let isDuplicate = files.contains {
            $0.filename == file.filename && $0.data.count == file.data.count
        }
        
        guard !isDuplicate else { return }
        
        withAnimation {
            files.append(file)
        }
    }
}

#Preview {
    FileDropStack()
}
