import Foundation
import SwiftUI
import Combine

@MainActor
final class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    
    @Published var activeDownloads: [String: Double] = [:] // wallpaperId: progress (0..1)
    
    private let downloadsFolder: URL
    
    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        downloadsFolder = appSupport.appendingPathComponent("Wallora/Downloads", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: downloadsFolder, withIntermediateDirectories: true)
    }
    
    func localURL(for wallpaper: Wallpaper) -> URL {
        // Sanitize the filename to avoid spaces/issues or use the ID
        let filename = "\(wallpaper.id).mp4"
        return downloadsFolder.appendingPathComponent(filename)
    }
    
    func isDownloaded(wallpaper: Wallpaper) -> Bool {
        return FileManager.default.fileExists(atPath: localURL(for: wallpaper).path)
    }
    
    func download(_ wallpaper: Wallpaper, from url: URL) async throws -> URL {
        let finalPath = localURL(for: wallpaper)
        
        // Already exists
        if FileManager.default.fileExists(atPath: finalPath.path) {
            return finalPath
        }
        
        activeDownloads[wallpaper.id] = 0.05 // start progress
        
        let (tempURL, _) = try await URLSession.shared.download(from: url)
        
        // Move to final path
        if FileManager.default.fileExists(atPath: finalPath.path) {
            try? FileManager.default.removeItem(at: finalPath)
        }
        
        try FileManager.default.moveItem(at: tempURL, to: finalPath)
        
        activeDownloads[wallpaper.id] = nil
        return finalPath
    }
}
