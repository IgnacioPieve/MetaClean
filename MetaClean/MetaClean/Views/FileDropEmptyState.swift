//
//  FileDropEmptyState.swift
//  MetaClean
//
//  Created by Ignacio Pieve Roiger on 30/10/2025.
//

import SwiftUI

struct FileDropEmptyState: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Drag & Drop Files Here")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Supported formats: JPG, PNG, MP4, PDF")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FileDropEmptyState()
        .frame(width: 600, height: 400)
}

