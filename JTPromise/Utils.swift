//
//  Utils.swift
//  JTPromise
//
//  Created by xinghanjie on 2024/10/3.
//

import Foundation

enum PromiseError: Error {
    case emptyPromises
}

final class PromiseLock {
    
    private var unfairLock = os_unfair_lock()
    
    func lock() {
        os_unfair_lock_lock(&unfairLock)
    }
    
    func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }
}
