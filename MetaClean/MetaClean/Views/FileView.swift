//
//  FileView.swift
//  MetaClean
//
//  Created by Ignacio Pieve Roiger on 30/10/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileView: View {
    let file: File
    let isSelected: Bool
    let allFiles: [File]
    let selectedFileIDs: Set<UUID>
    let onToggleSelection: () -> Void
    
    @State private var isHovering = false
    
    var selectedFiles: [File] {
        allFiles.filter { selectedFileIDs.contains($0.id) }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(file.displayName)
                    .font(.headline)
                
                Text(file.originalURL.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(NSLocalizedString("action.download", comment: "Download button label")) {
                downloadFiles()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(isSelected ? Color.accentColor.opacity(0.2) : (isHovering ? Color.accentColor.opacity(0.05) : Color.clear))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().modifiers(.command).onEnded {
                onToggleSelection()
            }
        )
        .onDrag {
            let urls = selectedFiles.count > 1 ? selectedFiles.map { $0.processedURL } : [file.processedURL]
            return FileService.shared.createDragProvider(for: urls)
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    private func downloadFiles() {
        let urls = selectedFiles.count > 1 ? selectedFiles.map { $0.processedURL } : [file.processedURL]
        FileService.shared.exportFiles(urls)
    }
}

#Preview {
    let file = File(
        originalURL: URL(fileURLWithPath: "/Users/example/Documents/photo.jpg"),
        processedURL: URL(fileURLWithPath: "/Users/example/Documents/photo_cleaned.jpg"),
        displayName: "photo.jpg"
    )
    
    return FileView(
        file: file,
        isSelected: false,
        allFiles: [file],
        selectedFileIDs: [],
        onToggleSelection: { }
    )
}
