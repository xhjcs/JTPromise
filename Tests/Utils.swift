//
//  Utils.swift
//  JTPromiseExampleTests
//
//  Created by xinghanjie on 2024/10/1.
//

import Foundation
import XCTest

enum TestError: Error, Equatable {
    case testFailed
    case testFailed1
}

class PromiseExpectation: XCTestExpectation {
    private var fulfillCount = 0
    private let maxFulfillCount: Int
    private let lock = NSLock() // 添加一个锁来确保线程安全

    init(description: String, maxFulfillCount: Int = 1) {
        self.maxFulfillCount = maxFulfillCount
        super.init(description: description)
    }

    override func fulfill() {
        lock.lock() // 加锁，确保 fulfillCount 的操作是原子的
        fulfillCount += 1
        if fulfillCount > maxFulfillCount {
            lock.unlock()
            XCTFail("Expectation fulfilled more than the allowed count of \(maxFulfillCount)")
        } else {
            lock.unlock()
            super.fulfill()
        }
    }
}

func delay(time: TimeInterval, task: @escaping () -> Void) {
    Thread.detachNewThread {
        Thread.sleep(forTimeInterval: time)
        task()
    }
}
