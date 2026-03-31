import SwiftUI
import AVFoundation

/// A robust Image Cache that saves to the Mac's disk so thumbnails never "black out" when switching tabs.
@MainActor
final class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let cacheFolder: URL
    
    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        cacheFolder = appSupport.appendingPathComponent("Wallora/Cache/Images", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheFolder, withIntermediateDirectories: true)
    }
    
    func getLocalPath(for url: URL) -> URL {
        let filename = url.lastPathComponent.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        return cacheFolder.appendingPathComponent("\(filename).jpg")
    }
    
    func isCached(url: URL) -> Bool {
        FileManager.default.fileExists(atPath: getLocalPath(for: url).path)
    }
}

struct BetterCachedImage: View {
    let url: URL?
    @State private var image: NSImage?
    @State private var isLoading = false

    var body: some View {
        Group {
            if let uiImage = image {
                Image(nsImage: uiImage)
                    .resizable()
            } else {
                ZStack {
                    Color.white.opacity(0.05)
                    if isLoading {
                        ProgressView().controlSize(.small)
                    }
                }
            }
        }
        .onAppear { loadImage() }
    }

    private func loadImage() {
        guard let url = url, image == nil, !isLoading else { return }
        
        let localPath = ImageCacheManager.shared.getLocalPath(for: url)
        
        // 1. Try disk cache
        if let data = try? Data(contentsOf: localPath), let nsImage = NSImage(data: data) {
            self.image = nsImage
            return
        }
        
        // 2. Fetch from network
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let nsImage = NSImage(data: data) {
                try? data.write(to: localPath) // Save to disk
                DispatchQueue.main.async {
                    self.image = nsImage
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

/// A mini player that shows the thumbnail instantly and fades the video in when ready.
struct VideoPreviewPlayer: View {
    let videoURL: URL
    let thumbURL: URL?
    @State private var player: AVQueuePlayer?
    @State private var isReady = false
    
    var body: some View {
        ZStack {
            // Instant Thumbnail so it never looks like it's "spinning"
            if let thumbURL = thumbURL {
                BetterCachedImage(url: thumbURL)
                    .aspectRatio(contentMode: .fill)
            }
            
            // Video Layer (Hidden until ready)
            VideoPlayerView(player: player)
                .opacity(isReady ? 1.0 : 0.0)
                .onAppear {
                    setupPlayer()
                }
                .onDisappear {
                    player?.pause()
                    player = nil
                }
        }
        .animation(.easeInOut(duration: 0.5), value: isReady)
    }
    
    private func setupPlayer() {
        let asset = AVURLAsset(url: videoURL)
        let item = AVPlayerItem(asset: asset)
        
        // Listen for when video is actually ready to show
        let queuePlayer = AVQueuePlayer(playerItem: item)
        queuePlayer.isMuted = true
        queuePlayer.preventsDisplaySleepDuringVideoPlayback = false
        
        // Simple logic to fade in video after it starts playing
        queuePlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { _ in
            if !isReady {
                isReady = true
            }
        }
        
        queuePlayer.play()
        self.player = queuePlayer
    }
}

struct VideoPlayerView: NSViewRepresentable {
    let player: AVPlayer?
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        view.wantsLayer = true
        view.layer = layer
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let layer = nsView.layer as? AVPlayerLayer {
            layer.player = player
            layer.frame = nsView.bounds
        }
    }
}
