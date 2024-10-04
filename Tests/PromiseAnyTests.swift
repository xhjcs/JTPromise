//
//  JTPromiseAnyTests.swift
//  JTPromiseExampleTests
//
//  Created by xinghanjie on 2024/10/1.
//

@testable import JTPromise
import XCTest

final class PromiseAnyTests: XCTestCase {
    // MARK: - Test Promise.any

    func testPromiseAnySuccess() {
        let promise1 = Promise<Int>(resolve: 1)
        let promise2 = Promise<Int>(reject: NSError(domain: "TestError", code: 1, userInfo: nil))
        let promise3 = Promise<Int>(resolve: 3)

        let anyPromise = Promise.any([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.any should resolve with the first resolved value")

        anyPromise.then { value in
            XCTAssertEqual(value, 1)
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.any should not reject")
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncPromiseAnySuccess() {
        let promise1 = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                resolve(1)
            })
        }
        let promise2 = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                reject(TestError.testFailed)
            })
        }
        let promise3 = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                resolve(3)
            })
        }

        let anyPromise = Promise.any([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.any should resolve with the first resolved value")

        anyPromise.then { value in
            XCTAssertEqual(value, 1)
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.any should not reject")
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testPromiseAnyFailure() {
        let promise1 = Promise<Int>(reject: TestError.testFailed)
        let promise2 = Promise<Int>(reject: TestError.testFailed)
        let promise3 = Promise<Int>(reject: TestError.testFailed)

        let anyPromise = Promise.any([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.any should reject when all promises reject")

        anyPromise.then { _ in
            XCTFail("Promise.any should not resolve")
        }.catch { error -> Void in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testPromiseAnyThreadSafety() {
        let expectation = PromiseExpectation(description: "All promises in array should settle concurrently with mixed fulfilled and rejected states")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

        // 创建多个 Promise，每个在不同线程中调用 resolve 或 reject，并将其添加到数组中。
        var promises = [Promise<Int>]()
        for i in 0 ..< 100 {
            promises.append(Promise { resolve, reject in
                DispatchQueue.global().async {
                    if i % 2 == 0 {
                        resolve(i)
                    } else {
                        reject(TestError.testFailed)
                    }
                }
            })
        }

        // 使用 `allSettled` 处理 Promise 数组
        let allSettledPromise = Promise.any(promises)

        allSettledPromise.then { results in
            XCTAssertTrue(results == 0)
            expectation.fulfill()
        }.catch { error in
            XCTFail("Promise.allSettled should not reject, but caught error: \(error)")
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 3.0)
    }

    func testPromiseAnyFailureThreadSafety() {
        let expectation = PromiseExpectation(description: "All promises in array should settle concurrently with mixed fulfilled and rejected states")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

        // 创建多个 Promise，每个在不同线程中调用 resolve 或 reject，并将其添加到数组中。
        var promises = [Promise<Int>]()
        for _ in 0 ..< 100 {
            promises.append(Promise { _, reject in
                DispatchQueue.global().async {
                    reject(TestError.testFailed)
                }
            })
        }

        // 使用 `allSettled` 处理 Promise 数组
        let allSettledPromise = Promise.any(promises)

        allSettledPromise.then { _ in
            XCTFail("Promise.allSettled should not resolve")
        }.catch { _ in
            expectation.fulfill()
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 3.0)
    }
}
