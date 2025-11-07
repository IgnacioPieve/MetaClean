//
//  FileListView.swift
//  MetaClean
//
//  Created by Ignacio Pieve Roiger on 30/10/2025.
//

import SwiftUI

struct FileListView: View {
    let files: [File]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(files) { file in
                    FileView(file: file)
                    
                    if file.id != files.last?.id {
                        Divider()
                    }
                }
            }
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

