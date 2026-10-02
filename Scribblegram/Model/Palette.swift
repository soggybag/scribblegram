/// A preset color with a name for VoiceOver.
nonisolated struct Swatch: Equatable, Sendable {
    var name: String
    var color: StrokeColor

    /// v1's 11 colors, in its order (UIKit's named colors).
    static let palette = [
        Swatch(name: "Red", color: StrokeColor(red: 1, green: 0, blue: 0)),
        Swatch(name: "Orange", color: StrokeColor(red: 1, green: 0.5, blue: 0)),
        Swatch(name: "Yellow", color: StrokeColor(red: 1, green: 1, blue: 0)),
        Swatch(name: "Green", color: StrokeColor(red: 0, green: 1, blue: 0)),
        Swatch(name: "Cyan", color: StrokeColor(red: 0, green: 1, blue: 1)),
        Swatch(name: "Blue", color: StrokeColor(red: 0, green: 0, blue: 1)),
        Swatch(name: "Purple", color: StrokeColor(red: 0.5, green: 0, blue: 0.5)),
        Swatch(name: "Magenta", color: StrokeColor(red: 1, green: 0, blue: 1)),
        Swatch(name: "Gray", color: StrokeColor(red: 0.5, green: 0.5, blue: 0.5)),
        Swatch(name: "Black", color: .black),
        Swatch(name: "White", color: StrokeColor(red: 1, green: 1, blue: 1)),
    ]
}
