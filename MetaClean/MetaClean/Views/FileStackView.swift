//
//  FileStackView.swift
//  MetaClean
//
//  Created by Ignacio Pieve Roiger on 30/10/2025.
//

import SwiftUI
import AppKit

@MainActor
struct FileStackView: View {
    let files: [File]
    
    var body: some View {
        ZStack {
            ForEach(Array(files.enumerated()), id: \.element.id) { index, file in
                FilePreviewCard(file: file, index: index)
                    .zIndex(Double(index))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onDrag { createDraggableFiles() }
    }
    
    private func createDraggableFiles() -> NSItemProvider {
        let urls = files.compactMap { file -> URL? in
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(file.filename)
            try? file.data.write(to: url, options: .atomic)
            return url
        }
        
        guard let firstURL = urls.first else { return NSItemProvider() }
        
        let itemProvider = NSItemProvider(contentsOf: firstURL) ?? NSItemProvider()
        itemProvider.suggestedName = firstURL.lastPathComponent
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let pasteboard = NSPasteboard(name: .drag)
            pasteboard.clearContents()
            pasteboard.writeObjects(urls.map { $0 as NSURL })
        }
        
        return itemProvider
    }
}

