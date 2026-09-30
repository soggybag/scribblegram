# Scribblegram 2026 — Rebuild Plan

**Approach:** Fresh SwiftUI app with a custom stroke engine. Swift 6.4, Xcode 27, strict concurrency. Rebuilt in this repo; the original 2014 app is preserved at the `v1-legacy` tag.

**Bundle ID:** Keep `com.webdevils.Color-Picker-2` so v2 ships as an **update to the existing App Store listing** (id955086437), keeping reviews, URL, and existing users.

---

## M0 — Clean slate
- Tag the current commit `v1-legacy`.
- Create a `v2` branch; remove the v1 code in a single "Remove v1 code" commit.
- New Xcode project: SwiftUI lifecycle, iOS 26 minimum, iPhone + iPad, Swift 6 language mode, Swift Testing target, existing bundle ID.
- Folder structure: `Model/`, `Engine/`, `Views/`, `Persistence/` (folders are created as code lands; the project uses synced folder groups, so no placeholder files).
- Merge `v2` into `master` once the app is presentable (M2 at the earliest); update the README then.

**Done when:** Blank app builds and runs on device from the `v2` branch with zero warnings.

## M1 — Stroke engine (the core)
- Data model: `Stroke` (points, color, width, opacity) and `Drawing` (ordered strokes), both `Codable` and `Sendable`. The drawing is *data*, not a bitmap — this is what makes undo, saving, replay, and future social features possible.
- Port the 4-point Bézier smoothing from v1's `SmothView` as a pure function with unit tests.
- Render with SwiftUI `Canvas`; cache completed strokes into a raster layer so only the live stroke redraws each frame.
- Input via `DragGesture(minimumDistance: 0)`, falling back to coalesced touches if points are dropped.

**Done when:** Drawing is smooth with no visible lag at 120 Hz on a real device with 500+ strokes on screen, verified in Instruments. Smoothing tests pass.

## M2 — Parity with v1
- **Color strip:** the dock-style stretching swatches, rebuilt in SwiftUI with spring animation and haptics on selection.
- **Brush control:** drag gesture (horizontal = size, vertical = opacity) with a live preview dot, as an overlay instead of a separate screen.
- Clear canvas (with confirmation).

**Done when:** Everything the 2014 app did, the new one does better (compare side by side).

## M3 — Editing essentials
- Undo/redo (including two- and three-finger tap gestures).
- Eraser: stroke eraser, pixel-style eraser, or both.
- Custom color picker beyond the 11 presets; recently used colors.

**Done when:** You can make a mistake and recover without thinking.

## M4 — Saving and gallery
- SwiftData store of drawings; autosave while drawing.
- Gallery grid with thumbnails; create, duplicate, delete.
- Restore the last drawing on launch.

**Done when:** Force-quitting mid-drawing loses nothing; a gallery of 100 drawings scrolls smoothly.

## M5 — Export and share
- Full-resolution PNG render; share via `ShareLink` (covers Photos, Messages, and any social app — replaces v1's Twitter/Facebook code).
- Optional: timelapse video export of the drawing being made, built from the stroke data.

**Done when:** A finished drawing goes to a sent iMessage in 2 taps.

## M6 — Apple Pencil and iPad
- Pressure- and tilt-sensitive width: render strokes as filled outlines rather than fixed-width lines (a real engine change).
- Pencil hover preview, squeeze/double-tap to toggle the eraser, palm rejection.
- Adaptive layout for iPad and landscape.

**Done when:** Drawing with a Pencil on iPad feels natural (tested with a real Pencil).

## M7 — Polish and ship
- New app icon, launch screen, dark mode UI chrome, accessibility (VoiceOver labels, color names, Reduce Motion).
- Privacy manifest, App Store screenshots.
- TestFlight with a few people for a week, then ship v2.0.

**Done when:** It's live on the App Store.

---

## How the plan stays on track
- **Each milestone ends with a working app on a real device.** No milestone leaves the app half-broken.
- **The stroke engine comes first and gets measured.** If drawing doesn't feel great, nothing else matters, so M1 has a performance bar you can check.
- **A small commit and a tag (`m1`, `m2`, …) at the end of each milestone.** This gives you checkpoints to return to.
- **Social features are deferred on purpose.** The `Codable` stroke model keeps that door open without building a backend now.
