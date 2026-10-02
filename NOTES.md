# Scribblegram — Notes and Ideas

Ideas, decisions, and open questions to revisit. The milestone plan is in `PLAN.md`.

---

## Brush control

**Current:** the brush pad. Tap the brush button to open a square pad. Left to right sets size, bottom to top sets opacity, and the dot sits under your finger. Tap outside to close.

**Why it changed:** the first version was a relative drag from the brush button in the top-right corner. Your finger ran off the screen before reaching large sizes or full opacity.

**Alternatives considered** (worth trying if the pad doesn't hold up):
- **Two sliders in a panel.** A glass panel under the brush button with a preview dot and Size / Opacity sliders. The most familiar and precise option, and it works with VoiceOver for free. Less playful.
- **Side sliders, like Procreate.** Two short vertical sliders always visible along the left edge, with the preview dot shown while dragging. Fastest to reach mid-drawing, but uses a strip of the canvas edge.
- **Keep the drag, move it inward.** Put the button at the middle of the right edge and double the sensitivity. Smallest change, but it's still a relative drag, so long adjustments may take two drags.

**Settings to tune** (`Views/BrushControl.swift`):
- `BrushMapping.widthCurve` (2.0): how much of the pad goes to small sizes.
- `BrushPad.side` (260) and `BrushPad.inset` (20).

## Color strip

**Current:** v1's dock-style strip. Swatches near your finger stretch up to 2.5× tall and up to about 1.5× wide, the row always fits the screen width, and lifting picks the swatch under your finger.

**Settings to tune** (`ColorStripLayout` in `Views/ColorStrip.swift`):
- `reach` (100 pt): how far from your finger swatches still react.
- `maxStretch` (1.5): extra height.
- `maxWiden` (1.0): extra width before the row is squeezed back to fit.
- `selectedStretch` (0.3): how much taller the selected swatch sits at rest.

**Ideas:**
- The M3 custom color picker and recent colors will need a place to go. Options: a long-press on the strip, or an extra swatch at one end.

## Deliberate changes from v1

- Dragging **up** makes the brush more opaque. In v1, dragging down did.
- The lowest opacity is **5%** instead of 1%, which was practically invisible.
- The selected swatch sits a little taller so you can see the current color. v1 didn't show it.
- Clearing the canvas is new and asks for confirmation. Once M3 adds undo, it could be undoable instead.
- Strokes end exactly at the last touch point. v1 dropped the last few points.

## Performance

**Results** (iPhone 11 Pro, 60 Hz, Animation Hitches):

| | Hitch time ratio | Hitches (not counting launch) |
|---|---|---|
| Before the fix | ~5.5 ms/s | 4 |
| After the fix | ~0.3 ms/s | 1 |

The fix: `StrokeRaster` keeps one bitmap and draws only the new stroke into it. Before, the whole cache was redrawn every time a stroke ended.

**Not verified yet:**
- **120 Hz.** Needs a ProMotion iPhone (13 Pro or later Pro model).
- **500+ strokes under Instruments.** The debug overlay with the +500 button only exists in Debug builds, and Profile uses Release. To run it, set Edit Scheme → Profile → Build Configuration to Debug, then set it back afterwards.

**Ideas:**
- **Remaining hitch:** the one left (~20 ms) was drawing a single finished stroke into the bitmap on the main thread, probably a long or wide one. A fix is to draw it on a background thread and keep showing the live stroke until it's done. Could happen alongside M6, which rebuilds stroke drawing for Pencil anyway.
- **Coalesced touches:** the fallback in `PLAN.md` M1 isn't built. Add it only if fast strokes show dropped points.

## Tooling tips

- **Simulators:** the iPhone 16 simulators run iOS 18.4, which is older than the app's iOS 26 minimum. Use an iOS 26.x simulator (e.g. iPhone 17 Pro).
- **Reading traces:** `xcrun xctrace export --input <file>.trace --toc` lists a trace's tables, and `--xpath` exports one (e.g. `hitches`, `potential-hangs`, `time-profile`) for a closer look.
