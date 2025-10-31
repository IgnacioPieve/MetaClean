//
//  ContentView.swift
//  EXIF Remover
//
//  Created by Ignacio Pieve Roiger on 30/10/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            FileDropStack()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
