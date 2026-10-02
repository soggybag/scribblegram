import SwiftUI

struct CanvasView: View {
    let model: CanvasModel
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        Canvas { context, size in
            if let cache = model.cache {
                context.draw(Image(uiImage: cache), in: CGRect(origin: .zero, size: size))
            }
            if let stroke = model.liveStroke {
                context.stroke(
                    StrokeSmoothing.path(for: stroke.points),
                    with: .color(stroke.color.color(opacity: stroke.opacity)),
                    style: StrokeRenderer.style(for: stroke)
                )
            }
        }
        .background(.white)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { model.addPoint($0.location) }
                .onEnded { _ in model.endStroke() }
        )
        .onGeometryChange(for: CGSize.self) { $0.size } action: { size in
            model.setCanvas(size: size, scale: displayScale)
        }
        .onChange(of: displayScale) {
            model.setCanvas(size: model.canvasSize, scale: displayScale)
        }
    }
}

#Preview {
    CanvasView(model: CanvasModel())
}
