import SwiftUI

/// A round button showing the current brush. Tapping it opens the `BrushPad`.
struct BrushButton: View {
    let model: CanvasModel
    let action: () -> Void

    var body: some View {
        let size = min(max(model.brushWidth, 4), 30)
        Button(action: action) {
            Circle()
                .fill(model.brushColor.color(opacity: model.brushOpacity))
                .overlay(Circle().strokeBorder(.black.opacity(0.15), lineWidth: 0.5))
                .frame(width: size, height: size)
                .frame(width: 48, height: 48)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
        .accessibilityLabel("Brush")
        .accessibilityValue(BrushMapping.description(of: model.brush))
    }
}

/// v1's options screen as an overlay: a square pad where the brush dot sits under your finger.
/// Left to right is size, bottom to top is opacity, so any brush is one touch away.
struct BrushPad: View {
    let model: CanvasModel
    static let side: CGFloat = 260
    /// Keeps the dot's center off the pad's edges so the extremes aren't cut in half.
    static let inset: CGFloat = 20

    var body: some View {
        let side = Self.side
        let inset = Self.inset
        let brush = model.brush
        let position = BrushMapping.point(for: brush, side: side - 2 * inset)

        VStack(spacing: 12) {
            ZStack(alignment: .topLeading) {
                Color.white
                Canvas { context, size in
                    // A faint dot grid so the pad reads as a surface you can touch anywhere.
                    let step = size.width / 8
                    for row in 1..<8 {
                        for column in 1..<8 {
                            let dot = CGRect(x: CGFloat(column) * step - 1.5, y: CGFloat(row) * step - 1.5, width: 3, height: 3)
                            context.fill(Path(ellipseIn: dot), with: .color(.gray.opacity(0.25)))
                        }
                    }
                }
                Circle()
                    .fill(model.brushColor.color(opacity: brush.opacity))
                    .overlay(Circle().strokeBorder(.black.opacity(0.15), lineWidth: 0.5))
                    .frame(width: brush.width, height: brush.width)
                    .position(x: position.x + inset, y: position.y + inset)
            }
            .frame(width: side, height: side)
            .clipShape(.rect(cornerRadius: 16))
            .contentShape(.rect)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let point = CGPoint(x: value.location.x - inset, y: value.location.y - inset)
                        model.brush = BrushMapping.brush(at: point, side: side - 2 * inset)
                    }
            )
            .sensoryFeedback(.impact(weight: .light), trigger: BrushMapping.isAtLimit(brush)) { _, atLimit in atLimit }
            .overlay(alignment: .bottom) {
                axisLabel("size →").offset(y: 20)
            }
            .overlay(alignment: .leading) {
                axisLabel("opacity →").rotationEffect(.degrees(-90)).fixedSize().offset(x: -36)
            }
            .padding(.leading, 12)
            .padding(.bottom, 14)

            Text(BrushMapping.label(for: brush))
                .font(.headline.monospacedDigit())
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 32))
        .accessibilityElement()
        .accessibilityLabel("Brush")
        .accessibilityValue(BrushMapping.description(of: brush))
        .accessibilityAdjustableAction { direction in
            model.brush = BrushMapping.stepped(brush, width: direction == .increment ? 2 : -2)
        }
        .accessibilityAction(named: "More opaque") { model.brush = BrushMapping.stepped(brush, opacity: 0.1) }
        .accessibilityAction(named: "Less opaque") { model.brush = BrushMapping.stepped(brush, opacity: -0.1) }
    }

    private func axisLabel(_ text: String) -> some View {
        Text(text).font(.caption2).foregroundStyle(.secondary)
    }
}

nonisolated struct Brush: Equatable, Sendable {
    var width: Double
    var opacity: Double
}

extension CanvasModel {
    var brush: Brush {
        get { Brush(width: brushWidth, opacity: brushOpacity) }
        set {
            brushWidth = newValue.width
            brushOpacity = newValue.opacity
        }
    }
}

/// Converts between a point on the brush pad and a brush.
nonisolated enum BrushMapping {
    /// v1's range: 1 to 120 points.
    static let widthRange = 1.0...120.0
    /// v1 allowed 1%, which is effectively invisible; 5% is the faintest useful brush.
    static let opacityRange = 0.05...1.0
    /// Width grows with the square of the distance across the pad, so the small sizes
    /// people use most get more room than they would with a straight line.
    static let widthCurve = 2.0

    static func brush(at point: CGPoint, side: CGFloat) -> Brush {
        let x = Double(point.x / side).clamped(to: 0...1)
        let y = 1 - Double(point.y / side).clamped(to: 0...1)
        return Brush(
            width: (widthRange.lowerBound + pow(x, widthCurve) * span(widthRange)).rounded(),
            opacity: opacityRange.lowerBound + y * span(opacityRange)
        )
    }

    static func point(for brush: Brush, side: CGFloat) -> CGPoint {
        let x = pow((brush.width - widthRange.lowerBound) / span(widthRange), 1 / widthCurve).clamped(to: 0...1)
        let y = ((brush.opacity - opacityRange.lowerBound) / span(opacityRange)).clamped(to: 0...1)
        return CGPoint(x: x * side, y: (1 - y) * side)
    }

    static func stepped(_ brush: Brush, width: Double = 0, opacity: Double = 0) -> Brush {
        Brush(
            width: (brush.width + width).clamped(to: widthRange),
            opacity: (brush.opacity + opacity).clamped(to: opacityRange)
        )
    }

    static func isAtLimit(_ brush: Brush) -> Bool {
        brush.width == widthRange.lowerBound || brush.width == widthRange.upperBound
            || brush.opacity == opacityRange.lowerBound || brush.opacity == opacityRange.upperBound
    }

    static func label(for brush: Brush) -> String {
        "\(Int(brush.width)) pt · \(Int((brush.opacity * 100).rounded()))%"
    }

    static func description(of brush: Brush) -> String {
        "\(Int(brush.width)) points, \(Int((brush.opacity * 100).rounded())) percent opacity"
    }

    private static func span(_ range: ClosedRange<Double>) -> Double {
        range.upperBound - range.lowerBound
    }
}

nonisolated private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
