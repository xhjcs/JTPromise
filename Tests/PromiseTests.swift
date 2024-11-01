//
//  JTPromiseTests.swift
//  JTPromiseExampleTests
//
//  Created by xinghanjie on 2024/10/1.
//

@testable import JTPromise
import XCTest

final class PromiseTests: XCTestCase {
    func testPromiseInitializationWithValue() {
        let promise = Promise(resolve: 42)

        let expectation = PromiseExpectation(description: "Promise is fulfilled with value")

        promise.then { value in
            XCTAssertEqual(value, 42)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncPromiseInitializationWithValue() {
        let promise = Promise<Int> { resolve, _ in
            delay(time: 0.5) {
                resolve(42)
            }
        }

        let expectation = PromiseExpectation(description: "Promise is fulfilled with value")

        promise.then { value in
            XCTAssertEqual(value, 42)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testPromiseInitializationWithError() {
        let promise = Promise<Int>(reject: TestError.testFailed)

        let expectation = PromiseExpectation(description: "Promise is rejected with error")

        promise.catch { error -> Void in
            XCTAssertEqual(error as? TestError, TestError.testFailed)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncPromiseInitializationWithError() {
        let promise = Promise<Int> { _, reject in
            delay(time: 0.5) {
                reject(TestError.testFailed)
            }
        }

        let expectation = PromiseExpectation(description: "Promise is rejected with error")

        promise.catch { error -> Void in
            XCTAssertEqual(error as? TestError, TestError.testFailed)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testThenHandler() {
        let promise = Promise(resolve: 10)

        let expectation = PromiseExpectation(description: "Promise then handler is called")

        promise.then { value -> Int in
            XCTAssertEqual(value, 10)
            return value * 2
        }.then { newValue in
            XCTAssertEqual(newValue, 20)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncThenHandler() {
        let promise = Promise { resolve, _ in
            delay(time: 0.5) {
                resolve(10)
            }
        }

        let expectation = PromiseExpectation(description: "Promise then handler is called")

        promise.then { value -> Int in
            XCTAssertEqual(value, 10)
            return value * 2
        }.then { newValue in
            XCTAssertEqual(newValue, 20)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testThenHandlerWithPromiseReturn() {
        let promise = Promise(resolve: 10)

        let expectation = PromiseExpectation(description: "Promise then handler with Promise return is called")

        promise.then { value -> Promise<Int> in
            XCTAssertEqual(value, 10)
            return Promise(resolve: value * 3)
        }.then { newValue in
            XCTAssertEqual(newValue, 30)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncThenHandlerWithPromiseReturn() {
        let promise = Promise { resolve, _ in
            delay(time: 0.5) {
                resolve(10)
            }
        }

        let expectation = PromiseExpectation(description: "Promise then handler with Promise return is called")

        promise.then { value -> Promise<Int> in
            XCTAssertEqual(value, 10)
            return Promise(resolve: value * 3)
        }.then { newValue in
            XCTAssertEqual(newValue, 30)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncThenHandlerWithAsyncPromiseReturn() {
        let promise = Promise { resolve, _ in
            delay(time: 0.5) {
                resolve(10)
            }
        }

        let expectation = PromiseExpectation(description: "Promise then handler with Promise return is called")

        promise.then { value -> Promise<Int> in
            XCTAssertEqual(value, 10)
            return Promise { resolve, _ in
                delay(time: 0.3) {
                    resolve(value * 3)
                }
            }
        }.then { newValue in
            XCTAssertEqual(newValue, 30)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testCatchHandler() {
        let promise = Promise<Int> { _, reject in
            reject(TestError.testFailed)
        }

        let expectation = PromiseExpectation(description: "Promise catch handler is called")

        promise.catch { error -> Void in
            XCTAssertEqual(error as? TestError, TestError.testFailed)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncCatchHandler() {
        let promise = Promise<Int> { _, reject in
            delay(time: 0.5) {
                reject(TestError.testFailed)
            }
        }

        let expectation = PromiseExpectation(description: "Promise catch handler is called")

        promise.catch { error -> Void in
            XCTAssertEqual(error as? TestError, TestError.testFailed)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testThenThrowError() {
        let promise = Promise(resolve: 10)
        let thenExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")

        promise.then { value -> Void in
            thenExpectation.fulfill()
            XCTAssertTrue(value == 10)
            throw TestError.testFailed
        }.catch { error -> Void in
            catchExpectation.fulfill()
            XCTAssertTrue((error as! TestError) == .testFailed)
        }

        wait(for: [thenExpectation, catchExpectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncThenThrowError() {
        let promise = Promise { resolve, _ in
            delay(time: 0.5) {
                resolve(10)
            }
        }

        let thenExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")

        promise.then { value -> Void in
            thenExpectation.fulfill()
            XCTAssertTrue(value == 10)
            throw TestError.testFailed
        }.catch { error -> Void in
            catchExpectation.fulfill()
            XCTAssertTrue((error as! TestError) == .testFailed)
        }

        wait(for: [thenExpectation, catchExpectation], timeout: 1.0, enforceOrder: true)
    }

    func testCatchHandlerWithValueReturn() {
        let promise = Promise<Int> { _, reject in
            reject(TestError.testFailed)
        }

        let expectation = PromiseExpectation(description: "Promise catch handler returns a new value")

        promise.catch { error -> Int in
            XCTAssertEqual(error as? TestError, TestError.testFailed)
            return 42
        }.then { value in
            XCTAssertEqual(value, 42)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncCatchHandlerWithValueReturn() {
        let promise = Promise<Int> { _, reject in
            delay(time: 0.5) {
                reject(TestError.testFailed)
            }
        }

        let expectation = PromiseExpectation(description: "Promise catch handler returns a new value")

        promise.catch { error -> Int in
            XCTAssertEqual(error as? TestError, TestError.testFailed)
            return 42
        }.then { value in
            XCTAssertEqual(value, 42)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testFinallyHandler() {
        let promise = Promise(resolve: "Success")

        let expectation = PromiseExpectation(description: "Promise finally handler is called")

        promise.finally {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncFinallyHandler() {
        let promise = Promise<String> { resolve, _ in
            delay(time: 0.5) {
                resolve("Success")
            }
        }

        let expectation = PromiseExpectation(description: "Promise finally handler is called")

        promise.finally {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0, enforceOrder: true)
    }

    func testFinallyHandlerAfterCatch() {
        let promise = Promise<String> { _, reject in
            reject(TestError.testFailed)
        }

        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise.catch { _ in
            // Error handled
            catchExpectation.fulfill()
        }.finally {
            expectation.fulfill()
        }

        wait(for: [catchExpectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncFinallyHandlerAfterCatch() {
        let promise = Promise<Int> { _, reject in
            delay(time: 0.5) {
                reject(TestError.testFailed)
            }
        }

        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise.catch { _ in
            // Error handled
            catchExpectation.fulfill()
        }.finally {
            expectation.fulfill()
        }

        wait(for: [catchExpectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    func testFinallyHandlerAfterThanAndCatch() {
        let promise = Promise(resolve: 10)

        let thenExpectation = PromiseExpectation(description: "Promise then handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise
            .then({ _ in
                thenExpectation.fulfill()
                return Promise(resolve: 10)
            })
            .catch { _ in
                // Error handled
            }.finally {
                expectation.fulfill()
            }

        wait(for: [thenExpectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncFinallyHandlerAfterThanAndCatch() {
        let promise = Promise<Int> { _, reject in
            delay(time: 0.5) {
                reject(TestError.testFailed)
            }
        }

        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise
            .then({ value in
                XCTAssertNotNil(value)
                return Promise(resolve: 10)
            })
            .catch { _ in
                // Error handled
                catchExpectation.fulfill()
            }.finally {
                expectation.fulfill()
            }

        wait(for: [catchExpectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    func testVoidCatch() {
        let promise = Promise<Int> { _, reject in
            delay(time: 0.5) {
                reject(TestError.testFailed)
            }
        }

        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let thenExpectation = PromiseExpectation(description: "Promise then handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise
            .then({ value in
                XCTAssertNotNil(value)
                return Promise(resolve: 10)
            })
            .catch { _ in
                // Error handled
                catchExpectation.fulfill()
            }
            .then({ value in
                XCTAssertTrue(value == nil)
                thenExpectation.fulfill()
            })
            .finally {
                expectation.fulfill()
            }

        wait(for: [catchExpectation, thenExpectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    func testValueCatch() {
        let promise = Promise<Int> { _, reject in
            delay(time: 0.5) {
                reject(TestError.testFailed)
            }
        }

        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let thenExpectation = PromiseExpectation(description: "Promise then handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise
            .then({ value in
                XCTAssertNotNil(value)
                return Promise(resolve: 10)
            })
            .catch { _ in
                // Error handled
                catchExpectation.fulfill()
                return 10
            }
            .then({ value in
                XCTAssertTrue(value == 10)
                thenExpectation.fulfill()
            })
            .finally {
                expectation.fulfill()
            }

        wait(for: [catchExpectation, thenExpectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    func testPromiseCatch() {
        let promise = Promise<Int> { _, reject in
            delay(time: 0.5) {
                reject(TestError.testFailed)
            }
        }

        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let thenExpectation = PromiseExpectation(description: "Promise then handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise
            .then({ value in
                XCTAssertNotNil(value)
                return Promise(resolve: 10)
            })
            .catch { _ in
                // Error handled
                catchExpectation.fulfill()
                return Promise(resolve: 10)
            }
            .then({ value in
                XCTAssertTrue(value == 10)
                thenExpectation.fulfill()
            })
            .finally {
                expectation.fulfill()
            }

        wait(for: [catchExpectation, thenExpectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    func testPromiseCatchNextCatch() {
        let promise = Promise<Int> { _, reject in
            delay(time: 0.5) {
                reject(TestError.testFailed)
            }
        }

        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let thenExpectation = PromiseExpectation(description: "Promise then handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise
            .then({ value in
                XCTAssertNotNil(value)
                return Promise(resolve: 10)
            })
            .catch { _ in
                // Error handled
                catchExpectation.fulfill()
                return Promise(resolve: 10)
            }
            .catch { _ in
                // Error handled
                XCTAssert(false)
                return Promise(resolve: 10)
            }
            .then({ value in
                XCTAssertTrue(value == 10)
                thenExpectation.fulfill()
            })
            .finally {
                expectation.fulfill()
            }

        wait(for: [catchExpectation, thenExpectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    func testVoidThenAndThen() {
        let promise = Promise<Int> { resolve, _ in
            delay(time: 0.5) {
                resolve(10)
            }
        }

        let thenExpectation = PromiseExpectation(description: "Promise then handler is called")
        let then1Expectation = PromiseExpectation(description: "Promise then handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise
            .then({ value in
                XCTAssertNotNil(value)
                thenExpectation.fulfill()
            })
            .catch { _ in
                // Error handled
                XCTAssert(false)
                return Promise(resolve: 10)
            }
            .catch { _ in
                // Error handled
                XCTAssert(false)
                return Promise(resolve: 10)
            }
            .then({ value in
                XCTAssertTrue(value == nil)
                then1Expectation.fulfill()
            })
            .finally {
                expectation.fulfill()
            }

        wait(for: [thenExpectation, then1Expectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    func testValueThenAndThen() {
        let promise = Promise<Int> { resolve, _ in
            delay(time: 0.5) {
                resolve(10)
            }
        }

        let thenExpectation = PromiseExpectation(description: "Promise then handler is called")
        let then1Expectation = PromiseExpectation(description: "Promise then handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise
            .then({ value -> String in
                XCTAssertNotNil(value)
                thenExpectation.fulfill()
                return "10"
            })
            .catch { _ in
                // Error handled
                XCTAssert(false)
                return Promise(resolve: "101")
            }
            .catch { _ in
                // Error handled
                XCTAssert(false)
                return Promise(resolve: "102")
            }
            .then({ value in
                XCTAssertTrue(value == "10")
                then1Expectation.fulfill()
            })
            .finally {
                expectation.fulfill()
            }

        wait(for: [thenExpectation, then1Expectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    func testPromiseThenAndThen() {
        let promise = Promise<Int> { resolve, _ in
            delay(time: 0.5) {
                resolve(10)
            }
        }

        let thenExpectation = PromiseExpectation(description: "Promise then handler is called")
        let then1Expectation = PromiseExpectation(description: "Promise then handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise
            .then({ value in
                XCTAssertNotNil(value)
                thenExpectation.fulfill()
                return Promise(resolve: "10")
            })
            .catch { _ in
                // Error handled
                XCTAssert(false)
                return Promise(resolve: "101")
            }
            .catch { _ in
                // Error handled
                XCTAssert(false)
                return Promise(resolve: "102")
            }
            .then({ value in
                XCTAssertTrue(value == "10")
                then1Expectation.fulfill()
            })
            .finally {
                expectation.fulfill()
            }

        wait(for: [thenExpectation, then1Expectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    func testAsyncPromiseThenAndThen() {
        let promise = Promise<Int> { resolve, _ in
            delay(time: 0.5) {
                resolve(10)
            }
        }

        let thenExpectation = PromiseExpectation(description: "Promise then handler is called")
        let then1Expectation = PromiseExpectation(description: "Promise then handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise
            .then({ value in
                XCTAssertNotNil(value)
                thenExpectation.fulfill()
                return Promise<String> { resolve, _ in
                    delay(time: 0.1) {
                        resolve("10")
                    }
                }
            })
            .catch { _ in
                // Error handled
                XCTAssert(false)
                return Promise(resolve: "101")
            }
            .catch { _ in
                // Error handled
                XCTAssert(false)
                return Promise(resolve: "102")
            }
            .then({ value in
                XCTAssertTrue(value == "10")
                then1Expectation.fulfill()
            })
            .finally {
                expectation.fulfill()
            }

        wait(for: [thenExpectation, then1Expectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    func testErrorPromiseThenAndThen() {
        let promise = Promise<Int> { resolve, _ in
            delay(time: 0.5) {
                resolve(10)
            }
        }

        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let thenExpectation = PromiseExpectation(description: "Promise then handler is called")
        let then1Expectation = PromiseExpectation(description: "Promise then handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise
            .then({ value in
                XCTAssertNotNil(value)
                thenExpectation.fulfill()
                return Promise<String> { _, reject in
                    delay(time: 0.1) {
                        reject(TestError.testFailed)
                    }
                }
            })
            .catch { _ in
                // Error handled
                catchExpectation.fulfill()
                return Promise(resolve: "101")
            }
            .catch { _ in
                // Error handled
                XCTAssert(false)
                return Promise(resolve: "102")
            }
            .then({ value in
                XCTAssertTrue(value == "101")
                then1Expectation.fulfill()
            })
            .finally {
                expectation.fulfill()
            }

        wait(for: [thenExpectation, catchExpectation, then1Expectation, expectation], timeout: 1.0, enforceOrder: true)
    }

    // 测试 `resolve` 和 `reject` 在多线程下的竞争，确保状态只会被变更一次
    func testPromiseConcurrentStateChange() {
        // 用于标识状态是否被改变
        var stateChangedCount = 50
        let promise = Promise<Int> { resolve, reject in
            for index in 0..<stateChangedCount {
                delay(time: 0.5) {
                    if index % 2 == 0 {
                        resolve(index)
                    } else {
                        reject(TestError.testFailed)
                    }
                }
            }
        } // 空的 Promise 实例，用于后续手动 resolve 或 reject
        let expectation = PromiseExpectation(description: "Promise state should only change once")

        // 创建一个 dispatch group 来跟踪所有线程的状态
        let syncGroup = DispatchGroup()
        
        let lock = NSLock()

        // 开启 100 个线程同时调用 `resolve` 和 `reject`
        for _ in 0 ..< 50 {
            syncGroup.enter()
            delay(time: 0.0) {
                promise.then { _ in
                    delay(time: 0.0) {
                        lock.lock()
                        stateChangedCount -= 1
                        lock.unlock()
                        syncGroup.leave()
                    }
                }
            }
            delay(time: 0.0) {
                promise.catch { _ in
                    delay(time: 0.0) {
                        lock.lock()
                        stateChangedCount -= 1
                        lock.unlock()
                        syncGroup.leave()
                    }
                }
            }
        }

        syncGroup.notify(queue: .main) {
            // 确保 `then` 或 `catch` 处理程序只调用一次
            XCTAssertEqual(stateChangedCount, 0, "Promise state changed multiple times")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2, enforceOrder: true)
    }

    // 测试多线程下 `fulfill` 的竞争
    func testConcurrentFulfillCalls() {
        let promise = Promise<Int> { resolve, _ in
            delay(time: 1) {
                for _ in 0 ..< 10 {
                    delay(time: 0.0) {
                        resolve(42)
                    }
                }
            }
        }
        let expectation = PromiseExpectation(description: "Only one fulfill should succeed")

        var fulfillCount = 0

        promise.then { value in
            fulfillCount += 1
            XCTAssertEqual(value, 42, "Fulfill value should be 42")
        }.finally {
            XCTAssertEqual(fulfillCount, 1, "Promise should only fulfill once")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2, enforceOrder: true)
    }

    // 测试多线程下 `reject` 的竞争
    func testConcurrentRejectCalls() {
        let promise = Promise<Int> { _, reject in
            delay(time: 1) {
                for _ in 0 ..< 10 {
                    delay(time: 0) {
                        reject(TestError.testFailed)
                    }
                }
            }
        }
        let expectation = PromiseExpectation(description: "Only one reject should succeed")

        var rejectCount = 0

        promise.catch { error -> Void in
            rejectCount += 1
            XCTAssertEqual(error as? TestError, TestError.testFailed, "Error should be testFailure")
        }.finally {
            XCTAssertEqual(rejectCount, 1, "Promise should only reject once")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2, enforceOrder: true)
    }

    // 测试 `resolve` 和 `reject` 的并发调用，确保最终只发生一种情况
    func testDelayConcurrentResolveAndReject() {
        let promise = Promise<Int> { resolve, reject in
            delay(time: 1) {
                for _ in 0 ..< 10 {
                    delay(time: 0) {
                        resolve(42)
                    }
                    delay(time: 0) {
                        reject(TestError.testFailed)
                    }
                }
            }
        }
        let expectation = PromiseExpectation(description: "Either resolve or reject should succeed, not both")
        let finallyExpectation = PromiseExpectation(description: "finallyExpectation")

        var resolveCount = 0
        var rejectCount = 0

        promise.then { _ in
            resolveCount += 1
            expectation.fulfill()
        }.catch { _ -> Void in
            rejectCount += 1
            expectation.fulfill()
        }.finally {
            XCTAssertEqual(resolveCount + rejectCount, 1, "Only one of resolve or reject should succeed")
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 2, enforceOrder: true)
    }

    // 测试 `resolve` 和 `reject` 的并发调用，确保最终只发生一种情况
    func testConcurrentResolveAndReject() {
        for _ in 0 ..< 100 {
            var promises = [Promise<Int>]()
            for _ in 0 ..< 10 {
                let promise = Promise<Int> { resolve, reject in
                    for _ in 0 ..< 5 {
                        delay(time: 0) {
                            resolve(42)
                        }
                        delay(time: 0) {
                            reject(TestError.testFailed)
                        }
                    }
                }
                promises.append(promise)
            }

            for promise in promises {
                delay(time: 0) {
                    let expectation = PromiseExpectation(description: "Either resolve or reject should succeed, not both")
                    let finallyExpectation = PromiseExpectation(description: "finallyExpectation")

                    var resolveCount = 0
                    var rejectCount = 0

                    promise.then { _ in
                        resolveCount += 1
                        expectation.fulfill()
                    }.catch { _ -> Void in
                        rejectCount += 1
                        expectation.fulfill()
                    }.finally {
                        XCTAssertEqual(resolveCount + rejectCount, 1, "Only one of resolve or reject should succeed")
                        finallyExpectation.fulfill()
                    }

                    self.wait(for: [expectation, finallyExpectation], timeout: 2, enforceOrder: true)
                }
            }
        }
    }

    func testAsyncConcurrentResolveAndReject() {
        for _ in 0 ..< 100 {
            var promises = [Promise<Int>]()
            for _ in 0 ..< 10 {
                let promise = Promise<Int> { resolve, reject in
                    for _ in 0 ..< 5 {
                        delay(time: 0.1) {
                            resolve(42)
                        }
                        delay(time: 0.1) {
                            reject(TestError.testFailed)
                        }
                    }
                }
                promises.append(promise)
            }

            for promise in promises {
                delay(time: 0) {
                    let expectation = PromiseExpectation(description: "Either resolve or reject should succeed, not both")
                    let finallyExpectation = PromiseExpectation(description: "finallyExpectation")

                    var resolveCount = 0
                    var rejectCount = 0

                    promise.then { _ in
                        resolveCount += 1
                        expectation.fulfill()
                    }.catch { _ -> Void in
                        rejectCount += 1
                        expectation.fulfill()
                    }.finally {
                        XCTAssertEqual(resolveCount + rejectCount, 1, "Only one of resolve or reject should succeed")
                        finallyExpectation.fulfill()
                    }

                    self.wait(for: [expectation, finallyExpectation], timeout: 2, enforceOrder: true)
                }
            }
        }
    }

    // 测试 `resolve` 和 `reject` 的并发调用，确保最终只发生一种情况
    func testConcurrentRejectAndResolve() {
        for _ in 0 ..< 100 {
            var promises = [Promise<Int>]()
            for _ in 0 ..< 10 {
                let promise = Promise<Int> { resolve, reject in
                    for _ in 0 ..< 5 {
                        delay(time: 0) {
                            reject(TestError.testFailed)
                        }
                        delay(time: 0) {
                            resolve(42)
                        }
                    }
                }
                promises.append(promise)
            }

            for promise in promises {
                delay(time: 0) {
                    let expectation = PromiseExpectation(description: "Either resolve or reject should succeed, not both")
                    let finallyExpectation = PromiseExpectation(description: "finallyExpectation")

                    var resolveCount = 0
                    var rejectCount = 0

                    promise.then { _ in
                        resolveCount += 1
                        expectation.fulfill()
                    }.catch { _ -> Void in
                        rejectCount += 1
                        expectation.fulfill()
                    }.finally {
                        XCTAssertEqual(resolveCount + rejectCount, 1, "Only one of resolve or reject should succeed")
                        finallyExpectation.fulfill()
                    }

                    self.wait(for: [expectation, finallyExpectation], timeout: 2, enforceOrder: true)
                }
            }
        }
    }

    func testAsyncConcurrentRejectAndResolve() {
        for _ in 0 ..< 100 {
            var promises = [Promise<Int>]()
            for _ in 0 ..< 10 {
                let promise = Promise<Int> { resolve, reject in
                    for _ in 0 ..< 5 {
                        delay(time: 0.1) {
                            reject(TestError.testFailed)
                        }
                        delay(time: 0.1) {
                            resolve(42)
                        }
                    }
                }
                promises.append(promise)
            }
            
            for promise in promises {
                delay(time: 0) {
                    let expectation = PromiseExpectation(description: "Either resolve or reject should succeed, not both")
                    let finallyExpectation = PromiseExpectation(description: "finallyExpectation")

                    var resolveCount = 0
                    var rejectCount = 0

                    promise.then { _ in
                        resolveCount += 1
                        expectation.fulfill()
                    }.catch { _ -> Void in
                        rejectCount += 1
                        expectation.fulfill()
                    }.finally {
                        XCTAssertEqual(resolveCount + rejectCount, 1, "Only one of resolve or reject should succeed")
                        finallyExpectation.fulfill()
                    }

                    self.wait(for: [expectation, finallyExpectation], timeout: 2, enforceOrder: true)
                }
            }
        }
    }

    func testFinally() {
        let ex = PromiseExpectation(description: "ex")
        let ex1 = PromiseExpectation(description: "ex1")
        let promise = Promise(resolve: 101)
        promise.finally {
            ex.fulfill()
        }

        Promise<Int>(reject: TestError.testFailed)
            .finally {
                ex1.fulfill()
            }

        wait(for: [ex, ex1], timeout: 2, enforceOrder: true)
    }

    func testAsyncFinally() {
        let ex = PromiseExpectation(description: "ex")
        let ex1 = PromiseExpectation(description: "ex1")
        let promise = Promise { resolve, _ in
            delay(time: 0.1) {
                resolve(101)
            }
        }
        promise.finally {
            ex.fulfill()
        }

        Promise<Int> { _, reject in
            delay(time: 0.1) {
                reject(TestError.testFailed)
            }
        }
        .finally {
            ex1.fulfill()
        }

        wait(for: [ex, ex1], timeout: 2)
    }

    func testAsyncFinally1() {
        let ex = PromiseExpectation(description: "ex")
        let ex1 = PromiseExpectation(description: "ex1")
        let ex2 = PromiseExpectation(description: "ex1")
        let ex3 = PromiseExpectation(description: "ex1")
        let promise = Promise { resolve, _ in
            delay(time: 0.1) {
                resolve(101)
            }
        }
        promise.finally {
            ex.fulfill()
        }.then { _ in
            ex1.fulfill()
        }.catch { _ in
            XCTFail()
        }

        Promise<Int> { _, reject in
            delay(time: 0.1) {
                reject(TestError.testFailed)
            }
        }
        .finally {
            ex2.fulfill()
        }.then { _ in
            XCTFail()
        }.catch { _ in
            ex3.fulfill()
        }

        wait(for: [ex, ex1], timeout: 2, enforceOrder: true)
        wait(for: [ex2, ex3], timeout: 2, enforceOrder: true)
    }

    func testAsyncFinally2() {
        let ex = PromiseExpectation(description: "ex")
        let ex1 = PromiseExpectation(description: "ex1")
        let ex2 = PromiseExpectation(description: "ex1")
        let ex3 = PromiseExpectation(description: "ex1")
        let promise = Promise { resolve, _ in
            delay(time: 0.1) {
                resolve(101)
            }
        }
        promise.then { _ in
            ex.fulfill()
        }.catch { _ in
            XCTFail()
        }.finally {
            ex1.fulfill()
        }

        Promise<Int> { _, reject in
            delay(time: 0.1) {
                reject(TestError.testFailed)
            }
        }.then { _ in
            XCTFail()
        }.catch { _ in
            ex2.fulfill()
        }
        .finally {
            ex3.fulfill()
        }

        wait(for: [ex, ex1], timeout: 2, enforceOrder: true)
        wait(for: [ex2, ex3], timeout: 2, enforceOrder: true)
    }

    func testThenThrow() {
        let ex = PromiseExpectation(description: "")
        let ex1 = PromiseExpectation(description: "")
        let ex2 = PromiseExpectation(description: "")
        Promise<Int> { resolve, _ in
            delay(time: 0.1) {
                resolve(101)
            }
        }
        .then { _ in
            ex.fulfill()
            throw TestError.testFailed
        }
        .catch { error in
            XCTAssertEqual(error as! TestError, TestError.testFailed)
        }
        .then { _ in
            ex1.fulfill()
        }
        .finally {
            ex2.fulfill()
        }

        wait(for: [ex, ex1, ex2], timeout: 1, enforceOrder: true)
    }

    func testCatchThrow() {
        let ex = PromiseExpectation(description: "")
        let ex1 = PromiseExpectation(description: "")
        let ex2 = PromiseExpectation(description: "")
        Promise<Int> { _, reject in
            delay(time: 0.1) {
                reject(TestError.testFailed)
            }
        }
        .then { _ -> Void in
            XCTFail()
        }
        .catch { error -> Void in
            XCTAssertEqual(error as! TestError, TestError.testFailed)
            ex.fulfill()
            throw TestError.testFailed1
        }
        .then { _ -> Void in
            XCTFail()
        }
        .catch { error -> Void in
            XCTAssertEqual(error as! TestError, TestError.testFailed1)
            ex1.fulfill()
        }
        .finally {
            ex2.fulfill()
        }

        wait(for: [ex, ex1, ex2], timeout: 1, enforceOrder: true)
    }

    func testFinallyThrow() {
        let ex = PromiseExpectation(description: "")
        let ex1 = PromiseExpectation(description: "")
        Promise { resolve, _ in
            delay(time: 0.1) {
                resolve(101)
            }
        }
        .finally {
            ex.fulfill()
            throw TestError.testFailed
        }
        .then { _ -> Void in
            XCTFail()
        }
        .catch { error -> Void in
            XCTAssertEqual(error as! TestError, TestError.testFailed)
            ex1.fulfill()
        }

        wait(for: [ex, ex1], timeout: 1, enforceOrder: true)
    }

    func testFinallyThreadSafe() {
        for _ in 0 ..< 100 {
            var promises = [Promise<Int>]()
            for _ in 0 ..< 10 {
                let promise = Promise<Int> { resolve, reject in
                    for _ in 0 ..< 5 {
                        delay(time: 0) {
                            resolve(42)
                        }
                        delay(time: 0) {
                            reject(TestError.testFailed)
                        }
                    }
                }
                promises.append(promise)
            }

            for promise in promises {
                delay(time: 0) {
                    let expectation = PromiseExpectation(description: "Either resolve or reject should succeed, not both")
                    let expectation1 = PromiseExpectation(description: "Either resolve or reject should succeed, not both")
                    let finallyExpectation = PromiseExpectation(description: "finallyExpectation")

                    var resolveCount = 0
                    var rejectCount = 0

                    promise
                        .finally {
                            expectation.fulfill()
                        }
                        .then { _ in
                            resolveCount += 1
                            expectation1.fulfill()
                        }.catch { _ -> Void in
                            rejectCount += 1
                            expectation1.fulfill()
                        }.finally {
                            XCTAssertEqual(resolveCount + rejectCount, 1, "Only one of resolve or reject should succeed")
                            finallyExpectation.fulfill()
                        }

                    self.wait(for: [expectation, expectation1, finallyExpectation], timeout: 2, enforceOrder: true)
                }
            }
        }
    }
}
