//
//  __PromiseForObjC__.swift
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
        }
        return userInfo
    }
}

@objc(JTPromiseSettledResult)
public class __PromiseSettledResultForObjC__: NSObject {
    @objc public let result: AnyObject?
    @objc public let error: Error?

    init(result: AnyObject?) {
        self.result = result
        error = nil
    }

    init(error: Error) {
        result = nil
        self.error = error
    }
}

@objc(JTPromise)
public final class __PromiseForObjC__: NSObject {
    private let promise: Promise<AnyObject?>

    required init(promise: Promise<AnyObject?>) {
        self.promise = promise
    }

    @objc public static func resolve(_ value: AnyObject?) -> __PromiseForObjC__ {
        return self.init(promise: Promise(resolve: value))
    }

    @objc public static func reject(_ error: Error) -> __PromiseForObjC__ {
        return self.init(promise: Promise(reject: error))
    }

    @objc public static func promise(executor: @escaping (_ resolve: @escaping (_ value: AnyObject?) -> Void, _ reject: @escaping (_ error: Error) -> Void) -> Void) -> __PromiseForObjC__ {
        return self.init(promise: Promise(executor: executor))
    }

    @discardableResult
    @objc public func then(_ handler: @escaping (_ value: AnyObject?) -> AnyObject?) -> __PromiseForObjC__ {
        let swiftPromise = promise.then { value in
            let nextValue = handler(value)
            if let nextPromise = nextValue as? __PromiseForObjC__ {
                return nextPromise.promise
            }
            return Promise(resolve: nextValue)
        }
        return __PromiseForObjC__(promise: swiftPromise)
    }

    @discardableResult
    @objc public func `catch`(_ handler: @escaping (_ error: Error) -> AnyObject?) -> __PromiseForObjC__ {
        let swiftPromise = promise.catch { error -> Promise<AnyObject?> in
            let nextValue = handler(error)
            if let nextPromise = nextValue as? __PromiseForObjC__ {
                return nextPromise.promise
            }
            return Promise(resolve: nextValue)
        }
        return __PromiseForObjC__(promise: swiftPromise)
    }

    @discardableResult
    @objc public func finally(_ handler: @escaping () -> Void) -> __PromiseForObjC__ {
        return __PromiseForObjC__(promise: promise.finally(handler))
    }

    @objc public static func all(_ promises: [__PromiseForObjC__]) -> __PromiseForObjC__ {
        let swiftPromises = promises.map { $0.promise }
        let newPromise = Promise.all(swiftPromises).then { $0 as AnyObject? }
        return __PromiseForObjC__(promise: newPromise)
    }

    @objc public static func allSettled(_ promises: [__PromiseForObjC__]) -> __PromiseForObjC__ {
        let swiftPromises = promises.map { $0.promise }
        let newPromise = Promise.allSettled(swiftPromises).then { values -> AnyObject? in
            values.map {
                switch $0 {
                case let .fulfilled(result):
                    return __PromiseSettledResultForObjC__(result: result)
                case let .rejected(error):
                    return __PromiseSettledResultForObjC__(error: error)
                }
            } as NSArray
        }
        return __PromiseForObjC__(promise: newPromise)
    }

    @objc public static func any(_ promises: [__PromiseForObjC__]) -> __PromiseForObjC__ {
        let swiftPromises = promises.map { $0.promise }
        return __PromiseForObjC__(promise: Promise.any(swiftPromises))
    }

    @objc public static func race(_ promises: [__PromiseForObjC__]) -> __PromiseForObjC__ {
        let swiftPromises = promises.map { $0.promise }
        return __PromiseForObjC__(promise: Promise.race(swiftPromises))
    }
}
