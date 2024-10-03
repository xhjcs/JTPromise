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

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncPromiseInitializationWithValue() {
        let promise = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(42)
            })
        }

        let expectation = PromiseExpectation(description: "Promise is fulfilled with value")

        promise.then { value in
            XCTAssertEqual(value, 42)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testPromiseInitializationWithError() {
        let promise = Promise<Int>(reject: TestError.testFailed)

        let expectation = PromiseExpectation(description: "Promise is rejected with error")

        promise.catch { error -> Void in
            XCTAssertEqual(error as? TestError, TestError.testFailed)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncPromiseInitializationWithError() {
        let promise = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                reject(TestError.testFailed)
            })
        }

        let expectation = PromiseExpectation(description: "Promise is rejected with error")

        promise.catch { error -> Void in
            XCTAssertEqual(error as? TestError, TestError.testFailed)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
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

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncThenHandler() {
        let promise = Promise { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(10)
            })
        }

        let expectation = PromiseExpectation(description: "Promise then handler is called")

        promise.then { value -> Int in
            XCTAssertEqual(value, 10)
            return value * 2
        }.then { newValue in
            XCTAssertEqual(newValue, 20)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
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

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncThenHandlerWithPromiseReturn() {
        let promise = Promise { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(10)
            })
        }

        let expectation = PromiseExpectation(description: "Promise then handler with Promise return is called")

        promise.then { value -> Promise<Int> in
            XCTAssertEqual(value, 10)
            return Promise(resolve: value * 3)
        }.then { newValue in
            XCTAssertEqual(newValue, 30)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncThenHandlerWithAsyncPromiseReturn() {
        let promise = Promise { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(10)
            })
        }

        let expectation = PromiseExpectation(description: "Promise then handler with Promise return is called")

        promise.then { value -> Promise<Int> in
            XCTAssertEqual(value, 10)
            return Promise { resolve, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    resolve(value * 3)
                })
            }
        }.then { newValue in
            XCTAssertEqual(newValue, 30)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
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

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncCatchHandler() {
        let promise = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                reject(TestError.testFailed)
            })
        }

        let expectation = PromiseExpectation(description: "Promise catch handler is called")

        promise.catch { error -> Void in
            XCTAssertEqual(error as? TestError, TestError.testFailed)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testThenThrowError() {
        let promise = Promise(resolve: 10)
        let thenExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")
        
        promise.then { value in
            thenExpectation.fulfill()
            XCTAssertTrue(value == 10)
            throw TestError.testFailed
        }.catch { error -> Void in
            catchExpectation.fulfill()
            XCTAssertTrue((error as! TestError) == .testFailed)
        }
        
        wait(for: [thenExpectation, catchExpectation], timeout: 1.0)
    }
    
    func testAsyncThenThrowError() {
        let promise = Promise { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(10)
            })
        }
        
        let thenExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")
        
        promise.then { value in
            thenExpectation.fulfill()
            XCTAssertTrue(value == 10)
            throw TestError.testFailed
        }.catch { error -> Void in
            catchExpectation.fulfill()
            XCTAssertTrue((error as! TestError) == .testFailed)
        }
        
        wait(for: [thenExpectation, catchExpectation], timeout: 1.0)
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

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncCatchHandlerWithValueReturn() {
        let promise = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                reject(TestError.testFailed)
            })
        }

        let expectation = PromiseExpectation(description: "Promise catch handler returns a new value")

        promise.catch { error -> Int in
            XCTAssertEqual(error as? TestError, TestError.testFailed)
            return 42
        }.then { value in
            XCTAssertEqual(value, 42)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFinallyHandler() {
        let promise = Promise(resolve: "Success")

        let expectation = PromiseExpectation(description: "Promise finally handler is called")

        promise.finally {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncFinallyHandler() {
        let promise = Promise<String> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                resolve("Success")
            })
        }

        let expectation = PromiseExpectation(description: "Promise finally handler is called")

        promise.finally {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
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

        wait(for: [expectation, catchExpectation], timeout: 1.0)
    }

    func testAsyncFinallyHandlerAfterCatch() {
        let promise = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                reject(TestError.testFailed)
            })
        }

        let catchExpectation = PromiseExpectation(description: "Promise catch handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise.catch { _ in
            // Error handled
            catchExpectation.fulfill()
        }.finally {
            expectation.fulfill()
        }

        wait(for: [expectation, catchExpectation], timeout: 1.0)
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

        wait(for: [expectation, thenExpectation], timeout: 1.0)
    }

    func testAsyncFinallyHandlerAfterThanAndCatch() {
        let promise = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                reject(TestError.testFailed)
            })
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

        wait(for: [expectation, catchExpectation], timeout: 1.0)
    }

    func testVoidCatch() {
        let promise = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                reject(TestError.testFailed)
            })
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

        wait(for: [expectation, thenExpectation, catchExpectation], timeout: 1.0)
    }

    func testValueCatch() {
        let promise = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                reject(TestError.testFailed)
            })
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

        wait(for: [expectation, catchExpectation, thenExpectation], timeout: 1.0)
    }

    func testPromiseCatch() {
        let promise = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                reject(TestError.testFailed)
            })
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

        wait(for: [expectation, catchExpectation, thenExpectation], timeout: 1.0)
    }

    func testPromiseCatchNextCatch() {
        let promise = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                reject(TestError.testFailed)
            })
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

        wait(for: [expectation, catchExpectation, thenExpectation], timeout: 1.0)
    }

    func testVoidThenAndThen() {
        let promise = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(10)
            })
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

        wait(for: [expectation, thenExpectation, then1Expectation], timeout: 1.0)
    }

    func testValueThenAndThen() {
        let promise = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(10)
            })
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

        wait(for: [expectation, thenExpectation, then1Expectation], timeout: 1.0)
    }

    func testPromiseThenAndThen() {
        let promise = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(10)
            })
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

        wait(for: [expectation, thenExpectation, then1Expectation], timeout: 1.0)
    }

    func testAsyncPromiseThenAndThen() {
        let promise = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(10)
            })
        }

        let thenExpectation = PromiseExpectation(description: "Promise then handler is called")
        let then1Expectation = PromiseExpectation(description: "Promise then handler is called")
        let expectation = PromiseExpectation(description: "Promise finally handler is called after catch")

        promise
            .then({ value in
                XCTAssertNotNil(value)
                thenExpectation.fulfill()
                return Promise<String> { resolve, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        resolve("10")
                    })
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

        wait(for: [expectation, thenExpectation, then1Expectation], timeout: 1.0)
    }

    func testErrorPromiseThenAndThen() {
        let promise = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(10)
            })
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        reject(TestError.testFailed)
                    })
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

        wait(for: [expectation, thenExpectation, then1Expectation, catchExpectation], timeout: 1.0)
    }

    // 测试 `resolve` 和 `reject` 在多线程下的竞争，确保状态只会被变更一次
    func testPromiseConcurrentStateChange() {
        // 用于标识状态是否被改变
        var stateChangedCount = 0
        var isSuccess: Bool = true
        let promise = Promise<Int> { resolve, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                // 同时进行 50 次 `resolve` 和 `reject` 调用
                DispatchQueue.concurrentPerform(iterations: 50) { index in
                    if index % 2 == 0 {
                        DispatchQueue.global().async(flags: .barrier) {
                            isSuccess = true
                            if isSuccess {
                                stateChangedCount += 1
                            }
                        }
                        resolve(index)
                    } else {
                        DispatchQueue.global().async(flags: .barrier) {
                            isSuccess = false
                            if !isSuccess {
                                stateChangedCount += 1
                            }
                        }
                        reject(TestError.testFailed)
                    }
                }
            })
        } // 空的 Promise 实例，用于后续手动 resolve 或 reject
        let expectation = PromiseExpectation(description: "Promise state should only change once")

        // 创建一个 dispatch group 来跟踪所有线程的状态
        let group = DispatchGroup()
        let syncGroup = DispatchGroup()

        // 开启 100 个线程同时调用 `resolve` 和 `reject`
        for _ in 0 ..< 50 {
            syncGroup.enter()
            DispatchQueue.global().async(group: group) {
                promise.then { _ in
                    DispatchQueue.global().async(flags: .barrier) {
                        stateChangedCount -= 1
                        syncGroup.leave()
                    }
                }
            }
            DispatchQueue.global().async(group: group) {
                promise.catch { _ in
                    DispatchQueue.global().async(flags: .barrier) {
                        stateChangedCount -= 1
                        syncGroup.leave()
                    }
                }
            }
        }

        group.notify(queue: .main) {
            // 确保 `then` 或 `catch` 处理程序只调用一次
            XCTAssertEqual(stateChangedCount, 0, "Promise state changed multiple times")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
    }

    // 测试多线程下 `fulfill` 的竞争
    func testConcurrentFulfillCalls() {
        let promise = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                let group = DispatchGroup()
                for _ in 0 ..< 100 {
                    group.enter()
                    DispatchQueue.global().async {
                        resolve(42)
                        group.leave()
                    }
                }
            })
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

        wait(for: [expectation], timeout: 2)
    }

    // 测试多线程下 `reject` 的竞争
    func testConcurrentRejectCalls() {
        let promise = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                let group = DispatchGroup()
                for _ in 0 ..< 100 {
                    group.enter()
                    DispatchQueue.global().async {
                        reject(TestError.testFailed)
                        group.leave()
                    }
                }
            })
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

        wait(for: [expectation], timeout: 2)
    }

    // 测试 `resolve` 和 `reject` 的并发调用，确保最终只发生一种情况
    func testConcurrentResolveAndReject() {
        let promise = Promise<Int> { resolve, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                let group = DispatchGroup()
                for _ in 0 ..< 100 {
                    group.enter()
                    DispatchQueue.global().async {
                        resolve(42)
                        group.leave()
                    }
                    group.enter()
                    DispatchQueue.global().async {
                        reject(TestError.testFailed)
                        group.leave()
                    }
                }
            })
        }
        let expectation = PromiseExpectation(description: "Either resolve or reject should succeed, not both")

        var resolveCount = 0
        var rejectCount = 0

        promise.then { _ in
            resolveCount += 1
        }.catch { _ in
            rejectCount += 1
        }.finally {
            XCTAssertEqual(resolveCount + rejectCount, 1, "Only one of resolve or reject should succeed")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
    }
}
