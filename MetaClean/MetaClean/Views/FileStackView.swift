//
//  FileStackView.swift
//  MetaClean
//
//  Created by Ignacio Pieve Roiger on 30/10/2025.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

@MainActor
struct FileStackView: View {
    let files: [File]
    @State private var fileURLs: [URL] = []
    
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
        
        fileURLs.removeAll()
        
        for file in files {
            let fileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(file.filename)
            
            if (try? file.data.write(to: fileURL, options: .atomic)) != nil {
                fileURLs.append(fileURL)
            }
        }
        
        guard !fileURLs.isEmpty else { return NSItemProvider() }
        
        let itemProvider = NSItemProvider(contentsOf: fileURLs.first!)
        itemProvider?.suggestedName = fileURLs.first!.lastPathComponent
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let dragPasteboard = NSPasteboard(name: .drag)
            dragPasteboard.clearContents()
            dragPasteboard.writeObjects(fileURLs.map { $0 as NSURL })
        }
        
        return itemProvider ?? NSItemProvider()
    }
}

