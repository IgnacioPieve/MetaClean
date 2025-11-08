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
                Text(NSLocalizedString("empty_state.title", comment: "Title for empty state"))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(NSLocalizedString("empty_state.subtitle", comment: "Subtitle showing supported formats"))
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

