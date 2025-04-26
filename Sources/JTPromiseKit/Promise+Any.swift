//
//  Promise+Any.swift
//  JTPromise
//
//  Created by xinghanjie on 2024/9/29.
//

import Foundation

public extension Promise {
    static func any(_ promises: [Promise<Value>]) -> Promise<Value> {
        guard !promises.isEmpty else {
            return Promise(reject: PromiseError.emptyPromises)
        }
        var remaining = promises.count
        let lock = Lock()
        return Promise { resolve, reject in
            for promise in promises {
                promise
                    .then(resolve)
                    .catch { error -> Void in
                        lock.lock()
                        remaining -= 1
                        let rejected = remaining == 0
                        lock.unlock()
                        if rejected {
                            reject(error)
                        }
                    }
            }
        }
    }
}
