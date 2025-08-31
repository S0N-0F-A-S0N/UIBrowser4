import XCTest
@testable import UIBrowser4

// MARK: - Mock Classes

class MockNotificationCenter: NotificationCenter {
    var addedObserver: Any?
    var removedObserver: Any?
    var notificationName: NSNotification.Name?
    var selector: Selector?

    override func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        self.addedObserver = observer
        self.notificationName = aName
        self.selector = aSelector
    }

    override func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        self.removedObserver = observer
        self.notificationName = aName
    }
}

class MockWorkspace: NSWorkspace {
    // NOTE: This is a simplified mock. A real project might need a more robust
    // solution for mocking system-level singletons like NSWorkspace.
    let mockCenter = MockNotificationCenter()

    override var notificationCenter: NotificationCenter {
        return mockCenter
    }
}

/// A mock to satisfy the `MainContentViewController.sharedInstance` dependency.
/// For the purposes of this test, we only need an instance to exist so the singleton
/// can be assigned.
class MockMainContentViewController: MainContentViewController {
    // In a real project with more complex tests, we might override methods here.
}


class FollowFocusCheckboxExtensionTests: XCTestCase {

    var masterVC: MasterSplitItemViewController!
    var mockWorkspace: MockWorkspace!
    var mockButton: NSButton!
    var mockMainContentVC: MainContentViewController!

    override func setUp() {
        super.setUp()
        // We need to instantiate the view controller that has the extension method.
        masterVC = MasterSplitItemViewController()

        // We create our mock objects for each test.
        mockWorkspace = MockWorkspace()
        mockButton = NSButton()

        // Set up the singleton dependency with our mock.
        // This is a common pattern for testing code that relies on singletons.
        mockMainContentVC = MockMainContentViewController()
        MainContentViewController.sharedInstance = mockMainContentVC
    }

    override func tearDown() {
        // Clean up our objects after each test.
        masterVC = nil
        mockWorkspace = nil
        mockButton = nil
        MainContentViewController.sharedInstance = nil // Reset singleton
        super.tearDown()
    }

    func testFollowFocus_whenTurnedOn_addsObserver() {
        // Arrange
        mockButton.state = .on
        let mockNotificationCenter = mockWorkspace.mockCenter

        // Act
        masterVC.handleFollowFocus(sender: mockButton, workspace: mockWorkspace)

        // Assert
        XCTAssertNotNil(mockNotificationCenter.addedObserver, "addObserver should have been called.")
        XCTAssertTrue(mockNotificationCenter.addedObserver as? MainContentViewController === mockMainContentVC, "The observer should be the MainContentViewController singleton.")
        XCTAssertEqual(mockNotificationCenter.notificationName, NSWorkspace.didActivateApplicationNotification, "The notification name should be for application activation.")
        XCTAssertEqual(mockNotificationCenter.selector, #selector(MainContentViewController.frontmostApplicationDidChange(_:)), "The selector should be for the correct handler method.")
        XCTAssertNil(mockNotificationCenter.removedObserver, "removeObserver should not have been called.")
    }

    func testFollowFocus_whenTurnedOff_removesObserver() {
        // Arrange
        mockButton.state = .off
        let mockNotificationCenter = mockWorkspace.mockCenter

        // Act
        masterVC.handleFollowFocus(sender: mockButton, workspace: mockWorkspace)

        // Assert
        XCTAssertNotNil(mockNotificationCenter.removedObserver, "removeObserver should have been called.")
        XCTAssertTrue(mockNotificationCenter.removedObserver as? MainContentViewController === mockMainContentVC, "The observer should be the MainContentViewController singleton.")
        XCTAssertEqual(mockNotificationCenter.notificationName, NSWorkspace.didActivateApplicationNotification, "The notification name should be for application activation.")
        XCTAssertNil(mockNotificationCenter.addedObserver, "addObserver should not have been called.")
    }
}
