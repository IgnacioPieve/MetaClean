//
//  FileStackView.swift
//  MetaClean
//
//  Created by Ignacio Pieve Roiger on 30/10/2025.
//

import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct FileStackView: View {
    let files: [File]
    
    var body: some View {
        ZStack {
            ForEach(Array(files.enumerated()), id: \.element.id) { index, file in
                FilePreviewCard(file: file, index: index)
                    .zIndex(Double(index))
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
        }
        .onDrag {
            return createDraggableFiles()
        }
    }
    
    private func createDraggableFiles() -> NSItemProvider {
        guard !files.isEmpty else { return NSItemProvider() }
        
        // Escribir todos los archivos a una carpeta temporal
        let dragFolder = FileManager.default.temporaryDirectory
            .appendingPathComponent("MetaClean_\(UUID().uuidString)")
        
        try? FileManager.default.createDirectory(at: dragFolder, withIntermediateDirectories: true)
        
        for file in files {
            let fileURL = dragFolder.appendingPathComponent(file.filename)
            try? file.data.write(to: fileURL, options: .atomic)
        }
        
        // Arrastrar la carpeta (funciona sin crashes)
        return NSItemProvider(object: dragFolder as NSURL)
    }
}

