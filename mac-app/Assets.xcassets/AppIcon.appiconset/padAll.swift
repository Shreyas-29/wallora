import Cocoa

let dir = URL(fileURLWithPath: ".")
let fm = FileManager.default
let files = try! fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)

for file in files {
    guard file.pathExtension == "png", file.lastPathComponent != "wallora_padded.png", file.lastPathComponent != "scaled_icon.png" else { continue }
    
    guard let nsImage = NSImage(contentsOf: file) else { continue }
    
    // Get actual pixel size, assuming image size is correct.
    let oldSize = nsImage.size
    
    let newImage = NSImage(size: oldSize)
    newImage.lockFocus()
    NSGraphicsContext.current?.imageInterpolation = .high
    
    // 820/1024 = 0.8
    // padding is 0.1 on all sides
    let scale: CGFloat = 0.8
    let w = oldSize.width * scale
    let h = oldSize.height * scale
    let x = (oldSize.width - w) / 2
    let y = (oldSize.height - h) / 2
    
    let rect = NSRect(x: x, y: y, width: w, height: h)
    nsImage.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)
    newImage.unlockFocus()
    
    if let tiff = newImage.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff) {
        let pngData = bitmap.representation(using: .png, properties: [:])
        try! pngData?.write(to: file)
    }
}
print("Done")
