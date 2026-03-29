import Foundation

public struct WallpaperTheme: Identifiable, Equatable {
    public let id = UUID()
    public let title: String
    public let category: String
    public let resolution: String
    public let dimensions: String
    public let size: String
    public let imageURL: String
}

public let sampleWallpapers: [WallpaperTheme] = [
    WallpaperTheme(title: "Sea Cliffs", category: "Mountains", resolution: "4K", dimensions: "3840 × 2160", size: "85 MB", imageURL: "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?q=80&w=1600"),
    WallpaperTheme(title: "Anime Twilight", category: "Anime", resolution: "4K", dimensions: "3840 × 2160", size: "42 MB", imageURL: "https://images.unsplash.com/photo-1578632292335-df3abbb0d586?q=80&w=1600"),
    WallpaperTheme(title: "Neon City", category: "Urban", resolution: "4K", dimensions: "3840 × 2160", size: "67 MB", imageURL: "https://images.unsplash.com/photo-1519501025264-65ba15a82390?q=80&w=1600"),
    WallpaperTheme(title: "Deep Space", category: "Space", resolution: "4K", dimensions: "3840 × 2160", size: "91 MB", imageURL: "https://images.unsplash.com/photo-1462331940025-496dfbfc7564?q=80&w=1600"),
    WallpaperTheme(title: "Abstract Fluid", category: "Abstract", resolution: "2K", dimensions: "2560 × 1440", size: "38 MB", imageURL: "https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=1600"),
    WallpaperTheme(title: "Rainy Street", category: "Urban", resolution: "4K", dimensions: "3840 × 2160", size: "54 MB", imageURL: "https://images.unsplash.com/photo-1507608616759-54f48f0af0ee?q=80&w=1600"),
    WallpaperTheme(title: "Dark Forest", category: "Nature", resolution: "4K", dimensions: "3840 × 2160", size: "73 MB", imageURL: "https://images.unsplash.com/photo-1448375240586-882707db888b?q=80&w=1600"),
    WallpaperTheme(title: "Desert Dunes", category: "Nature", resolution: "4K", dimensions: "3840 × 2160", size: "60 MB", imageURL: "https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=1600"),
    WallpaperTheme(title: "Frozen Lake", category: "Nature", resolution: "4K", dimensions: "3840 × 2160", size: "48 MB", imageURL: "https://images.unsplash.com/photo-1516912481808-3406841bd33c?q=80&w=1600"),
    WallpaperTheme(title: "Lava Flow", category: "Abstract", resolution: "2K", dimensions: "2560 × 1440", size: "31 MB", imageURL: "https://images.unsplash.com/photo-1563974318767-a4de8b8b5e83?q=80&w=1600")
]
