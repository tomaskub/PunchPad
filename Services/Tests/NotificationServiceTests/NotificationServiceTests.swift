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
    
    func test_requestAuthorizationForNotification_callsFailureHandler_whenRequestAuthFails() {
        // Given
        mockUserNotificationCenter.requestAuthorizationReturn = false
        var result: Bool?
        var resultError: Error?
        
        // When
        sut.requestAuthorizationForNotifications { success, error in
            result = success
            resultError = error
        }
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertNil(resultError)
        XCTAssertEqual(result, false)
    }
    
    func test_requestAuthorizationForNotification_callsFailureHandler_whenRequestAuthFails_withError() {
        // Given
        mockUserNotificationCenter.requestAuthorizationReturn = false
        mockUserNotificationCenter.requestAuthorizationShouldFailError = MockError.mock
        var result: Bool?
        var resultError: Error?
        
        // When
        sut.requestAuthorizationForNotifications { success, error in
            result = success
            resultError = error
        }
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertNotNil(resultError)
        XCTAssertEqual(result, false)
        XCTAssertEqual(resultError as? MockError, MockError.mock)
    }
    
    func test_requestAuthorizationForNotification_doesNotCallFailureHandler_whenRequestAuthSucceeds_withError() {
        // Given
        mockUserNotificationCenter.requestAuthorizationReturn = true
        mockUserNotificationCenter.requestAuthorizationShouldFailError = MockError.mock
        var result: Bool?
        var resultError: Error?
        
        // When
        sut.requestAuthorizationForNotifications { success, error in
            result = success
            resultError = error
        }
        
        // Then
        XCTAssertNil(result)
        XCTAssertNil(resultError)
    }
    
    func test_scheduleNotification_doesNotCallAdd_whenNotAuthorized() {
        // Given
        mockUserNotificationCenter.getNotificationSettingsReturn = .init(authorizationStatus: .denied)
        
        // When
        sut.scheduleNotification(for: .overTime, in: 5)
        
       // Then
        XCTAssertFalse(mockUserNotificationCenter.addCalled)
    }
    
    func test_scheduleNotification_callsAdd_whenAuthorized() {
        // Given
        mockUserNotificationCenter.getNotificationSettingsReturn = .init(authorizationStatus: .authorized)
        
        // When
        sut.scheduleNotification(for: .overTime, in: 5)
        
       // Then
        XCTAssertTrue(mockUserNotificationCenter.addCalled)
    }
}
