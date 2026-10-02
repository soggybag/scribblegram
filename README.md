# Scribblegram

[Scribblegram](http://webdevils.com/scribblegram/) is a simple drawing app for iPhone and iPad. The original version from 2014 is [on the App Store](https://itunes.apple.com/us/app/scribblegram/id955086437?mt=8&uo=4).

This branch is **Scribblegram 2**, a ground-up rebuild in SwiftUI. It will ship as an update to the same App Store listing. Work in progress: see [PLAN.md](PLAN.md) for the milestones.

## What works so far

- **Smooth drawing.** v1's Bézier smoothing, with a renderer that only redraws the stroke in progress, so drawing stays fast however full the canvas gets.
- **Color strip.** v1's 11 colors as a dock-style strip: swatches near your finger stretch and widen, and lifting picks the one under your finger.
- **Brush pad.** Tap the brush button and touch anywhere on the pad: left to right sets size, bottom to top sets opacity.
- **Clear** the canvas, with confirmation.

Coming next: undo/redo and an eraser, a gallery with autosave, sharing, and Apple Pencil support.

## Building

Requirements: Xcode 27, iOS 26 or later.

1. Open `Scribblegram.xcodeproj`.
2. Choose the **Scribblegram** scheme and an iOS 26 simulator or a device.
3. Run with ⌘R, or run the tests with ⌘U.

To run on a device, set your own team under **Signing & Capabilities**.

Debug builds show a small overlay with the frame rate and a **+500** button that fills the canvas with test strokes.

## Project layout

| Folder | Contents |
|---|---|
| `Scribblegram/Model` | `Stroke` and `Drawing` (plain `Codable` data) and the color palette |
| `Scribblegram/Engine` | Stroke smoothing, rendering, and `CanvasModel` |
| `Scribblegram/Views` | The canvas, color strip, brush controls, and debug overlay |
| `ScribblegramTests` | Swift Testing tests |

Drawings are stored as strokes (lists of points with a color and brush), not as pictures. That's what makes undo, saving, and replay possible.

## The original app

Scribblegram 1 was written in 2014 in Swift and UIKit, and was a great way to learn Core Graphics and multithreading. It let you pick colors, set the brush size and opacity, and post drawings to Twitter and Facebook. Its code is preserved at the [`v1-legacy`](https://github.com/soggybag/scribblegram/tree/v1-legacy) tag.

![Scribblegram 1](https://github.com/soggybag/scribblegram/raw/v1-legacy/screencast.gif)
