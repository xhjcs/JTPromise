//
//  Utils.swift
//  JTPromise
//
//  Created by xinghanjie on 2024/10/3.
//

import Foundation

enum PromiseError: Int, Error {
    case emptyPromises = 1001
    case impossible = 1002
}

final class Lock {
    
    private var unfairLock = os_unfair_lock()
    
    func lock() {
        os_unfair_lock_lock(&unfairLock)
    }
    
    func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }
}

extension Promise {
    func asAny() -> Promise<Any> {
        return self.then { $0 as Any }
    }
}
