import CoreGraphics
import Foundation
import Testing
import UIKit
@testable import Scribblegram

struct DrawingTests {
    @Test func drawingSurvivesEncodingRoundTrip() throws {
        let drawing = Drawing(strokes: [
            Stroke(points: [CGPoint(x: 1, y: 2), CGPoint(x: 3.5, y: 4)], color: .black, width: 8, opacity: 1),
            Stroke(points: [CGPoint(x: 9, y: 9)], color: StrokeColor(red: 1, green: 0.5, blue: 0), width: 2, opacity: 0.4),
        ])
        let data = try JSONEncoder().encode(drawing)
        #expect(try JSONDecoder().decode(Drawing.self, from: data) == drawing)
    }
}

@MainActor
struct CanvasModelTests {
    @Test func finishedStrokeIsAddedToDrawing() {
        let model = CanvasModel()
        model.addPoint(CGPoint(x: 0, y: 0))
        model.addPoint(CGPoint(x: 5, y: 5))
        model.addPoint(CGPoint(x: 9, y: 2))
        #expect(model.liveStroke?.points.count == 3)

        model.endStroke()
        #expect(model.liveStroke == nil)
        #expect(model.drawing.strokes.map(\.points.count) == [3])
    }

    @Test func strokeUsesCurrentBrush() throws {
        let model = CanvasModel()
        model.brushColor = StrokeColor(red: 1, green: 0, blue: 0)
        model.brushWidth = 20
        model.brushOpacity = 0.5
        model.addPoint(.zero)
        model.endStroke()

        let stroke = try #require(model.drawing.strokes.first)
        #expect(stroke.color == StrokeColor(red: 1, green: 0, blue: 0))
        #expect(stroke.width == 20)
        #expect(stroke.opacity == 0.5)
    }

    @Test func duplicatePointsAreIgnored() {
        let model = CanvasModel()
        model.addPoint(CGPoint(x: 1, y: 1))
        model.addPoint(CGPoint(x: 1, y: 1))
        #expect(model.liveStroke?.points.count == 1)
    }

    @Test func endingWithoutPointsDoesNothing() {
        let model = CanvasModel()
        model.endStroke()
        #expect(model.drawing.strokes.isEmpty)
    }

    @Test func cacheIsBuiltOnceCanvasHasASize() {
        let model = CanvasModel()
        model.addPoint(.zero)
        model.endStroke()
        #expect(model.cache == nil)

        model.setCanvas(size: CGSize(width: 100, height: 50), scale: 2)
        #expect(model.cache?.size == CGSize(width: 100, height: 50))
        #expect(model.cache?.scale == 2)
    }
}
