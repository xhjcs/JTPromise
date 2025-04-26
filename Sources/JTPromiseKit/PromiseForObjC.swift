//
//  PromiseForObjC.swift
//  JTPromise
//
//  Created by xinghanjie on 2024/9/29.
//

import Foundation

extension PromiseError: CustomNSError {
    static var errorDomain: String {
        return "com.xhjcs.Promise.Error"
    }

    var errorCode: Int {
        return rawValue
    }

    var errorUserInfo: [String: Any] {
        var userInfo = [String: Any]()
        switch self {
        case .emptyPromises:
            userInfo[NSLocalizedDescriptionKey] = "The array of promises is empty."
        case .impossible:
            userInfo[NSLocalizedDescriptionKey] = "It's impossible."
        }
        return userInfo
    }
}

@objc public class JTPromiseSettledResult: NSObject {
    @objc public let result: Any?
    @objc public let error: Error?

    init(result: Any?) {
        self.result = result
        error = nil
    }

    init(error: Error) {
        result = nil
        self.error = error
    }
}

@objc public final class JTPromise: NSObject {
    public let base: Promise<Any?>

    public required init(base: Promise<Any?>) {
        self.base = base
    }

    @objc public static func resolve(_ value: Any?) -> JTPromise {
        return self.init(base: Promise(resolve: value))
    }

    @objc public static func reject(_ error: Error) -> JTPromise {
        return self.init(base: Promise(reject: error))
    }

    @objc public static func promise(executor: @escaping (_ resolve: @escaping (_ value: Any?) -> Void, _ reject: @escaping (_ error: Error) -> Void) -> Void) -> JTPromise {
        return self.init(base: Promise(executor: executor))
    }

    @discardableResult
    @objc public func then(_ handler: @escaping (_ value: Any?) -> Any?) -> JTPromise {
        let swiftPromise = base.then { value in
            let nextValue = handler(value)
            if let nextPromise = nextValue as? JTPromise {
                return nextPromise.base
            }
            return Promise(resolve: nextValue)
        }
        return JTPromise(base: swiftPromise)
    }

    @discardableResult
    @objc public func `catch`(_ handler: @escaping (_ error: Error) -> Any?) -> JTPromise {
        let swiftPromise = base.catch { error -> Promise<Any?> in
            let nextValue = handler(error)
            if let nextPromise = nextValue as? JTPromise {
                return nextPromise.base
            }
            return Promise(resolve: nextValue)
        }
        return JTPromise(base: swiftPromise)
    }

    @discardableResult
    @objc public func finally(_ handler: @escaping () -> Void) -> JTPromise {
        return JTPromise(base: base.finally(handler))
    }

    @objc public static func all(_ promises: [JTPromise]) -> JTPromise {
        let swiftPromises = promises.map { $0.base }
        let newPromise = Promise.all(swiftPromises).then { $0 as Any? }
        return JTPromise(base: newPromise)
    }

    @objc public static func allSettled(_ promises: [JTPromise]) -> JTPromise {
        let swiftPromises = promises.map { $0.base }
        let newPromise = Promise.allSettled(swiftPromises).then { values -> Any? in
            values.map {
                switch $0 {
                case let .fulfilled(result):
                    return JTPromiseSettledResult(result: result)
                case let .rejected(error):
                    return JTPromiseSettledResult(error: error)
                }
            } as NSArray
        }
        return JTPromise(base: newPromise)
    }

    @objc public static func any(_ promises: [JTPromise]) -> JTPromise {
        let swiftPromises = promises.map { $0.base }
        return JTPromise(base: Promise.any(swiftPromises))
    }

    @objc public static func race(_ promises: [JTPromise]) -> JTPromise {
        let swiftPromises = promises.map { $0.base }
        return JTPromise(base: Promise.race(swiftPromises))
    }
}
