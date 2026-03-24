import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var wallpaperManager = WallpaperManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "desktopcomputer")
                    .font(.title2)
                    .foregroundStyle(.white)
                Text("Video Wallpaper")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                // Status Indicator
                Circle()
                    .fill(wallpaperManager.isWallpaperActive ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                    .shadow(color: wallpaperManager.isWallpaperActive ? .green.opacity(0.8) : .clear, radius: 4)
            }
            .padding(.top, 4)
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // File Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Video")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Image(systemName: "film")
                        .foregroundStyle(.secondary)
                    
                    Text(wallpaperManager.currentVideoURL?.lastPathComponent ?? "No video selected")
                        .font(.callout)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(wallpaperManager.currentVideoURL != nil ? .primary : .secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        wallpaperManager.selectVideo()
                    }) {
                        Text("Select")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.bordered)
                    .clipShape(Capsule())
                }
                .padding(10)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
            }
            
            // Actions
            HStack(spacing: 12) {
                Button(action: {
                    if let url = wallpaperManager.currentVideoURL {
                        wallpaperManager.setWallpaper(url: url)
                    }
                }) {
                    Label("Apply", systemImage: "play.fill")
                    
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .disabled(wallpaperManager.currentVideoURL == nil || wallpaperManager.isWallpaperActive)
                .tint(.blue)
                
                Button(action: {
                    wallpaperManager.removeWallpaper()
                }) {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.bordered)
                .disabled(!wallpaperManager.isWallpaperActive)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Footer
            HStack {
                Text("v1.0")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(width: 320)
        .background(Color.black.opacity(0.4))
    }
}

#Preview {
    ContentView()
}
