import SwiftUI

struct ContentView: View {
    @State private var model = CanvasModel()
    @State private var isShowingBrushPad = false
    @State private var isConfirmingClear = false

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                CanvasView(model: model)
                ColorStrip(selection: $model.brushColor, bottomInset: proxy.safeAreaInsets.bottom)
            }
            .ignoresSafeArea()
        }
        // Shows through when the swatches bounce below their resting size.
        .background(.white)
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 12) {
                Button("Clear", systemImage: "trash") { isConfirmingClear = true }
                    .labelStyle(.iconOnly)
                    .font(.title3)
                    .frame(width: 48, height: 48)
                    .glassEffect(.regular.interactive(), in: .circle)
                    .disabled(model.drawing.strokes.isEmpty)
                    .confirmationDialog("Clear the drawing?", isPresented: $isConfirmingClear, titleVisibility: .visible) {
                        Button("Clear Drawing", role: .destructive) { model.clear() }
                    } message: {
                        Text("This can't be undone.")
                    }
                BrushButton(model: model) { isShowingBrushPad.toggle() }
            }
            .padding()
        }
        .overlay {
            if isShowingBrushPad {
                ZStack {
                    // Catches the tap that closes the pad, so it doesn't draw on the canvas.
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                        .onTapGesture { isShowingBrushPad = false }
                        .accessibilityLabel("Close brush")
                        .accessibilityAddTraits(.isButton)
                    BrushPad(model: model)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
        }
        .animation(.spring(duration: 0.3), value: isShowingBrushPad)
        // Keep edge swipes for drawing; system gestures need a second swipe.
        .defersSystemGestures(on: .all)
        .statusBarHidden()
        #if DEBUG
        .overlay(alignment: .topLeading) {
            DebugOverlay(model: model).padding()
        }
        #endif
    }
}

#Preview {
    ContentView()
}
