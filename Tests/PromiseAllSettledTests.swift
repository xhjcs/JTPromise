//
//  JTPromiseAllSettledTests.swift
//  JTPromiseExampleTests
//
//  Created by xinghanjie on 2024/10/1.
//

@testable import JTPromiseKit
import XCTest

final class PromiseAllSettledTests: XCTestCase {
    // MARK: - Test Promise.allSettled

    func testPromiseAllSettledSuccess() {
        let promise1 = Promise<Int>(resolve: 1)
        let promise2 = Promise<Int>(resolve: 2)
        let promise3 = Promise<Int>(resolve: 3)

        let allSettledPromise = Promise.allSettled([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.allSettled should resolve with fulfilled results")

        allSettledPromise.then { results in
            XCTAssertEqual(results.count, 3)
            if case let .fulfilled(value) = results[0] { XCTAssertEqual(value, 1) }
            if case let .fulfilled(value) = results[1] { XCTAssertEqual(value, 2) }
            if case let .fulfilled(value) = results[2] { XCTAssertEqual(value, 3) }
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.allSettled should not reject")
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testPromiseAllSettledWithRejection() {
        let promise1 = Promise<Int>(resolve: 1)
        let promise2 = Promise<Int>(reject: NSError(domain: "TestError", code: 1, userInfo: nil))
        let promise3 = Promise<Int>(resolve: 3)

        let allSettledPromise = Promise.allSettled([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.allSettled should resolve with mixed results")

        allSettledPromise.then { results in
            XCTAssertEqual(results.count, 3)
            if case let .fulfilled(value) = results[0] { XCTAssertEqual(value, 1) }
            if case let .rejected(error) = results[1] { XCTAssertNotNil(error) }
            if case let .fulfilled(value) = results[2] { XCTAssertEqual(value, 3) }
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.allSettled should not reject")
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncPromiseAllSettledSuccess() {
        let promise1 = Promise<Int>(reject: TestError.testFailed)
            .catch { _ in
                Promise<Int> { resolve, _ in
                    delay(time: 0.5) {
                        resolve(1)
                    }
                }
            }
        let promise2 = Promise<Int>(resolve: 2)
        let promise3 = Promise<Int>(resolve: 3)

        let allSettledPromise = Promise.allSettled([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.allSettled should resolve with fulfilled results")

        allSettledPromise.then { results in
            XCTAssertEqual(results.count, 3)
            if case let .fulfilled(value) = results[0] { XCTAssertEqual(value, 1) }
            if case let .fulfilled(value) = results[1] { XCTAssertEqual(value, 2) }
            if case let .fulfilled(value) = results[2] { XCTAssertEqual(value, 3) }
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.allSettled should not reject")
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    // MARK: - 测试 `Promise.allSettled` 处理传入数组的 Promise，并验证各个 Promise 的最终状态

    func testAllSettledWithPromiseArrayConcurrently() {
        let expectation = PromiseExpectation(description: "All promises in array should settle concurrently with mixed fulfilled and rejected states")

        // 创建多个 Promise，每个在不同线程中调用 resolve 或 reject，并将其添加到数组中。
        let promises: [Promise<Int>] = [
            Promise { resolve, _ in
                delay(time: 0) {
                    resolve(1)
                }
            },
            Promise { _, reject in
                delay(time: 0) {
                    reject(TestError.testFailed)
                }
            },
            Promise { resolve, _ in
                delay(time: 0) {
                    resolve(3)
                }
            },
            Promise { _, reject in
                delay(time: 0) {
                    reject(TestError.testFailed)
                }
            },
        ]

        // 使用 `allSettled` 处理 Promise 数组
        let allSettledPromise: Promise<[SettledResult<Int>]> = Promise.allSettled(promises)

        allSettledPromise.then { results in
            XCTAssertEqual(results.count, 4, "All promises in the array should be settled")

            // 检查每个 Promise 的结果
            switch results[0] {
            case let .fulfilled(value):
                XCTAssertEqual(value, 1)
            case .rejected:
                XCTFail("Promise 0 should be fulfilled")
            }

            switch results[1] {
            case .fulfilled:
                XCTFail("Promise 1 should be rejected")
            case let .rejected(error):
                XCTAssertEqual(error as? TestError, TestError.testFailed)
            }

            switch results[2] {
            case let .fulfilled(value):
                XCTAssertEqual(value, 3)
            case .rejected:
                XCTFail("Promise 2 should be fulfilled")
            }

            switch results[3] {
            case .fulfilled:
                XCTFail("Promise 3 should be rejected")
            case let .rejected(error):
                XCTAssertEqual(error as? TestError, TestError.testFailed)
            }

            expectation.fulfill()
        }.catch { error in
            XCTFail("Promise.allSettled should not reject, but caught error: \(error)")
        }

        wait(for: [expectation], timeout: 3.0, enforceOrder: true)
    }

    func testAllSettledWithEmptyPromiseArray() {
        let expectation = PromiseExpectation(description: "Empty promise array should resolve immediately with an empty result array")

        let promises: [Promise<Int>] = []

        let allSettledPromise: Promise<[SettledResult<Int>]> = Promise.allSettled(promises)

        allSettledPromise.then { results in
            XCTAssertEqual(results.count, 0, "The result array should be empty when the input promises array is empty")
            expectation.fulfill()
        }.catch { error in
            XCTFail("Promise.allSettled should not reject for an empty promise array, but caught error: \(error)")
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAllSettledWithAllPromisesRejected() {
        let expectation = PromiseExpectation(description: "All promises should reject, and allSettled should still resolve with all rejected results")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

        let promises: [Promise<Int>] = [
            Promise { _, reject in
                delay(time: 0) {
                    reject(TestError.testFailed)
                }
            },
            Promise { _, reject in
                delay(time: 0) {
                    reject(TestError.testFailed)
                }
            },
            Promise { _, reject in
                delay(time: 0) {
                    reject(TestError.testFailed)
                }
            },
        ]

        let allSettledPromise: Promise<[SettledResult<Int>]> = Promise.allSettled(promises)

        allSettledPromise.then { results in
            XCTAssertEqual(results.count, 3, "All promises in the array should be settled")

            for result in results {
                switch result {
                case .fulfilled:
                    XCTFail("All promises should be rejected")
                case let .rejected(error):
                    XCTAssertEqual(error as? TestError, TestError.testFailed)
                }
            }

            expectation.fulfill()
        }.catch { error in
            XCTFail("Promise.allSettled should not reject, but caught error: \(error)")
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 3.0, enforceOrder: true)
    }

    func testAllSettledWithAllPromisesFulfilled() {
        let expectation = PromiseExpectation(description: "All promises should fulfill, and allSettled should resolve with all fulfilled results")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

        let promises: [Promise<Int>] = [
            Promise { resolve, _ in
                delay(time: 0) {
                    resolve(1)
                }
            },
            Promise { resolve, _ in
                delay(time: 0) {
                    resolve(2)
                }
            },
            Promise { resolve, _ in
                delay(time: 0) {
                    resolve(3)
                }
            },
        ]

        let allSettledPromise: Promise<[SettledResult<Int>]> = Promise.allSettled(promises)

        allSettledPromise.then { results in
            XCTAssertEqual(results.count, 3, "All promises in the array should be settled")

            for (index, result) in results.enumerated() {
                switch result {
                case let .fulfilled(value):
                    XCTAssertEqual(value, index + 1)
                case .rejected:
                    XCTFail("All promises should be fulfilled")
                }
            }

            expectation.fulfill()
        }.catch { error in
            XCTFail("Promise.allSettled should not reject, but caught error: \(error)")
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 3.0, enforceOrder: true)
    }

    // MARK: - 测试多个 Promise 在不同线程中调用 resolve 或 reject 时，Promise.allSettled 的行为

    func testAllSettledWithMultiplePromisesFulfilledAndRejectedConcurrently() {
        let expectation = PromiseExpectation(description: "All promises should settle, some fulfilled and some rejected")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

        // 创建六个 Promise，每个都在不同线程中调用 resolve 或 reject。
        let promiseA = Promise<Int> { resolve, _ in
            delay(time: 0) {
                resolve(1)
            }
        }

        let promiseB = Promise<String> { resolve, _ in
            delay(time: 0) {
                resolve("B")
            }
        }

        let promiseC = Promise<Bool> { resolve, _ in
            delay(time: 0) {
                resolve(true)
            }
        }

        let promiseD = Promise<Double> { _, reject in
            delay(time: 0) {
                reject(TestError.testFailed)
            }
        }

        let promiseE = Promise<[String]> { resolve, _ in
            delay(time: 0) {
                resolve(["E"])
            }
        }

        let promiseF = Promise<[Int: String]> { _, reject in
            delay(time: 0) {
                reject(TestError.testFailed)
            }
        }

        // 使用 allSettled 处理多个 Promise
        let allSettledPromise = Promise<(Int, String, Bool, Double, [String], [Int: String])>.allSettled(promiseA, promiseB, promiseC, promiseD, promiseE, promiseF)

        allSettledPromise.then { result in
            let (valueA, valueB, valueC, valueD, valueE, valueF) = result

            // 检查每个 Promise 的结果
            switch valueA {
            case let .fulfilled(value):
                XCTAssertEqual(value, 1)
            case .rejected:
                XCTFail("Promise A should be fulfilled")
            }

            switch valueB {
            case let .fulfilled(value):
                XCTAssertEqual(value, "B")
            case .rejected:
                XCTFail("Promise B should be fulfilled")
            }

            switch valueC {
            case let .fulfilled(value):
                XCTAssertEqual(value, true)
            case .rejected:
                XCTFail("Promise C should be fulfilled")
            }

            switch valueD {
            case .fulfilled:
                XCTFail("Promise D should be rejected")
            case let .rejected(error):
                XCTAssertTrue(error is TestError)
            }

            switch valueE {
            case let .fulfilled(value):
                XCTAssertEqual(value, ["E"])
            case .rejected:
                XCTFail("Promise E should be fulfilled")
            }

            switch valueF {
            case .fulfilled:
                XCTFail("Promise F should be rejected")
            case let .rejected(error):
                XCTAssertTrue(error is TestError)
            }

            expectation.fulfill()
        }.catch { error in
            XCTFail("Promise.allSettled should not reject, but caught error: \(error)")
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 5.0, enforceOrder: true)
    }

    func testAllSettledWithMixedPromisesThenCatchFinally() {
        for _ in 0..<100 {
            let expectation = PromiseExpectation(description: "All promises should invoke their respective then, catch and finally")
            let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

            let promiseA = Promise<Int> { resolve, _ in
                delay(time: 0) {
                    resolve(1)
                }
            }

            let promiseB = Promise<String> { resolve, _ in
                delay(time: 0) {
                    resolve("B")
                }
            }

            let promiseC = Promise<Bool> { resolve, _ in
                delay(time: 0) {
                    resolve(true)
                }
            }

            let promiseD = Promise<Double> { _, reject in
                delay(time: 0) {
                    reject(TestError.testFailed)
                }
            }

            let promiseE = Promise<[String]> { resolve, _ in
                delay(time: 0) {
                    resolve(["E"])
                }
            }

            let promiseF = Promise<[Int: String]> { _, reject in
                delay(time: 0) {
                    reject(TestError.testFailed)
                }
            }


            let allSettledPromise = Promise<(Int, String, Bool, Double, [String], [Int: String])>.allSettled(promiseA, promiseB, promiseC, promiseD, promiseE, promiseF)

            allSettledPromise.then { _ in
                expectation.fulfill()
            }
            .catch { error -> Void in
                XCTFail("Promise.allSettled should not reject, but caught error: \(error)")
            }
            .finally {
                finallyExpectation.fulfill()
            }

            wait(for: [expectation, finallyExpectation], timeout: 5.0, enforceOrder: true)
        }
    }
}
