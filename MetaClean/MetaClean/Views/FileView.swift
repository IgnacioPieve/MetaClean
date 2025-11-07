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
            
            Button("Download") {
                downloadFile()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func downloadFile() {
        
    }
}

#Preview {
    FileView(file: File(
        originalURL: URL(fileURLWithPath: "/Users/example/Documents/photo.jpg"),
        processedURL: URL(fileURLWithPath: "/Users/example/Documents/photo_cleaned.jpg"),
        displayName: "photo.jpg"
    ))
}
