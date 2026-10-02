import CoreGraphics
import Testing
@testable import Scribblegram

struct ColorStripLayoutTests {
    @Test func indexFollowsFingerAndStaysInBounds() {
        let widths = ColorStripLayout.widths(count: 11, width: 110, fingerX: nil)
        #expect(widths == Array(repeating: 10, count: 11))
        #expect(ColorStripLayout.index(at: 0, in: widths) == 0)
        #expect(ColorStripLayout.index(at: 55, in: widths) == 5)
        #expect(ColorStripLayout.index(at: 110, in: widths) == 10)
        #expect(ColorStripLayout.index(at: -30, in: widths) == 0)
        #expect(ColorStripLayout.index(at: 500, in: widths) == 10)
    }

    @Test func swatchUnderFingerWidensAndRowStillFits() {
        // 11 swatches of 40 pt at rest; swatch 5 is centered at 220.
        let widths = ColorStripLayout.widths(count: 11, width: 440, fingerX: 220)
        #expect(abs(widths.reduce(0, +) - 440) < 0.001)
        #expect(widths[5] == widths.max())
        #expect(widths[5] > 40)
        #expect(widths[0] < 40)
        #expect(abs(widths[4] - widths[6]) < 0.001)
        // The finger is still over the swatch it's magnifying.
        #expect(ColorStripLayout.index(at: 220, in: widths) == 5)
    }

    @Test func swatchUnderFingerStretchesMostAndFarOnesDont() {
        // 11 swatches of 40 pt; swatch 5 is centered at 220.
        let stretch = { (index: Int) in
            ColorStripLayout.stretch(forSwatchAt: index, count: 11, width: 440, fingerX: 220, isSelected: false)
        }
        #expect(stretch(5) == 1 + ColorStripLayout.maxStretch)
        #expect(stretch(4) < stretch(5) && stretch(4) > 1)
        #expect(stretch(4) == stretch(6))
        #expect(stretch(0) == 1)
    }

    @Test func atRestOnlyTheSelectedSwatchIsRaised() {
        #expect(ColorStripLayout.stretch(forSwatchAt: 3, count: 11, width: 440, fingerX: nil, isSelected: false) == 1)
        #expect(ColorStripLayout.stretch(forSwatchAt: 3, count: 11, width: 440, fingerX: nil, isSelected: true) > 1)
    }

    @Test func paletteMatchesV1() {
        #expect(Swatch.palette.count == 11)
        #expect(Swatch.palette.map(\.name).first == "Red")
        #expect(Swatch.palette.contains { $0.color == .black })
    }
}

struct BrushMappingTests {
    let side: CGFloat = 200

    @Test func cornersAreTheExtremes() {
        #expect(BrushMapping.brush(at: CGPoint(x: 0, y: side), side: side) == Brush(width: 1, opacity: 0.05))
        #expect(BrushMapping.brush(at: CGPoint(x: side, y: 0), side: side) == Brush(width: 120, opacity: 1))
    }

    @Test func touchesOutsideThePadClamp() {
        #expect(BrushMapping.brush(at: CGPoint(x: -50, y: 900), side: side) == Brush(width: 1, opacity: 0.05))
        #expect(BrushMapping.isAtLimit(BrushMapping.brush(at: CGPoint(x: 900, y: 100), side: side)))
    }

    @Test func smallSizesGetMoreOfThePad() {
        // Halfway across is well under half the maximum size.
        #expect(BrushMapping.brush(at: CGPoint(x: side / 2, y: 0), side: side).width < 40)
    }

    @Test(arguments: [Brush(width: 1, opacity: 1), Brush(width: 8, opacity: 0.5), Brush(width: 61, opacity: 0.2), Brush(width: 120, opacity: 0.05)])
    func dotSitsWhereTouchingWouldPickIt(brush: Brush) {
        let roundTrip = BrushMapping.brush(at: BrushMapping.point(for: brush, side: side), side: side)
        #expect(roundTrip.width == brush.width)
        #expect(abs(roundTrip.opacity - brush.opacity) < 0.0001)
    }

    @Test func steppingStaysInRange() {
        #expect(BrushMapping.stepped(Brush(width: 119, opacity: 0.98), width: 5, opacity: 0.1) == Brush(width: 120, opacity: 1))
        #expect(!BrushMapping.isAtLimit(Brush(width: 20, opacity: 0.5)))
    }
}
