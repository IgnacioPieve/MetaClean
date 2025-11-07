//
//  FileManagerView.swift
//  MetaClean
//
//  Created by Ignacio Pieve Roiger on 30/10/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileManagerView: View {
    @State private var files: [File] = []
    
    var body: some View {
        Group {
            if files.isEmpty {
                FileDropEmptyState()
            } else {
                FileListView(files: files)
            }
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            handleDrop(providers: providers)
            return true
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, error in
                guard let data = data as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                
                DispatchQueue.main.async {
                    let newFile = File(
                        originalURL: url,
                        processedURL: url,
                        displayName: url.lastPathComponent
                    )
                    files.append(newFile)
                }
            }
        }
    }
}

#Preview {
    FileManagerView()
}

