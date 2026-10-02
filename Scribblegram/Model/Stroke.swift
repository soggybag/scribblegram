import CoreGraphics
import Foundation

/// An RGB color stored as plain numbers so drawings stay `Codable` and platform-independent.
nonisolated struct StrokeColor: Codable, Equatable, Sendable {
    var red: Double
    var green: Double
    var blue: Double

    static let black = StrokeColor(red: 0, green: 0, blue: 0)
}

/// One continuous mark: the raw touch points plus the brush used to draw them.
/// Points are stored unsmoothed so the smoothing can improve later without changing saved drawings.
nonisolated struct Stroke: Codable, Equatable, Identifiable, Sendable {
    var id = UUID()
    var points: [CGPoint]
    var color: StrokeColor
    var width: Double
    var opacity: Double
}

/// A drawing is an ordered list of strokes, oldest first.
nonisolated struct Drawing: Codable, Equatable, Sendable {
    var strokes: [Stroke] = []
}
