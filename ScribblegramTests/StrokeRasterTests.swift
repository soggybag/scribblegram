import CoreGraphics
import Testing
import UIKit
@testable import Scribblegram

struct StrokeRasterTests {
    @Test func tapDrawsADot() throws {
        let tap = Stroke(points: [CGPoint(x: 10, y: 10)], color: .black, width: 8, opacity: 1)
        let raster = try #require(StrokeRaster(size: CGSize(width: 20, height: 20), scale: 1))
        raster.draw([tap])
        let image = try #require(raster.image())

        #expect(try brightness(of: image, at: CGPoint(x: 10, y: 10)) < 0.1)
        #expect(try brightness(of: image, at: CGPoint(x: 1, y: 1)) > 0.9)
    }

    @Test func laterStrokesKeepEarlierOnes() throws {
        let raster = try #require(StrokeRaster(size: CGSize(width: 40, height: 20), scale: 1))
        raster.draw([Stroke(points: [CGPoint(x: 10, y: 10)], color: .black, width: 8, opacity: 1)])
        let before = try #require(raster.image())
        raster.draw([Stroke(points: [CGPoint(x: 30, y: 10)], color: .black, width: 8, opacity: 1)])
        let after = try #require(raster.image())

        #expect(try brightness(of: after, at: CGPoint(x: 10, y: 10)) < 0.1)
        #expect(try brightness(of: after, at: CGPoint(x: 30, y: 10)) < 0.1)
        // Drawing must not change a snapshot that was already handed to the canvas.
        #expect(try brightness(of: before, at: CGPoint(x: 30, y: 10)) > 0.9)
    }

    @Test func imageIsUprightAtDisplayScale() throws {
        let raster = try #require(StrokeRaster(size: CGSize(width: 20, height: 40), scale: 2))
        raster.draw([Stroke(points: [CGPoint(x: 10, y: 5)], color: .black, width: 6, opacity: 1)])
        let image = try #require(raster.image())

        #expect(image.size == CGSize(width: 20, height: 40))
        // Pixel coordinates: the dot is near the top, so a flipped image would put it at the bottom.
        #expect(try brightness(of: image, at: CGPoint(x: 20, y: 10)) < 0.1)
        #expect(try brightness(of: image, at: CGPoint(x: 20, y: 70)) > 0.9)
    }

    /// Average of the RGB channels at a point, from 0 (black) to 1 (white).
    private func brightness(of image: UIImage, at point: CGPoint) throws -> Double {
        let cgImage = try #require(image.cgImage)
        var pixel = [UInt8](repeating: 0, count: 4)
        let context = try #require(CGContext(
            data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        // Shift the image so the requested pixel lands in the 1×1 context (CG's origin is bottom-left).
        context.draw(cgImage, in: CGRect(
            x: -point.x, y: point.y - CGFloat(cgImage.height) + 1,
            width: CGFloat(cgImage.width), height: CGFloat(cgImage.height)
        ))
        return Double(Int(pixel[0]) + Int(pixel[1]) + Int(pixel[2])) / (3 * 255)
    }
}
