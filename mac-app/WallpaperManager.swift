import Cocoa
import AVFoundation
import SwiftUI
internal import Combine

@MainActor
final class WallpaperManager: ObservableObject {
    static let shared = WallpaperManager()
    
    // Published state to update UI
    @Published var isWallpaperActive: Bool = false
    @Published var currentVideoURL: URL?
    
    // Track resources per screen to support multi-monitor
    private struct WallpaperContext {
        let window: NSWindow
        let player: AVQueuePlayer
        let looper: AVPlayerLooper
        let layer: AVPlayerLayer
    }
    
    private var contexts: [WallpaperContext] = []
    
    // Observer for screen changes
    private var screenObserver: AnyCancellable?
    
    private init() {
        // Listen for screen configuration changes (plug/unplug)
        screenObserver = NotificationCenter.default
            .publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.refreshWallpaperOnScreens()
                }
            }
    }
    
    func setWallpaper(url: URL) {
        // 1. Cleanup existing
        removeWallpaper()
        
        self.currentVideoURL = url
        
        // 2. Iterate over ALL connected screens
        for screen in NSScreen.screens {
            setupWallpaperFor(screen: screen, url: url)
        }
        
        self.isWallpaperActive = true
    }
    
    private func setupWallpaperFor(screen: NSScreen, url: URL) {
        // Setup Player
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        let queuePlayer = AVQueuePlayer(playerItem: item)
        queuePlayer.isMuted = true
        queuePlayer.preventsDisplaySleepDuringVideoPlayback = false
        
        let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        
        // Setup Window
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.backgroundColor = .black
        window.hidesOnDeactivate = false
        window.canHide = false
        window.isReleasedWhenClosed = false
        
        // Setup Layer
        let contentView = NSView(frame: screen.frame)
        contentView.wantsLayer = true
        
        let layer = AVPlayerLayer(player: queuePlayer)
        layer.videoGravity = .resizeAspectFill
        layer.frame = contentView.bounds
        layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        
        contentView.layer = layer
        window.contentView = contentView
        
        window.orderBack(nil)
        queuePlayer.play()
        
        let context = WallpaperContext(window: window, player: queuePlayer, looper: looper, layer: layer)
        contexts.append(context)
    }
    
    func removeWallpaper() {
        for context in contexts {
            context.player.pause()
            context.layer.removeFromSuperlayer()
            context.window.close()
        }
        contexts.removeAll()
        
        // Does NOT reset currentVideoURL, so we can re-apply
        isWallpaperActive = false
    }
    
    private func refreshWallpaperOnScreens() {
        guard isWallpaperActive, let url = currentVideoURL else { return }
        setWallpaper(url: url)
    }
    
    func selectVideo() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie, .quickTimeMovie, .mpeg4Movie]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        panel.begin { [weak self] response in
            if response == .OK, let url = panel.url {
                Task { @MainActor in
                    self?.currentVideoURL = url
                    self?.setWallpaper(url: url)
                }
            }
        }
    }
}
