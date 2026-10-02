import Observation
import UIKit

/// Editing state for the canvas: the drawing, the stroke in progress, the current brush,
/// and a raster cache of every finished stroke.
@Observable
final class CanvasModel {
    private(set) var drawing = Drawing()
    private(set) var liveStroke: Stroke?
    private(set) var cache: UIImage?
    private(set) var canvasSize: CGSize = .zero

    var brushColor = StrokeColor.black
    var brushWidth = 8.0
    var brushOpacity = 1.0

    @ObservationIgnored private var raster: StrokeRaster?

    /// Rebuilds the cache when the canvas changes size, e.g. on rotation.
    func setCanvas(size: CGSize, scale: CGFloat) {
        guard size != raster?.size || scale != raster?.scale,
              let raster = StrokeRaster(size: size, scale: scale) else { return }
        canvasSize = size
        self.raster = raster
        raster.draw(drawing.strokes)
        cache = raster.image()
    }

    func addPoint(_ point: CGPoint) {
        guard var stroke = liveStroke else {
            liveStroke = Stroke(points: [point], color: brushColor, width: brushWidth, opacity: brushOpacity)
            return
        }
        // Gestures can report the same location twice; duplicates add nothing to the curve.
        guard stroke.points.last != point else { return }
        stroke.points.append(point)
        liveStroke = stroke
    }

    func endStroke() {
        guard let stroke = liveStroke else { return }
        liveStroke = nil
        append([stroke])
    }

    func clear() {
        liveStroke = nil
        drawing = Drawing()
        guard let old = raster, let raster = StrokeRaster(size: old.size, scale: old.scale) else { return }
        self.raster = raster
        cache = raster.image()
    }

    func append(_ strokes: [Stroke]) {
        drawing.strokes.append(contentsOf: strokes)
        guard let raster else { return }
        raster.draw(strokes)
        cache = raster.image()
    }
}
