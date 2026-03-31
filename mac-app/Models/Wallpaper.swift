import Foundation

public struct Wallpaper: Identifiable, Codable, Equatable {
    public let id: String
    public let title: String
    public let category: String
    public let videoPath: String
    public let thumbPath: String
    
    // Non-codable extra info if needed
    public var resolution: String?
    public var size: String?

    enum CodingKeys: String, CodingKey {
        case id, title, category
        case videoPath = "video_path"
        case thumbPath = "thumb_path"
        case resolution, size
    }

    public static func == (lhs: Wallpaper, rhs: Wallpaper) -> Bool {
        lhs.id == rhs.id
    }
}

public struct WallpaperManifest: Codable {
    public let version: Int
    public let config: ManifestConfig
    public let wallpapers: [Wallpaper]
}

public struct ManifestConfig: Codable {
    public let baseURL: String
    
    enum CodingKeys: String, CodingKey {
        case baseURL = "base_url"
    }
}
