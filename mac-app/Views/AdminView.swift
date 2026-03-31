import SwiftUI
import AVFoundation

struct AdminView: View {
    @StateObject private var admin = AdminManager.shared
    @State private var selectedVideo: URL?
    @State private var videoTitle: String = ""
    @State private var selectedCategory: String = "Nature"
    @State private var previewThumb: NSImage?
    @State private var showSuccess = false
    
    let categories = ["Nature", "Aesthetic", "Space"]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Admin Publishing Center")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 40) {
                // Drop Area / Preview
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .background(Color.white.opacity(0.03))
                            .frame(width: 320, height: 180)
                        
                        if let thumb = previewThumb {
                            Image(nsImage: thumb)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 320, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "plus.viewfinder")
                                    .font(.system(size: 30))
                                Text("Drop .mp4 here")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        handleDrop(providers: providers)
                        return true
                    }
                    
                    if let video = selectedVideo {
                        Text(video.lastPathComponent)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                }
                
                // Form Area
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Wallpaper Title")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        TextField("e.g. Neon Cityscape", text: $videoTitle)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        Picker("", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { cat in
                                Text(cat).tag(cat)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Button(action: {
                        publish()
                    }) {
                        HStack {
                            if admin.isUploading {
                                ProgressView().controlSize(.small).tint(.black)
                            } else {
                                Image(systemName: "paperplane.fill")
                            }
                            Text(admin.isUploading ? "Publishing..." : "Publish to R2")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(canPublish ? Color.white : Color.white.opacity(0.1))
                        .foregroundColor(canPublish ? .black : .white.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canPublish || admin.isUploading)
                }
                .frame(width: 300)
            }
            
            if showSuccess {
                Text("Successfully published to Cloudflare R2!")
                    .foregroundColor(.green)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding(60)
    }
    
    private var canPublish: Bool {
        selectedVideo != nil && !videoTitle.isEmpty
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        providers.first?.loadItem(forTypeIdentifier: "public.file-url", options: nil) { urlData, _ in
            if let data = urlData as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                DispatchQueue.main.async {
                    self.selectedVideo = url
                    self.videoTitle = url.deletingPathExtension().lastPathComponent
                    generatePreview(from: url)
                }
            }
        }
    }
    
    private func generatePreview(from url: URL) {
        Task {
            do {
                self.previewThumb = try await admin.generateThumbnail(from: url)
            } catch {
                print("Failed preview: \(error)")
            }
        }
    }
    
    private func publish() {
        guard let url = selectedVideo else { return }
        Task {
            do {
                try await admin.publishWallpaper(videoURL: url, title: videoTitle, category: selectedCategory)
                withAnimation { showSuccess = true }
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                withAnimation { showSuccess = false }
            } catch {
                print("Publish error: \(error)")
            }
        }
    }
}
