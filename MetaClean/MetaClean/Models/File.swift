//
//  File.swift
//  MetaClean
//
//  Created by Ignacio Pieve Roiger on 30/10/2025.
//

import Foundation

struct File: Identifiable {
    let id = UUID()
    let originalURL: URL
    let processedURL: URL
    let displayName: String
}
