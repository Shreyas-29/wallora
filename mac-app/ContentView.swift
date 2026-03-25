import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var wallpaperManager = WallpaperManager.shared

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header
            HStack {
                Text("Wallora")
                    .font(.system(size: 14, weight: .semibold))

                Spacer()

                if wallpaperManager.isWallpaperActive {
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 6, height: 6)
                        .padding(.trailing, 2)
                }

                Menu {
                    Text("Version 1.0")
                    Divider()
                    Button("Quit") {
                        NSApplication.shared.terminate(nil)
                    }
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // MARK: - Content
            VStack(spacing: 12) {
                if let url = wallpaperManager.currentVideoURL {

                    // File Row
                    HStack(spacing: 10) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)

                        Text(url.lastPathComponent)
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer()

                        Button(action: {
                            wallpaperManager.selectVideo()
                        }) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(8)

                    // Single Action Button
                    if wallpaperManager.isWallpaperActive {
                        Button(action: {
                            wallpaperManager.removeWallpaper()
                        }) {
                            Text("Stop Wallpaper")
                                .font(.system(size: 13, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 7)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(Color.primary)
                        .foregroundStyle(Color(nsColor: .windowBackgroundColor))
                        .cornerRadius(8)
                    } else {
                        Button(action: {
                            wallpaperManager.setWallpaper(url: url)
                        }) {
                            Text("Apply Wallpaper")
                                .font(.system(size: 13, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 7)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(Color.primary)
                        .foregroundStyle(Color(nsColor: .windowBackgroundColor))
                        .cornerRadius(8)
                    }

                } else {

                    // Empty State
                    VStack(spacing: 10) {
                        Image(systemName: "film")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)

                        Text("No video selected")
                            .font(.system(size: 13, weight: .medium))

                        // Text("Select an MP4 file to set as your desktop wallpaper.")
                        //     .font(.system(size: 11))
                        //     .foregroundStyle(.secondary)
                        //     .multilineTextAlignment(.center)
                        //     .fixedSize(horizontal: false, vertical: true)

                        Button(action: {
                            wallpaperManager.selectVideo()
                        }) {
                            Text("Upload Video")
                                .font(.system(size: 13, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 7)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(Color.primary)
                        .foregroundStyle(Color(nsColor: .windowBackgroundColor))
                        .cornerRadius(8)
                        .padding(.top, 4)
                    }
                    // .padding(16)
                    // .background(Color.primary.opacity(0.04))
                    // .overlay(
                    //     RoundedRectangle(cornerRadius: 10)
                    //         .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    // )
                    // .cornerRadius(10)
                }
            }
            .padding(16)
        }
        .frame(width: 300)
        .background(VisualEffectView().ignoresSafeArea())
    }
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .popover
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

#Preview {
    ContentView()
}
