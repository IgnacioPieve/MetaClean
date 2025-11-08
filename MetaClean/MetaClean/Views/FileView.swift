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
    @State private var isHovering = false
    
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
                downloadFile()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(isHovering ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onDrag {
            return NSItemProvider(object: file.processedURL as NSURL)
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    private func downloadFile() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.data]
        let prefix = NSLocalizedString("file.cleaned_prefix", comment: "Prefix for cleaned file names")
        savePanel.nameFieldStringValue = "\(prefix)_\(file.displayName)"
        
        if savePanel.runModal() == .OK, let destinationURL = savePanel.url {
            do {
                try FileManager.default.copyItem(at: file.processedURL, to: destinationURL)
            } catch {
                print("Error saving file: \(error)")
            }
        }
    }
}

#Preview {
    FileView(file: File(
        originalURL: URL(fileURLWithPath: "/Users/example/Documents/photo.jpg"),
        processedURL: URL(fileURLWithPath: "/Users/example/Documents/photo_cleaned.jpg"),
        displayName: "photo.jpg"
    ))
}
