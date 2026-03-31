import Foundation
import Combine

@MainActor
final class WallpaperStore: ObservableObject {
    static let shared = WallpaperStore()
    
    @Published var wallpapers: [Wallpaper] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let manifestURL = URL(string: "https://pub-0d300580e0414418856e4bbff1672869.r2.dev/wallpapers.json")!
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        fetchManifest()
    }
    
    func fetchManifest() {
        isLoading = true
        
        URLSession.shared.dataTaskPublisher(for: manifestURL)
            .map { $0.data }
            .decode(type: WallpaperManifest.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.error = err
                }
            } receiveValue: { [weak self] manifest in
                self?.wallpapers = manifest.wallpapers
                print("Wallora System: \(manifest.wallpapers.count) wallpapers loaded.")
            }
            .store(in: &cancellables)
    }
    
    func getFullVideoURL(for wallpaper: Wallpaper) -> URL? {
        let basePath = "https://pub-0d300580e0414418856e4bbff1672869.r2.dev"
        let encodedPath = wallpaper.videoPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? wallpaper.videoPath
        return URL(string: "\(basePath)/\(encodedPath)")
    }
    
    func getFullThumbURL(for wallpaper: Wallpaper) -> URL? {
        let basePath = "https://pub-0d300580e0414418856e4bbff1672869.r2.dev"
        let encodedPath = wallpaper.thumbPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? wallpaper.thumbPath
        return URL(string: "\(basePath)/\(encodedPath)")
    }
}
