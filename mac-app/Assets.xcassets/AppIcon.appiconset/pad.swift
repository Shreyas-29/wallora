import Cocoa

let url = URL(fileURLWithPath: "wallora.png")
guard let nsImage = NSImage(contentsOf: url) else { exit(1) }

let newSize = NSSize(width: 1024, height: 1024)
let newImage = NSImage(size: newSize)

newImage.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .high
let rect = NSRect(x: 102, y: 102, width: 820, height: 820)
nsImage.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)
newImage.unlockFocus()

if let tiff = newImage.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff) {
    let pngData = bitmap.representation(using: .png, properties: [:])
    try! pngData?.write(to: URL(fileURLWithPath: "wallora_padded.png"))
}
