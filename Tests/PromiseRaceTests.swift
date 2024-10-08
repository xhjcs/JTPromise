//
//  JTPromiseRaceTests.swift
//  JTPromiseExampleTests
//
//  Created by xinghanjie on 2024/10/1.
//

@testable import JTPromise
import XCTest

final class PromiseRaceTests: XCTestCase {
    // MARK: - Test Promise.race

    func testPromiseRaceSuccess() {
        let promise1 = Promise<Int> { resolve, _ in DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { resolve(1) } }
        let promise2 = Promise<Int> { resolve, _ in DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) { resolve(2) } }
        let promise3 = Promise<Int> { resolve, _ in DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) { resolve(3) } }

        let racePromise = Promise.race([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.race should resolve with the first resolved value")

        racePromise.then { value in
            XCTAssertEqual(value, 2) // Promise2 should win the race
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.race should not reject")
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testArrayPromiseRaceFailure() {
        let promise1 = Promise<Int> { resolve, _ in DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { resolve(1) } }
        let promise2 = Promise<Int> { resolve, _ in DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) { resolve(2) } }
        let promise3 = Promise<Int> { _, reject in DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) { reject(TestError.testFailed) } }

        let racePromise = Promise.race([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.race should resolve with the first resolved value")

        racePromise.then { _ in
            XCTFail("Promise.race should not resolve")
        }.catch { error -> Void in
            XCTAssertNotNil(error) // Promise2 should reject first
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testPromiseRaceFailure() {
        let promise1 = Promise<Int> { _, reject in DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { reject(NSError(domain: "TestError", code: 1, userInfo: nil)) } }
        let promise2 = Promise<Int> { _, reject in DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) { reject(NSError(domain: "TestError", code: 2, userInfo: nil)) } }
        let promise3 = Promise<Int> { _, reject in DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) { reject(NSError(domain: "TestError", code: 3, userInfo: nil)) } }

        let racePromise = Promise.race([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.race should reject with the first rejected error")

        racePromise.then { _ in
            XCTFail("Promise.race should not resolve")
        }.catch { error -> Void in
            XCTAssertNotNil(error) // Promise2 should reject first
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testPromiseRaceThreadSafety() {
        let expectation = PromiseExpectation(description: "All promises in array should settle concurrently with mixed fulfilled and rejected states")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")
        var isSuccess: Bool? = true

        // 创建多个 Promise，每个在不同线程中调用 resolve 或 reject，并将其添加到数组中。
        var promises = [Promise<Int>]()
        for i in 0 ..< 100 {
            promises.append(Promise { resolve, reject in
                DispatchQueue.global().async {
                    if i % 2 == 0 {
                        DispatchQueue.global().sync(flags: .barrier) {
                            if isSuccess == nil {
                                isSuccess = true
                            }
                        }
                        resolve(i)
                    } else {
                        DispatchQueue.global().sync(flags: .barrier) {
                            if isSuccess == nil {
                                isSuccess = false
                            }
                        }
                        reject(TestError.testFailed)
                    }
                }
            })
        }

        // 使用 `allSettled` 处理 Promise 数组
        let allSettledPromise = Promise.any(promises)

        allSettledPromise.then { results in
            if isSuccess! {
                XCTAssertTrue(results == 0)
                expectation.fulfill()
            } else {
                XCTFail("Promise.allSettled should not resolve")
            }
        }.catch { error -> Void in
            if isSuccess! {
                XCTFail("Promise.allSettled should not reject, but caught error: \(error)")
            } else {
                XCTAssertTrue((error as! TestError) == .testFailed)
            }
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 3.0, enforceOrder: true)
    }

    func testPromiseRaceThreadSafety1() {
        let expectation = PromiseExpectation(description: "All promises in array should settle concurrently with mixed fulfilled and rejected states")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")
        var isSuccess: Bool? = true

        // 创建多个 Promise，每个在不同线程中调用 resolve 或 reject，并将其添加到数组中。
        var promises = [Promise<Int>]()
        for i in 0 ..< 100 {
            promises.append(Promise { resolve, reject in
                DispatchQueue.global().async {
                    if i % 2 == 1 {
                        DispatchQueue.global().sync(flags: .barrier) {
                            if isSuccess == nil {
                                isSuccess = true
                            }
                        }
                        resolve(i)
                    } else {
                        DispatchQueue.global().sync(flags: .barrier) {
                            if isSuccess == nil {
                                isSuccess = false
                            }
                        }
                        reject(TestError.testFailed)
                    }
                }
            })
        }

        // 使用 `allSettled` 处理 Promise 数组
        let allSettledPromise = Promise.any(promises)

        allSettledPromise.then { results in
            if isSuccess! {
                XCTAssertTrue(results >= 0 && results < 100)
                expectation.fulfill()
            } else {
                XCTFail("Promise.allSettled should not resolve")
            }
        }.catch { error -> Void in
            if isSuccess! {
                XCTFail("Promise.allSettled should not reject, but caught error: \(error)")
            } else {
                XCTAssertTrue((error as! TestError) == .testFailed)
            }
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 3.0, enforceOrder: true)
    }
}
