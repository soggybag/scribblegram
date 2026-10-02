import SwiftUI

/// v1's dock-style palette: touching the strip stretches the swatches near your finger,
/// sliding moves the bulge, and lifting picks the swatch under your finger.
struct ColorStrip: View {
    @Binding var selection: StrokeColor
    /// The swatches run under the home indicator, like v1's strip ran off the bottom of the screen.
    var bottomInset: CGFloat = 0
    @State private var fingerX: CGFloat?

    private let palette = Swatch.palette

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let widths = ColorStripLayout.widths(count: palette.count, width: width, fingerX: fingerX)
            HStack(spacing: 0) {
                ForEach(palette.indices, id: \.self) { index in
                    let swatch = palette[index]
                    Rectangle()
                        .fill(swatch.color.color(opacity: 1))
                        // Keeps the white swatch visible against the white canvas.
                        .overlay(Rectangle().strokeBorder(.black.opacity(0.08), lineWidth: 0.5))
                        .scaleEffect(
                            x: 1,
                            y: ColorStripLayout.stretch(
                                forSwatchAt: index, count: palette.count, width: width,
                                fingerX: fingerX, isSelected: swatch.color == selection
                            ),
                            anchor: .bottom
                        )
                        .frame(width: widths[index])
                        .accessibilityElement()
                        .accessibilityLabel(swatch.name)
                        .accessibilityAddTraits(swatch.color == selection ? [.isButton, .isSelected] : .isButton)
                        .accessibilityAction { selection = swatch.color }
                }
            }
            .contentShape(.rect)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { fingerX = $0.location.x }
                    .onEnded { value in
                        let index = ColorStripLayout.index(at: value.location.x, in: widths)
                        selection = palette[index].color
                        fingerX = nil
                    }
            )
            .animation(fingerX == nil ? .spring(duration: 0.35, bounce: 0.45) : .interactiveSpring, value: fingerX)
            .sensoryFeedback(.selection, trigger: fingerX.map { ColorStripLayout.index(at: $0, in: widths) })
            .sensoryFeedback(.impact(weight: .light), trigger: selection)
        }
        .frame(height: ColorStripLayout.height + bottomInset)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Colors")
    }
}

nonisolated enum ColorStripLayout {
    static let height: CGFloat = 50
    /// How far from the finger, in points, a swatch still stretches.
    static let reach: CGFloat = 100
    /// Extra height for the swatch right under the finger (v1 used 1.5, so 2.5× in all).
    static let maxStretch: CGFloat = 1.5
    /// The selected swatch sits a little taller so you can see which color is active.
    static let selectedStretch: CGFloat = 0.3

    /// Extra width for the swatch right under the finger, before the row is squeezed back
    /// to fit the screen. Its neighbors give up the space, like the Dock's magnification.
    static let maxWiden: CGFloat = 1

    /// Each swatch's width. They always add up to `width`.
    static func widths(count: Int, width: CGFloat, fingerX: CGFloat?) -> [CGFloat] {
        guard count > 0 else { return [] }
        let weights = (0..<count).map { index in
            1 + maxWiden * closeness(ofSwatchAt: index, count: count, width: width, fingerX: fingerX)
        }
        let total = weights.reduce(0, +)
        return weights.map { width * $0 / total }
    }

    /// The swatch whose span contains `x`, clamped to the ends of the strip.
    static func index(at x: CGFloat, in widths: [CGFloat]) -> Int {
        var right: CGFloat = 0
        for (index, width) in widths.enumerated() {
            right += width
            if x < right { return index }
        }
        return max(widths.count - 1, 0)
    }

    static func stretch(forSwatchAt index: Int, count: Int, width: CGFloat, fingerX: CGFloat?, isSelected: Bool) -> CGFloat {
        guard fingerX != nil else { return isSelected ? 1 + selectedStretch : 1 }
        return 1 + maxStretch * closeness(ofSwatchAt: index, count: count, width: width, fingerX: fingerX)
    }

    /// 1 when the finger is over the swatch's resting center, falling to 0 at `reach` away.
    /// Measured from resting positions so the bulge doesn't chase itself as swatches widen.
    private static func closeness(ofSwatchAt index: Int, count: Int, width: CGFloat, fingerX: CGFloat?) -> CGFloat {
        guard let fingerX, width > 0, count > 0 else { return 0 }
        let center = (CGFloat(index) + 0.5) * width / CGFloat(count)
        return max(0, 1 - abs(fingerX - center) / reach)
    }
}

#Preview {
    @Previewable @State var selection = StrokeColor.black
    VStack(spacing: 0) {
        Color.white
        ColorStrip(selection: $selection)
    }
}
