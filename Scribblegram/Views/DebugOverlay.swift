#if DEBUG
import QuartzCore
import SwiftUI

/// Temporary M1 tooling: live stats for checking the performance bar on a real device,
/// plus a button that fills the canvas with test strokes.
struct DebugOverlay: View {
    let model: CanvasModel
    @State private var monitor = FrameRateMonitor()

    var body: some View {
        let strokes = model.drawing.strokes
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text("\(strokes.count) strokes · \(strokes.reduce(0) { $0 + $1.points.count }) pts")
                Text("\(monitor.framesPerSecond, format: .number.precision(.fractionLength(0))) fps · worst \(monitor.worstFrameMilliseconds, format: .number.precision(.fractionLength(1))) ms")
            }
            Button("+500") { model.addRandomStrokes(count: 500) }
                .buttonStyle(.bordered)
        }
        .font(.caption.monospacedDigit())
        .padding(8)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 8))
        .onAppear { monitor.start() }
        .onDisappear { monitor.stop() }
    }
}

/// Measures how often the main thread actually delivers frames. Values are published twice
/// a second so the overlay itself doesn't add per-frame work.
@Observable
final class FrameRateMonitor {
    private(set) var framesPerSecond = 0.0
    private(set) var worstFrameMilliseconds = 0.0

    @ObservationIgnored private var link: CADisplayLink?
    @ObservationIgnored private var lastTimestamp: CFTimeInterval = 0
    @ObservationIgnored private var windowStart: CFTimeInterval = 0
    @ObservationIgnored private var frames = 0
    @ObservationIgnored private var worstInterval: CFTimeInterval = 0

    func start() {
        guard link == nil else { return }
        let target = DisplayLinkTarget { [weak self] link in self?.tick(link) }
        let link = CADisplayLink(target: target, selector: #selector(DisplayLinkTarget.tick(_:)))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 80, maximum: 120, preferred: 120)
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    func stop() {
        link?.invalidate()
        link = nil
        lastTimestamp = 0
    }

    private func tick(_ link: CADisplayLink) {
        defer { lastTimestamp = link.timestamp }
        guard lastTimestamp > 0 else {
            windowStart = link.timestamp
            return
        }
        frames += 1
        worstInterval = max(worstInterval, link.timestamp - lastTimestamp)

        let elapsed = link.timestamp - windowStart
        if elapsed >= 0.5 {
            framesPerSecond = Double(frames) / elapsed
            worstFrameMilliseconds = worstInterval * 1000
            frames = 0
            worstInterval = 0
            windowStart = link.timestamp
        }
    }
}

/// CADisplayLink retains its target, so this small object holds the monitor weakly.
private final class DisplayLinkTarget: NSObject {
    private let onTick: (CADisplayLink) -> Void

    init(onTick: @escaping (CADisplayLink) -> Void) {
        self.onTick = onTick
    }

    @objc func tick(_ link: CADisplayLink) {
        onTick(link)
    }
}

extension CanvasModel {
    /// Adds random squiggles roughly the length of a quick hand-drawn stroke.
    func addRandomStrokes(count: Int) {
        let size = canvasSize
        guard size != .zero else { return }
        let strokes = (0..<count).map { _ in
            var point = CGPoint(x: .random(in: 0...size.width), y: .random(in: 0...size.height))
            var points = [point]
            for _ in 0..<40 {
                point.x = min(max(point.x + .random(in: -12...12), 0), size.width)
                point.y = min(max(point.y + .random(in: -12...12), 0), size.height)
                points.append(point)
            }
            return Stroke(
                points: points,
                color: StrokeColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1)),
                width: .random(in: 2...20),
                opacity: .random(in: 0.3...1)
            )
        }
        append(strokes)
    }
}
#endif
