import SwiftUI

struct ContentView: View {
    @State private var model = CanvasModel()

    var body: some View {
        CanvasView(model: model)
            .ignoresSafeArea()
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
