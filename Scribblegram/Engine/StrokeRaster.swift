import CoreGraphics
import UIKit

/// A bitmap that finished strokes are drawn into one at a time. It lives as long as the canvas
/// size does, so adding a stroke only costs that stroke, never a redraw of the whole picture.
nonisolated final class StrokeRaster {
    let size: CGSize
    let scale: CGFloat
    private let context: CGContext

    /// Returns nil if the bitmap can't be allocated, e.g. for an empty size.
    init?(size: CGSize, scale: CGFloat) {
        let width = Int((size.width * scale).rounded(.up))
        let height = Int((size.height * scale).rounded(.up))
        guard width > 0, height > 0, let context = CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            // The device's native pixel format, so drawing the snapshot needs no conversion.
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else { return nil }

        // Use UIKit's coordinates: points, with the origin at the top left.
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: scale, y: -scale)
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))

        self.size = size
        self.scale = scale
        self.context = context
    }

    func draw(_ strokes: [Stroke]) {
        for stroke in strokes {
            StrokeRenderer.draw(stroke, in: context)
        }
    }

    /// A snapshot of the bitmap. Core Graphics shares the pixels until the next `draw`,
    /// so taking one is cheap.
    func image() -> UIImage? {
        context.makeImage().map { UIImage(cgImage: $0, scale: scale, orientation: .up) }
    }
}
