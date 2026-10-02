import SwiftUI

/// Turns raw touch points into smooth curves.
nonisolated enum StrokeSmoothing {
    struct Segment: Equatable, Sendable {
        var start: CGPoint
        var control1: CGPoint
        var control2: CGPoint
        var end: CGPoint
    }

    /// Port of v1's `SmothView` smoothing: every four new points become one cubic Bézier that
    /// ends at the midpoint of the 3rd and 5th points, so consecutive curves join without kinks.
    /// Unlike v1, the leftover points at the end of a stroke are drawn too, so every stroke
    /// ends exactly at its last point.
    static func segments(for points: [CGPoint]) -> [Segment] {
        guard points.count > 1 else { return [] }

        var segments: [Segment] = []
        var pending = [points[0]]
        for point in points.dropFirst() {
            pending.append(point)
            if pending.count == 5 {
                let end = midpoint(pending[2], pending[4])
                segments.append(Segment(start: pending[0], control1: pending[1], control2: pending[2], end: end))
                pending = [end, pending[4]]
            }
        }

        switch pending.count {
        case 2:
            segments.append(Segment(start: pending[0], control1: pending[0], control2: pending[1], end: pending[1]))
        case 3:
            segments.append(quadratic(pending[0], control: pending[1], end: pending[2]))
        case 4:
            segments.append(Segment(start: pending[0], control1: pending[1], control2: pending[2], end: pending[3]))
        default:
            break
        }
        return segments
    }

    static func path(for points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)

        let segments = segments(for: points)
        if segments.isEmpty {
            // A zero-length line with a round cap draws a dot, so a single tap leaves a mark.
            path.addLine(to: first)
        }
        for segment in segments {
            path.addCurve(to: segment.end, control1: segment.control1, control2: segment.control2)
        }
        return path
    }

    private static func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }

    /// Expresses a quadratic curve as the equivalent cubic so all segments share one type.
    private static func quadratic(_ start: CGPoint, control: CGPoint, end: CGPoint) -> Segment {
        Segment(
            start: start,
            control1: CGPoint(x: start.x + 2 / 3 * (control.x - start.x), y: start.y + 2 / 3 * (control.y - start.y)),
            control2: CGPoint(x: end.x + 2 / 3 * (control.x - end.x), y: end.y + 2 / 3 * (control.y - end.y)),
            end: end
        )
    }
}
