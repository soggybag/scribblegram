import SwiftUI
import UIKit

/// Draws strokes the same way everywhere: into the raster cache, and live in a SwiftUI `Canvas`.
nonisolated enum StrokeRenderer {
    static func draw(_ stroke: Stroke, in context: CGContext) {
        context.addPath(StrokeSmoothing.path(for: stroke.points).cgPath)
        context.setStrokeColor(stroke.color.cgColor(opacity: stroke.opacity))
        context.setLineWidth(stroke.width)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.strokePath()
    }

    /// The same style `draw(_:in:)` uses, for drawing the live stroke in a SwiftUI `Canvas`.
    static func style(for stroke: Stroke) -> StrokeStyle {
        StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round)
    }
}

nonisolated extension StrokeColor {
    func cgColor(opacity: Double) -> CGColor {
        CGColor(srgbRed: red, green: green, blue: blue, alpha: opacity)
    }

    func color(opacity: Double) -> Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
