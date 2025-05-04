import NotificationServiceMocks
import XCTest

@testable import NotificationService

final class NotificationServiceTests: XCTestCase {
    var sut: NotificationService!
    var mockUserNotificationCenter: UserNotificationCenterMock!
    
    override func setUp() {
        mockUserNotificationCenter = UserNotificationCenterMock()
        sut = NotificationService(center: mockUserNotificationCenter)
    }
    
    override func tearDown() {
        mockUserNotificationCenter = nil
        sut = nil
    }
}

extension NotificationServiceTests {
    func test_deschedulePendingNotifications_callsUNC() {
        // When
        sut.deschedulePendingNotifications()
        
        // Then
        XCTAssertTrue(mockUserNotificationCenter.requestAuthorizationCalled)
    }
    
    func test_requestAuthorizationForNotification_requestsAuth_withOptions() throws {
        // Given
        let correctOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        // When
        sut.requestAuthorizationForNotifications { _, _ in }
        
        // Then
        XCTAssertTrue(mockUserNotificationCenter.requestAuthorizationCalled)
        let options = try XCTUnwrap(
            mockUserNotificationCenter.requestAuthorizationOptions
        )
        XCTAssertEqual(options, correctOptions)
    }
}
