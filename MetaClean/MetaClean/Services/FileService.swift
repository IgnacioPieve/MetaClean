//
//  FileService.swift
//  MetaClean
//
//  Created by Ignacio Pieve Roiger on 08/11/2025.
//
//  This service centralizes all file import/export logic:
//  - Import: drag and drop files into the app and process them
//  - Export: save files via download button or drag and drop out of the app
//

import Foundation
import AppKit
import UniformTypeIdentifiers

class FileService {
    static let shared = FileService()
    
    private init() {}
    
    // MARK: - Import Files (Drag & Drop In)
    
    /// Imports files from drag and drop providers
    /// - Parameters:
    ///   - providers: The NSItemProvider array from the drop
    ///   - completion: Callback with the processed File objects
    func importFiles(from providers: [NSItemProvider], completion: @escaping ([File]) -> Void) {
        var processedFiles: [File] = []
        let group = DispatchGroup()
        let lock = NSLock()
        
        for provider in providers {
            group.enter()
            
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { data, error in
                guard error == nil,
                      let data = data as? Data,
                      let originalURL = URL(dataRepresentation: data, relativeTo: nil) else {
                    group.leave()
                    return
                }
                
                self.processFile(originalURL: originalURL) { file in
                    if let file = file {
                        lock.lock()
                        processedFiles.append(file)
                        lock.unlock()
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(processedFiles)
        }
    }
    
    /// Processes a single file through the MetadataRemovalService
    /// - Parameters:
    ///   - originalURL: The URL of the original file
    ///   - completion: Callback with the File object or nil if processing failed
    private func processFile(originalURL: URL, completion: @escaping (File?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let processedURL = MetadataRemovalService.shared.removeMetadata(from: originalURL) {
                let file = File(
                    originalURL: originalURL,
                    processedURL: processedURL,
                    displayName: originalURL.lastPathComponent
                )
                DispatchQueue.main.async {
                    completion(file)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - Export Files (Download / Drag & Drop Out)
    
    /// Exports files to a destination
    /// - Parameters:
    ///   - urls: Array of file URLs to export
    ///   - targetURL: Optional target directory. If nil, shows native save panel
    ///   - completion: Callback indicating success/failure
    func exportFiles(_ urls: [URL], to targetURL: URL? = nil, completion: ((Bool) -> Void)? = nil) {
        if let targetURL = targetURL {
            // Direct export to target (used for drag and drop out)
            exportToTarget(urls: urls, targetURL: targetURL, completion: completion)
        } else {
            // Show native save panel (used for download button)
            showSavePanel(for: urls, completion: completion)
        }
    }
    
    /// Exports files directly to a target directory
    private func exportToTarget(urls: [URL], targetURL: URL, completion: ((Bool) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            var success = true
            
            for url in urls {
                let destinationURL = targetURL.appendingPathComponent(url.lastPathComponent)
                
                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    try FileManager.default.copyItem(at: url, to: destinationURL)
                } catch {
                    success = false
                }
            }
            
            DispatchQueue.main.async {
                completion?(success)
            }
        }
    }
    
    /// Shows the native macOS save panel for file export
    private func showSavePanel(for urls: [URL], completion: ((Bool) -> Void)?) {
        guard !urls.isEmpty else {
            completion?(false)
            return
        }
        
        DispatchQueue.main.async {
            let savePanel = NSSavePanel()
            
            if urls.count == 1 {
                savePanel.nameFieldStringValue = urls[0].lastPathComponent
                savePanel.message = NSLocalizedString("save_panel.message.single", comment: "Save panel message for single file")
            } else {
                savePanel.message = NSLocalizedString("save_panel.message.multiple", comment: "Save panel message for multiple files")
                savePanel.canCreateDirectories = true
                savePanel.showsTagField = false
            }
            
            savePanel.begin { response in
                guard response == .OK, let selectedURL = savePanel.url else {
                    completion?(false)
                    return
                }
                
                if urls.count == 1 {
                    self.copySingleFile(from: urls[0], to: selectedURL, completion: completion)
                } else {
                    self.exportToTarget(urls: urls, targetURL: selectedURL, completion: completion)
                }
            }
        }
    }
    
    /// Copies a single file to a destination
    private func copySingleFile(from sourceURL: URL, to destinationURL: URL, completion: ((Bool) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                DispatchQueue.main.async {
                    completion?(true)
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(false)
                }
            }
        }
    }
    
    // MARK: - Drag Provider (for Drag & Drop Out)
    
    /// Creates an NSItemProvider for dragging files out of the app
    /// - Parameter urls: The URLs to make draggable
    /// - Returns: An NSItemProvider that can be used in onDrag
    func createDragProvider(for urls: [URL]) -> NSItemProvider {
        if urls.count == 1, let url = urls.first {
            return NSItemProvider(contentsOf: url) ?? NSItemProvider()
        }
        
        let provider = NSItemProvider()
        urls.forEach { url in
            provider.suggestedName = url.lastPathComponent
            _ = provider.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { _, _ in }
        }
        return provider
    }
}

