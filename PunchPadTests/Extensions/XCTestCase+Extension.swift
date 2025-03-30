//
//  XCTestCase+Extension.swift
//  PunchPadTests
//
//  Created by Tomasz Kubiak on 12/02/2024.
//

import XCTest
import Combine

extension XCTestCase {
    func awaitPublisher<T: Publisher>(_ publisher: T, timeout: TimeInterval = 2.5, file: StaticString = #file, line: UInt = #line) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")
        
        let cancellable = publisher.sink { completion in
            switch completion {
            case .failure(let error):
                result = .failure(error)
            case .finished:
                break
            }
            expectation.fulfill()
        } receiveValue: { value in
            result = .success(value)
        }
        waitForExpectations(timeout: timeout)
        cancellable.cancel()
        let unwrappedResult = try XCTUnwrap(result,
                                            "Awaited publisher did not produce any output",
                                            file: file,
                                            line: line)
        return try unwrappedResult.get()
    }
}

extension StableDateCreating where Self: XCTest {
    func createDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date? {
        let components = DateComponents(
            calendar: fixedCalendar,
            timeZone: fixedCalendar.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )
        return fixedCalendar.date(from: components)
    }
}
