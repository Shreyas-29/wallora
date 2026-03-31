import SwiftUI

struct InfoBlock: View {
    let wallpaper: Wallpaper
    @StateObject private var downloadManager = DownloadManager.shared
    @StateObject private var wallpaperManager = WallpaperManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Category Chip
            Text(wallpaper.category)
                .font(.system(size: 11, weight: .regular, design: .default))
                .tracking(0.5)
                .foregroundColor(Color.white.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial) // macOS Blur backdrop
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.bottom, 12)

            // Title
            Text(wallpaper.title)
                .font(.system(size: 44, weight: .regular)) // Reduced from 60
                .foregroundColor(.white)
                .tracking(-1.5)
                .lineLimit(1) // Force one line
                .minimumScaleFactor(0.8) // Shrink slightly more if needed
                .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
                .padding(.bottom, 12)

            // Meta Line
            HStack(spacing: 6) {
                MetaText(text: wallpaper.resolution ?? "4K")
                MetaSeparator()
                MetaText(text: "3840 × 2160")
                MetaSeparator()
                MetaText(text: wallpaper.size ?? "80 MB")
            }
            .padding(.bottom, 18) 

            // Action Buttons
            HStack(spacing: 12) {
                SetButton(wallpaper: wallpaper)
                SaveButton()
            }
        }
    }
}

struct MetaText: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .regular, design: .rounded))
            .foregroundColor(Color.white.opacity(0.75))
            .tracking(0.2)
    }
}

struct MetaSeparator: View {
    var body: some View {
        Text("·")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color.white.opacity(0.4))
    }
}

struct SetButton: View {
    let wallpaper: Wallpaper
    @State private var hovered = false
    @StateObject private var downloadManager = DownloadManager.shared
    @StateObject private var wallpaperManager = WallpaperManager.shared
    
    private var isDownloaded: Bool {
        downloadManager.isDownloaded(wallpaper: wallpaper)
    }
    
    private var progress: Double? {
        downloadManager.activeDownloads[wallpaper.id]
    }

    var body: some View {
        Button(action: {
            handleAction()
        }) {
            HStack(spacing: 8) {
                if let progress = progress {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.black)
                }
                
                Text(progress != nil ? "Downloading..." : (isDownloaded ? "Apply Wallpaper" : "Set Wallpaper"))
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .tracking(0.1)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(hovered ? Color.white.opacity(0.85) : Color.white)
            .foregroundColor(.black)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(progress != nil)
        .onHover { h in 
            withAnimation(.easeInOut(duration: 0.2)) { hovered = h } 
        }
    }
    
    private func handleAction() {
        if isDownloaded {
            wallpaperManager.setWallpaper(url: downloadManager.localURL(for: wallpaper))
        } else {
            Task {
                guard let url = WallpaperStore.shared.getFullVideoURL(for: wallpaper) else { return }
                do {
                    let _ = try await downloadManager.download(wallpaper, from: url)
                    // We don't automatically set it anymore per user request.
                    // The button will update its text to "Apply Wallpaper" automatically because it checks 'isDownloaded'
                } catch {
                    print("Download failed: \(error)")
                }
            }
        }
    }
}

struct SaveButton: View {
    @State private var hovered = false
    @State private var isSaved = false 

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isSaved.toggle()
            }
        }) {
            ZStack {
                Circle()
                    .fill(hovered ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                    .background(.ultraThinMaterial, in: Circle())
                    
                Image(systemName: isSaved ? "heart.fill" : "heart")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isSaved ? .red : (hovered ? .white : Color.white.opacity(0.8)))
            }
            .frame(width: 38, height: 38)
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.easeInOut(duration: 0.2)) { hovered = h } }
        .focusable(false)
    }
}
