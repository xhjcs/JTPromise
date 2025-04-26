//
//  Promise+All.swift
//  JTPromise
//
//  Created by xinghanjie on 2024/9/29.
//

import Foundation

public extension Promise {
    static func all(_ promises: [Promise<Value>]) -> Promise<[Value]> {
        guard !promises.isEmpty else {
            return Promise<[Value]>(resolve: [Value]())
        }
        let count = promises.count
        var results = [Value?](repeating: nil, count: count)
        var remaining = count
        let lock = Lock()
        return Promise<[Value]> { resolve, reject in
            for i in 0 ..< count {
                let promise = promises[i]
                promise.then { value in
                    lock.lock()
                    results[i] = value
                    remaining -= 1
                    let resolved = remaining == 0
                    lock.unlock()
                    if resolved {
                        resolve(results.compactMap { $0 })
                    }
                }.catch(reject)
            }
        }
    }
    
    static func all<A, B>(_ promiseA: Promise<A>, _ promiseB: Promise<B>) -> Promise<(A, B)> {
        let lock = Lock()
        return Promise<(A, B)> { resolve, reject in
            var resultA: A?
            var resultB: B?

            func handleResult(handler: () -> Void) {
                lock.lock()
                handler()
                if let resultA = resultA, let resultB = resultB {
                    lock.unlock()
                    resolve((resultA, resultB))
                } else {
                    lock.unlock()
                }
            }

            promiseA.then { value in
                handleResult {
                    resultA = value
                }
            }.catch(reject)

            promiseB.then { value in
                handleResult {
                    resultB = value
                }
            }.catch(reject)
        }
    }

    static func all<A, B, C>(_ promiseA: Promise<A>, _ promiseB: Promise<B>, _ promiseC: Promise<C>) -> Promise<(A, B, C)> {
        return all(all(promiseA, promiseB), promiseC)
            .then { ($0.0.0, $0.0.1, $0.1) }
    }

    static func all<A, B, C, D>(_ promiseA: Promise<A>, _ promiseB: Promise<B>, _ promiseC: Promise<C>, _ promiseD: Promise<D>) -> Promise<(A, B, C, D)> {
        all(all(promiseA, promiseB), promiseC, promiseD)
            .then { ($0.0.0, $0.0.1, $0.1, $0.2) }
    }

    static func all<A, B, C, D, E>(_ promiseA: Promise<A>, _ promiseB: Promise<B>, _ promiseC: Promise<C>, _ promiseD: Promise<D>, _ promiseE: Promise<E>) -> Promise<(A, B, C, D, E)> {
        all(all(promiseA, promiseB), promiseC, promiseD, promiseE)
            .then { ($0.0.0, $0.0.1, $0.1, $0.2, $0.3) }
    }

    static func all<A, B, C, D, E, F>(_ promiseA: Promise<A>, _ promiseB: Promise<B>, _ promiseC: Promise<C>, _ promiseD: Promise<D>, _ promiseE: Promise<E>, _ promiseF: Promise<F>) -> Promise<(A, B, C, D, E, F)> {
        all(all(promiseA, promiseB), promiseC, promiseD, promiseE, promiseF)
            .then { ($0.0.0, $0.0.1, $0.1, $0.2, $0.3, $0.4) }
    }
}
