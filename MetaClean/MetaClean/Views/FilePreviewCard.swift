//
//  FilePreviewCard.swift
//  MetaClean
//
//  Created by Ignacio Pieve Roiger on 30/10/2025.
//

import SwiftUI
import AppKit
import QuickLookThumbnailing

@MainActor
struct FilePreviewCard: View {
    let file: File
    let index: Int
    
    @State private var thumbnail: NSImage?
    @State private var isDragging = false
    
    var body: some View {
        Image(nsImage: thumbnail ?? NSImage())
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 200)
            .cornerRadius(10)
            .shadow(radius: isDragging ? 8 : 3)
            .scaleEffect(isDragging ? 1.05 : 1.0)
            .rotationEffect(.degrees(Double(index) * 4 - 4))
            .offset(x: Double(index) * 6, y: Double(index) * 6)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
            .task {
                await generateThumbnail()
            }
            .onDrag {
                isDragging = true
                return createDraggableItem()
            }
            .onChange(of: isDragging) { _, newValue in
                if newValue {
                    Task {
                        try? await Task.sleep(for: .milliseconds(100))
                        isDragging = false
                    }
                }
            }
    }
    
    private func generateThumbnail() async {
        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(file.id.uuidString)
            .appendingPathExtension(URL(filePath: file.filename).pathExtension)
        
        try? file.data.write(to: tmpURL, options: .atomic)
        
        let request = QLThumbnailGenerator.Request(
            fileAt: tmpURL,
            size: CGSize(width: 600, height: 400),
            scale: 2,
            representationTypes: .all
        )
        
        if let representation = try? await QLThumbnailGenerator.shared.generateBestRepresentation(for: request) {
            thumbnail = NSImage(cgImage: representation.cgImage, size: .zero)
        }
        
        try? FileManager.default.removeItem(at: tmpURL)
    }
    
    private func createDraggableItem() -> NSItemProvider {
        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(file.filename)
        
        try? file.data.write(to: tmpURL, options: .atomic)
        
        let provider = NSItemProvider(object: tmpURL as NSURL)
        return provider
    }
}

#Preview {
    let exampleFile = File(
        filename: "example.jpg",
        data: Data()
    )
    return FilePreviewCard(file: exampleFile, index: 0)
}

