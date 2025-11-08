//
//  FileListView.swift
//  MetaClean
//
//  Created by Ignacio Pieve Roiger on 30/10/2025.
//

import SwiftUI

struct FileListView: View {
    let files: [File]
    @State private var selectedFileIDs: Set<UUID> = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(files) { file in
                    FileView(
                        file: file,
                        isSelected: selectedFileIDs.contains(file.id),
                        allFiles: files,
                        selectedFileIDs: selectedFileIDs,
                        onToggleSelection: {
                            toggleSelection(for: file.id)
                        }
                    )
                    
                    if file.id != files.last?.id {
                        Divider()
                    }
                }
            }
        }
    }
    
    private func toggleSelection(for fileID: UUID) {
        if selectedFileIDs.contains(fileID) {
            selectedFileIDs.remove(fileID)
        } else {
            selectedFileIDs.insert(fileID)
        }
    }
}

#Preview {
    FileListView(files: [
        File(
            originalURL: URL(fileURLWithPath: "/Users/example/Documents/photo1.jpg"),
            processedURL: URL(fileURLWithPath: "/Users/example/Documents/photo1_cleaned.jpg"),
            displayName: "photo1.jpg"
        ),
        File(
            originalURL: URL(fileURLWithPath: "/Users/example/Documents/video.mp4"),
            processedURL: URL(fileURLWithPath: "/Users/example/Documents/video_cleaned.mp4"),
            displayName: "video.mp4"
        ),
    ])
}

