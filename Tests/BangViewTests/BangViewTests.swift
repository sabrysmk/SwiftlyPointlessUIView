import XCTest
@testable import BangView

class BangViewTests: XCTestCase {
    
    func testBangViewModelInit() {
        let viewModel = BangViewModel(image: nil, text: "Test", textColor: .red, backgroundColor: .blue, font: nil)
        XCTAssertEqual(viewModel.text, "Test")
        XCTAssertEqual(viewModel.textColor, .red)
        XCTAssertEqual(viewModel.backgroundColor, .blue)
    }

    func testRequiredWidth() {
        let viewModel = BangViewModel(image: nil, text: "Test", textColor: .red, backgroundColor: .blue, font: nil)
        XCTAssertGreaterThan(viewModel.requiredWidth(), 0)
    }

    func testBangViewInit() {
        let viewModel = BangViewModel(image: nil, text: "Test", textColor: .red, backgroundColor: .blue, font: nil)
        let bangView = BangView(viewModel: viewModel)
        XCTAssertEqual(bangView.viewModel.text, "Test")
    }

    // Mock UIWindow for tests
    class MockWindow: UIWindow {
        override var safeAreaInsets: UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
    }

    func testShouldShowBang() {
        let bangManager = BangsManager()
        let shouldShow = bangManager.shouldShowBang(window: MockWindow())
        XCTAssertTrue(shouldShow)
    }
}
