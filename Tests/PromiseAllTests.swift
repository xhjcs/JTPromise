//
//  JTPromiseAllTests.swift
//  JTPromiseExampleTests
//
//  Created by xinghanjie on 2024/10/1.
//

@testable import JTPromise
import XCTest

final class PromiseAllTests: XCTestCase {
    // MARK: - Test Promise.all with Array

    func testPromiseAllWithArraySuccess() {
        let promise1 = Promise<Int>(resolve: 1)
        let promise2 = Promise<Int>(resolve: 2)
        let promise3 = Promise<Int>(resolve: 3)

        let allPromise = Promise.all([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.all with array should resolve with [1, 2, 3]")

        allPromise.then { results in
            XCTAssertEqual(results, [1, 2, 3])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.all should not reject")
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncPromiseAllWithArraySuccess() {
        let promise1 = Promise<Int>(resolve: 1)
        let promise2 = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                resolve(2)
            })
        }
        let promise3 = Promise<Int>(resolve: 3)

        let allPromise = Promise.all([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.all with array should resolve with [1, 2, 3]")

        allPromise.then { results in
            XCTAssertEqual(results, [1, 2, 3])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.all should not reject")
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testPromiseAllWithArrayFailure() {
        let promise1 = Promise<Int>(resolve: 1)
        let promise2 = Promise<Int>(reject: NSError(domain: "TestError", code: 1, userInfo: nil))
        let promise3 = Promise<Int>(resolve: 3)

        let allPromise = Promise.all([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.all with array should reject")

        allPromise.then { _ in
            XCTFail("Promise.all should not resolve")
        }.catch { error -> Void in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncPromiseAllWithArrayFailure() {
        let promise1 = Promise<Int>(resolve: 1)
        let promise2 = Promise<Int> { _, reject in
            reject(TestError.testFailed)
        }
        let promise3 = Promise<Int> { resolve, _ in
            resolve(2)
        }

        let allPromise = Promise.all([promise1, promise2, promise3])
        let expectation = PromiseExpectation(description: "Promise.all with array should reject")

        allPromise.then { _ in
            XCTFail("Promise.all should not resolve")
        }.catch { error -> Void in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testPromiseAllWithEmptyArray() {
        let allPromise = Promise.all([Promise<Int>]())
        let expectation = PromiseExpectation(description: "Promise.all with empty array should resolve with an empty array")

        allPromise.then { results in
            XCTAssertEqual(results, [])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.all should not reject")
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Test Promise.all with multiple types

    func testPromiseAllWithDifferentTypes() {
        let promiseA = Promise<String>(resolve: "A")
        let promiseB = Promise<Int>(resolve: 2)
        let promiseC = Promise<Bool> { resolve, _ in
            resolve(true)
        }

        let allPromise = Promise<(String, Int, Bool)>.all(promiseA, promiseB, promiseC)
        let expectation = PromiseExpectation(description: "Promise.all with different types should resolve with a tuple")

        allPromise.then { resultA, resultB, resultC in
            XCTAssertEqual(resultA, "A")
            XCTAssertEqual(resultB, 2)
            XCTAssertEqual(resultC, true)
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.all should not reject")
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncPromiseAllWithDifferentTypes() {
        let promiseA = Promise<String>(resolve: "A")
        let promiseB = Promise<Int>(resolve: 2)
        let promiseC = Promise<Bool> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                resolve(true)
            })
        }

        let allPromise = Promise<(String, Int, Bool)>.all(promiseA, promiseB, promiseC)
        let expectation = PromiseExpectation(description: "Promise.all with different types should resolve with a tuple")

        allPromise.then { resultA, resultB, resultC in
            XCTAssertEqual(resultA, "A")
            XCTAssertEqual(resultB, 2)
            XCTAssertEqual(resultC, true)
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.all should not reject")
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncErrorPromiseAllWithDifferentTypes() {
        let promiseA = Promise<String>(resolve: "A")
        let promiseB = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                reject(TestError.testFailed)
            })
        }
        let promiseC = Promise<Bool> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                resolve(true)
            })
        }

        let allPromise = Promise<(String, Int, Bool)>.all(promiseA, promiseB, promiseC)
        let expectation = PromiseExpectation(description: "Promise.all with different types should resolve with a tuple")

        allPromise.then { _, _, _ in
            XCTFail("Promise.all should not reject")
        }.catch { error -> Void in
            expectation.fulfill()
            XCTAssertTrue((error as! TestError) == TestError.testFailed)
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncPromiseAllCombineWithDifferentTypes() {
        let promise1 = Promise<Int>(resolve: 1)
        let promise2 = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                resolve(2)
            })
        }
        let promise3 = Promise<Int> { resolve, _ in
            resolve(2)
        }
        let promise4 = Promise<Int> { resolve, _ in
            resolve(5)
        }

        let allPromise = Promise.all([Promise.all([promise1, promise2]), Promise.all([promise3, promise4])])
        let expectation = PromiseExpectation(description: "Promise.all with array should reject")

        allPromise.then { value in
            XCTAssertTrue(value == [[1, 2], [2, 5]])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.all should not reject")
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncErrorPromiseAllCombineWithDifferentTypes() {
        let promise1 = Promise<Int>(resolve: 1)
        let promise2 = Promise<Int> { _, reject in
            reject(TestError.testFailed)
        }
        let promise3 = Promise<Int> { resolve, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                resolve(2)
            })
        }
        let promise4 = Promise<Int> { resolve, _ in
            resolve(5)
        }

        let allPromise = Promise.all([Promise.all([promise1, promise2]), Promise.all([promise3, promise4])])
        let expectation = PromiseExpectation(description: "Promise.all with array should reject")

        allPromise.then { _ in
            XCTFail("Promise.all should not resolve")
        }.catch { error -> Void in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testAsyncCatchErrorPromiseAllCombineWithDifferentTypes() {
        let promise1 = Promise<Int>(resolve: 1)
        let promise2 = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                reject(TestError.testFailed)
            })
        }
        let promise3 = Promise<Int> { resolve, _ in
            resolve(2)
        }
        let promise4 = Promise<Int> { resolve, _ in
            resolve(5)
        }

        let errorPromise = Promise.all([promise1, promise2]).catch { _ in
            [1, 2]
        }
        let allPromise = Promise.all([errorPromise, Promise.all([promise3, promise4])])
        let expectation = PromiseExpectation(description: "Promise.all with array should reject")

        allPromise.then { value in
            XCTAssertTrue(value == [[1, 2], [2, 5]])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.all should not reject")
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testFinallyPromiseAllCombineWithDifferentTypes() {
        let promise1 = Promise<Int>(resolve: 1)
        let promise2 = Promise<Int> { _, reject in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                reject(TestError.testFailed)
            })
        }
        let promise3 = Promise<Int> { resolve, _ in
            resolve(2)
        }
        let promise4 = Promise<Int> { resolve, _ in
            resolve(5)
        }

        let errorPromise = Promise.all([promise1, promise2]).catch { _ in
            [1, 2]
        }
        let allPromise = Promise.all([errorPromise, Promise.all([promise3, promise4])])
        let expectation = PromiseExpectation(description: "Promise.all with array should reject")
        let finallyExpectation = PromiseExpectation(description: "Promise.all with array should finally")

        allPromise.then { value in
            XCTAssertTrue(value == [[1, 2], [2, 5]])
            expectation.fulfill()
        }.catch { _ in
            XCTFail("Promise.all should not reject")
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 1.0)
    }

    // MARK: - 测试多线程并发操作 Promise.all

    func testAllPromisesConcurrency() {
        let expectation = PromiseExpectation(description: "Concurrent promises handling")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

        let promiseCount = 100
        var promises: [Promise<Int>] = []
        for i in 0 ..< promiseCount {
            promises.append(Promise<Int> { resolve, _ in
                DispatchQueue.global().asyncAfter(deadline: .now() + Double.random(in: 0.1 ... 0.5)) {
                    resolve(i)
                }
            })
        }

        let allPromise = Promise.all(promises)
        allPromise.then { results in
            XCTAssertEqual(results, Array(0 ..< promiseCount), "The result should match the expected values")
            expectation.fulfill()
        }.catch { error in
            XCTFail("All promises should succeed, but caught an error: \(error)")
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 5.0)
    }

    // MARK: - 测试 Promise.all 是否能够正确释放内存

    func testPromiseAllMemoryDeallocation() {
        let expectation = PromiseExpectation(description: "Promises deallocated")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")
        weak var weakPromise: Promise<[Int]>?

        autoreleasepool {
            let promise1 = Promise<Int> { resolve, _ in DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { resolve(1) } }
            let promise2 = Promise<Int> { resolve, _ in DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) { resolve(2) } }

            let allPromise = Promise.all([promise1, promise2])
            weakPromise = allPromise

            allPromise.then { results in
                XCTAssertEqual(results, [1, 2], "All promises should fulfill with correct values")
                expectation.fulfill()
            }.catch { error in
                XCTFail("All promises should succeed, but caught an error: \(error)")
            }.finally {
                finallyExpectation.fulfill()
            }
        }

        wait(for: [expectation, finallyExpectation], timeout: 1.0)
        XCTAssertNil(weakPromise, "The Promise.all should have been deallocated")
    }

    // MARK: - 多个线程同时监听一个 Promise.all 时的行为测试

    func testAllPromisesWithMultipleListeners() {
        let expectation1 = PromiseExpectation(description: "Listener 1 fulfilled")
        let expectation2 = PromiseExpectation(description: "Listener 2 fulfilled")
        let finallyExpectation1 = PromiseExpectation(description: "Concurrent promises handling")
        let finallyExpectation2 = PromiseExpectation(description: "Concurrent promises handling")

        let promise1 = Promise<Int> { resolve, _ in DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { resolve(1) } }
        let promise2 = Promise<Int> { resolve, _ in DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) { resolve(2) } }

        let allPromise = Promise.all([promise1, promise2])

        // 第一个监听者
        DispatchQueue.global().async {
            allPromise.then { results in
                XCTAssertEqual(results, [1, 2], "First listener should fulfill with correct values")
                expectation1.fulfill()
            }.catch { error in
                XCTFail("First listener caught an error: \(error)")
            }.finally {
                finallyExpectation1.fulfill()
            }
        }

        // 第二个监听者
        DispatchQueue.global().async {
            allPromise.then { results in
                XCTAssertEqual(results, [1, 2], "Second listener should fulfill with correct values")
                expectation2.fulfill()
            }.catch { error in
                XCTFail("Second listener caught an error: \(error)")
            }.finally {
                finallyExpectation2.fulfill()
            }
        }

        wait(for: [expectation1, expectation2, finallyExpectation1, finallyExpectation2], timeout: 2.0)
    }

    // MARK: - 测试所有 Promise 都在不同线程中调用 resolve 时的行为

    func testAllPromisesFulfilledConcurrently() {
        let expectation = PromiseExpectation(description: "All promises fulfilled concurrently")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

        let promiseCount = 100
        var promises: [Promise<Int>] = []

        // 创建多个 promise，每个 promise 都会在不同的线程中调用 resolve。
        for i in 0 ..< promiseCount {
            promises.append(Promise<Int> { resolve, _ in
                DispatchQueue.global().async {
                    resolve(i)
                }
            })
        }

        let allPromise = Promise.all(promises)

        allPromise.then { results in
            XCTAssertEqual(results, Array(0 ..< promiseCount), "The result should match the expected values")
            expectation.fulfill()
        }.catch { error in
            XCTFail("All promises should succeed, but caught an error: \(error)")
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 5.0)
    }

    // MARK: - 测试所有 Promise 都在不同线程中调用 reject 时的行为

    func testAllPromisesRejectedConcurrently() {
        let expectation = PromiseExpectation(description: "One promise rejected concurrently")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

        let promiseCount = 100
        var promises: [Promise<Int>] = []

        // 创建多个 promise，其中一个会被拒绝
        for i in 0 ..< promiseCount {
            promises.append(Promise<Int> { resolve, reject in
                DispatchQueue.global().async {
                    if i == 42 { // 随便选择一个 Promise 进行拒绝
                        reject(TestError.testFailed)
                    } else {
                        resolve(i)
                    }
                }
            })
        }

        let allPromise = Promise.all(promises)

        allPromise.then { _ in
            XCTFail("One promise should be rejected, but allPromise fulfilled")
        }.catch { error -> Void in
            if let error = error as? TestError, error == .testFailed {
                expectation.fulfill()
            } else {
                XCTFail("Expected TestError.rejected but got \(error)")
            }
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 5.0)
    }

    // MARK: - 测试多线程混合调用 resolve 和 reject 时 Promise.all 的行为

    func testAllPromisesMixedConcurrently() {
        let expectation = PromiseExpectation(description: "Mixed promises fulfilled or rejected concurrently")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

        let promiseCount = 100
        var promises: [Promise<Int>] = []

        // 创建多个 promise，其中一部分会成功，另一部分会被拒绝
        for i in 0 ..< promiseCount {
            promises.append(Promise<Int> { resolve, reject in
                DispatchQueue.global().async {
                    if i % 2 == 0 { // 偶数 Promise 成功
                        resolve(i)
                    } else { // 奇数 Promise 被拒绝
                        reject(TestError.testFailed)
                    }
                }
            })
        }

        let allPromise = Promise.all(promises)

        allPromise.then { _ in
            XCTFail("At least one promise should be rejected, but allPromise fulfilled")
        }.catch { _ in
            expectation.fulfill()
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 5.0)
    }

    // MARK: - 测试六个 Promise 都在不同线程中调用 resolve 时的行为

    func testAllSixPromisesFulfilledConcurrently() {
        let expectation = PromiseExpectation(description: "All six promises fulfilled concurrently")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

        // 创建六个 Promise，每个都在不同线程中调用 resolve。
        let promiseA = Promise<Int> { resolve, _ in
            DispatchQueue.global().async {
                resolve(1)
            }
        }

        let promiseB = Promise<String> { resolve, _ in
            DispatchQueue.global().async {
                resolve("B")
            }
        }

        let promiseC = Promise<Bool> { resolve, _ in
            DispatchQueue.global().async {
                resolve(true)
            }
        }

        let promiseD = Promise<Double> { resolve, _ in
            DispatchQueue.global().async {
                resolve(4.0)
            }
        }

        let promiseE = Promise<[String]> { resolve, _ in
            DispatchQueue.global().async {
                resolve(["E"])
            }
        }

        let promiseF = Promise<[Int: String]> { resolve, _ in
            DispatchQueue.global().async {
                resolve([1: "F"])
            }
        }

        let allPromise = Promise<(Int, String, Bool, Double, [String], [Int: String])>.all(promiseA, promiseB, promiseC, promiseD, promiseE, promiseF)

        allPromise.then { result in
            let (valueA, valueB, valueC, valueD, valueE, valueF) = result
            XCTAssertEqual(valueA, 1)
            XCTAssertEqual(valueB, "B")
            XCTAssertEqual(valueC, true)
            XCTAssertEqual(valueD, 4.0)
            XCTAssertEqual(valueE, ["E"])
            XCTAssertEqual(valueF, [1: "F"])
            expectation.fulfill()
        }.catch { error in
            XCTFail("All promises should fulfill successfully, but caught an error: \(error)")
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 5.0)
    }

    // MARK: - 测试六个 Promise 中任意一个在不同线程中调用 reject 时的行为

    func testAllSixPromisesRejectedConcurrently() {
        let expectation = PromiseExpectation(description: "One of six promises rejected concurrently")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

        // 创建六个 Promise，其中一个会在不同线程中调用 reject。
        let promiseA = Promise<Int> { resolve, _ in
            DispatchQueue.global().async {
                resolve(1)
            }
        }

        let promiseB = Promise<String> { resolve, _ in
            DispatchQueue.global().async {
                resolve("B")
            }
        }

        let promiseC = Promise<Bool> { resolve, _ in
            DispatchQueue.global().async {
                resolve(true)
            }
        }

        let promiseD = Promise<Double> { _, reject in
            DispatchQueue.global().async {
                reject(TestError.testFailed)
            }
        }

        let promiseE = Promise<[String]> { resolve, _ in
            DispatchQueue.global().async {
                resolve(["E"])
            }
        }

        let promiseF = Promise<[Int: String]> { resolve, _ in
            DispatchQueue.global().async {
                resolve([1: "F"])
            }
        }

        let allPromise = Promise<(Int, String, Bool, Double, [String], [Int: String])>.all(promiseA, promiseB, promiseC, promiseD, promiseE, promiseF)

        allPromise.then { _ in
            XCTFail("One promise should be rejected, but allPromise fulfilled")
        }.catch { error -> Void in
            if let error = error as? TestError, error == .testFailed {
                expectation.fulfill()
            } else {
                XCTFail("Expected TestError.rejected but got \(error)")
            }
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 5.0)
    }

    // MARK: - 测试六个 Promise 中混合调用 resolve 和 reject 时的行为

    func testAllSixPromisesMixedConcurrently() {
        let expectation = PromiseExpectation(description: "Mixed six promises fulfilled or rejected concurrently")
        let finallyExpectation = PromiseExpectation(description: "Concurrent promises handling")

        // 创建六个 Promise，其中一部分会被拒绝，一部分会成功。
        let promiseA = Promise<Int> { resolve, _ in
            DispatchQueue.global().async {
                resolve(1)
            }
        }

        let promiseB = Promise<String> { resolve, _ in
            DispatchQueue.global().async {
                resolve("B")
            }
        }

        let promiseC = Promise<Bool> { resolve, _ in
            DispatchQueue.global().async {
                resolve(true)
            }
        }

        let promiseD = Promise<Double> { _, reject in
            DispatchQueue.global().async {
                reject(TestError.testFailed)
            }
        }

        let promiseE = Promise<[String]> { resolve, _ in
            DispatchQueue.global().async {
                resolve(["E"])
            }
        }

        let promiseF = Promise<[Int: String]> { _, reject in
            DispatchQueue.global().async {
                reject(TestError.testFailed)
            }
        }

        let allPromise = Promise<(Int, String, Bool, Double, [String], [Int: String])>.all(promiseA, promiseB, promiseC, promiseD, promiseE, promiseF)

        allPromise.then { _ in
            XCTFail("At least one promise should be rejected, but allPromise fulfilled")
        }.catch { _ in
            expectation.fulfill()
        }.finally {
            finallyExpectation.fulfill()
        }

        wait(for: [expectation, finallyExpectation], timeout: 5.0)
    }
}
