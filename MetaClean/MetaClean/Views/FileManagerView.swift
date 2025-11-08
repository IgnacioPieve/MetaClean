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
        FileService.shared.importFiles(from: providers) { newFiles in
            files.append(contentsOf: newFiles)
        }
    }
}

#Preview {
    FileManagerView()
}

