//
//  Promise+Race.swift
//  JTPromise
//
//  Created by xinghanjie on 2024/9/29.
//

import Foundation

public extension Promise {
    static func race(_ promises: [Promise<Value>]) -> Promise<Value> {
        guard !promises.isEmpty else {
            return Promise(reject: PromiseError.emptyPromises)
        }
        return Promise { resolve, reject in
            for promise in promises {
                promise.then(resolve).catch(reject)
            }
        }
    }
}
