import Foundation
import Testing
@testable import Scribblegram

struct ScribblegramTests {
    // v2 must ship as an update to the existing App Store listing (id955086437),
    // which requires keeping the original bundle identifier.
    @Test func bundleIdentifierMatchesAppStoreListing() {
        #expect(Bundle.main.bundleIdentifier == "com.webdevils.Color-Picker-2")
    }
}
