//
//  MetadataRemovalService.swift
//  MetaClean
//
//  Created by Ignacio Pieve Roiger on 07/11/2025.
//
//  This service removes metadata from images. Ideally it would remove metadata from other file types as well,
//  but I will implement that later (maybe).
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

class MetadataRemovalService {
  static let shared = MetadataRemovalService()

  private let tempDirectory: URL

  private init() {
    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("MetaClean")
    try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    self.tempDirectory = tempDir
  }

  func removeMetadata(from imageURL: URL) -> URL? {
    guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
      let imageType = CGImageSourceGetType(imageSource),
      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    else {
      DispatchQueue.main.async {
        NotificationCenter.default.post(
          name: Notification.Name("ShowToastNotification"),
          object: NSLocalizedString("error.file_processing", comment: "Error message when file cannot be processed"))
      }
      return nil
    }

    let destinationURL = tempDirectory.appendingPathComponent(imageURL.lastPathComponent)

    guard
      let destination = CGImageDestinationCreateWithURL(
        destinationURL as CFURL,
        imageType,
        1,
        nil
      )
    else {
      return nil
    }

    CGImageDestinationAddImage(destination, cgImage, nil)

    return CGImageDestinationFinalize(destination) ? destinationURL : nil
  }
}
