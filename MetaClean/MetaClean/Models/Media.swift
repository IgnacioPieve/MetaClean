//
//  Media.swift
//  EXIF Remover
//
//  Created by Ignacio Pieve Roiger on 30/10/2025.
//

import Foundation

struct File: Identifiable {
    let id = UUID()
    let filename: String
    let data: Data
}
