import CoreGraphics
import SwiftUI
import Testing
@testable import Scribblegram

struct StrokeSmoothingTests {
    @Test func fewerThanTwoPointsHaveNoSegments() {
        #expect(StrokeSmoothing.segments(for: []).isEmpty)
        #expect(StrokeSmoothing.segments(for: [CGPoint(x: 1, y: 1)]).isEmpty)
    }

    @Test func singlePointStillDrawsADot() {
        let path = StrokeSmoothing.path(for: [CGPoint(x: 5, y: 5)])
        #expect(!path.isEmpty)
    }

    @Test func twoPointsMakeAStraightSegment() {
        let a = CGPoint(x: 0, y: 0)
        let b = CGPoint(x: 10, y: 0)
        let segments = StrokeSmoothing.segments(for: [a, b])
        #expect(segments == [StrokeSmoothing.Segment(start: a, control1: a, control2: b, end: b)])
    }

    @Test func fivePointsMatchV1Curve() {
        let points = [
            CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 5), CGPoint(x: 20, y: 0),
            CGPoint(x: 30, y: 5), CGPoint(x: 40, y: 0),
        ]
        let segments = StrokeSmoothing.segments(for: points)

        // v1: curve from p0 to midpoint(p2, p4) with controls p1 and p2...
        #expect(segments.first == StrokeSmoothing.Segment(
            start: points[0], control1: points[1], control2: points[2], end: CGPoint(x: 30, y: 0)
        ))
        // ...then (new in v2) the remainder up to the last point.
        #expect(segments.count == 2)
        #expect(segments.last?.end == points[4])
    }

    @Test(arguments: 2...25)
    func segmentsAreContinuousAndEndAtLastPoint(count: Int) {
        let points = (0..<count).map { CGPoint(x: Double($0) * 7, y: Double($0 % 3) * 4) }
        let segments = StrokeSmoothing.segments(for: points)

        #expect(segments.first?.start == points.first)
        #expect(segments.last?.end == points.last)
        for (previous, next) in zip(segments, segments.dropFirst()) {
            #expect(previous.end == next.start)
        }
    }
}
