import SwiftUI

struct WallpaperDetailView: View {
    let wallpaper: Wallpaper
    @Environment(\.dismiss) var dismiss
    @StateObject private var downloadManager = DownloadManager.shared
    @StateObject private var wallpaperManager = WallpaperManager.shared

    private var isDownloaded: Bool {
        downloadManager.isDownloaded(wallpaper: wallpaper)
    }
    
    private var isDownloading: Bool {
        downloadManager.activeDownloads[wallpaper.id] != nil
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            
            // 1. Full-Screen Preview Background
            if let videoURL = WallpaperStore.shared.getFullVideoURL(for: wallpaper) {
                let thumbURL = WallpaperStore.shared.getFullThumbURL(for: wallpaper)
                VideoPreviewPlayer(videoURL: videoURL, thumbURL: thumbURL)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(1.0)
                    .ignoresSafeArea()
            }
            
            // Bottom Info Overlay
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Category Tag
                        Text(wallpaper.category.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(5)
                        
                        Text(wallpaper.title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            labelValue(label: "Format", value: "4K MP4")
                            labelValue(label: "Size", value: "100+ MB")
                            labelValue(label: "License", value: "Wallora Pro")
                        }
                    }
                    
                    Spacer()
                    
                    // Actions
                    HStack(spacing: 12) {
                        // Heart / Save Button
                        Button(action: {
                            // Library logic coming soon
                        }) {
                            Image(systemName: "heart")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
                        // Set / Apply Button
                        Button(action: handleAction) {
                            HStack {
                                if isDownloading {
                                    ProgressView().controlSize(.small).tint(.black)
                                } else {
                                    Image(systemName: isDownloaded ? "checkmark.circle.fill" : "arrow.down.circle.fill")
                                }
                                Text(isDownloaded ? "Apply Wallpaper" : "Set Wallpaper")
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 24)
                            .frame(height: 50)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(25)
                        }
                        .buttonStyle(.plain)
                        .disabled(isDownloading)
                    }
                }
                .padding(40)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                )
            }
            
            // Close Button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.black.opacity(0.5)))
                    .padding(24)
            }
            .buttonStyle(.plain)
        }
        .frame(minWidth: 800, minHeight: 500)
    }
    
    private func labelValue(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 10)).foregroundColor(.white.opacity(0.5))
            Text(value).font(.system(size: 12, weight: .medium)).foregroundColor(.white)
        }
    }
    
    private func handleAction() {
        if isDownloaded {
            wallpaperManager.setWallpaper(url: downloadManager.localURL(for: wallpaper))
        } else {
            Task {
                guard let url = WallpaperStore.shared.getFullVideoURL(for: wallpaper) else { return }
                try? await downloadManager.download(wallpaper, from: url)
            }
        }
    }
}
