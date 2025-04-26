//
//  Promise+AllSettled.swift
//  JTPromise
//
//  Created by xinghanjie on 2024/9/29.
//

import Foundation

public enum SettledResult<T> {
    case fulfilled(T)
    case rejected(Error)
}

public extension Promise {
    static func allSettled(_ promises: [Promise<Value>]) -> Promise<[SettledResult<Value>]> {
        guard !promises.isEmpty else {
            return Promise<[SettledResult<Value>]>(resolve: [SettledResult<Value>]())
        }
        let count = promises.count
        var results = [SettledResult<Value>?](repeating: nil, count: count)
        var remaining = count
        let lock = Lock()
        return Promise<[SettledResult]> { resolve, _ in
            func handleSettledResult(_ result: SettledResult<Value>, at index: Int) {
                lock.lock()
                results[index] = result
                remaining -= 1
                let resolved = remaining == 0
                lock.unlock()
                if resolved {
                    resolve(results.compactMap { $0 })
                }
            }
            for i in 0 ..< count {
                let promise = promises[i]
                promise
                    .then { value in
                        handleSettledResult(.fulfilled(value), at: i)
                    }
                    .catch { error in
                        handleSettledResult(.rejected(error), at: i)
                    }
            }
        }
    }
    
    static func allSettled<A, B>(_ promiseA: Promise<A>, _ promiseB: Promise<B>) -> Promise<(SettledResult<A>, SettledResult<B>)> {
        let lock = Lock()
        return Promise<(SettledResult<A>, SettledResult<B>)> { resolve, _ in
            var resultA: SettledResult<A>?
            var resultB: SettledResult<B>?

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

            promiseA
                .then { value in
                    handleResult {
                        resultA = SettledResult.fulfilled(value)
                    }
                }
                .catch { error in
                    handleResult {
                        resultA = SettledResult.rejected(error)
                    }
                }

            promiseB
                .then { value in
                    handleResult {
                        resultB = SettledResult.fulfilled(value)
                    }
                }
                .catch { error in
                    handleResult {
                        resultB = SettledResult.rejected(error)
                    }
                }
        }
    }

    static func allSettled<A, B, C>(_ promiseA: Promise<A>, _ promiseB: Promise<B>, _ promiseC: Promise<C>) -> Promise<(SettledResult<A>, SettledResult<B>, SettledResult<C>)> {
        allSettled(allSettled(promiseA, promiseB), promiseC)
            .then { value in
                guard case let .fulfilled(result) = value.0 else {
                    throw PromiseError.impossible
                }
                return (result.0, result.1, value.1)
            }
    }

    static func allSettled<A, B, C, D>(_ promiseA: Promise<A>, _ promiseB: Promise<B>, _ promiseC: Promise<C>, _ promiseD: Promise<D>) -> Promise<(SettledResult<A>, SettledResult<B>, SettledResult<C>,SettledResult<D>)> {
        allSettled(allSettled(promiseA, promiseB), promiseC, promiseD)
            .then { value in
                guard case let .fulfilled(result) = value.0 else {
                    throw PromiseError.impossible
                }
                return (result.0, result.1, value.1, value.2)
            }
    }

    static func allSettled<A, B, C, D, E>(_ promiseA: Promise<A>, _ promiseB: Promise<B>, _ promiseC: Promise<C>, _ promiseD: Promise<D>, _ promiseE: Promise<E>) -> Promise<(SettledResult<A>, SettledResult<B>, SettledResult<C>, SettledResult<D>, SettledResult<E>)> {
        allSettled(allSettled(promiseA, promiseB), promiseC, promiseD, promiseE)
            .then { value in
                guard case let .fulfilled(result) = value.0 else {
                    throw PromiseError.impossible
                }
                return (result.0, result.1, value.1, value.2, value.3)
            }
    }

    static func allSettled<A, B, C, D, E, F>(_ promiseA: Promise<A>, _ promiseB: Promise<B>, _ promiseC: Promise<C>, _ promiseD: Promise<D>, _ promiseE: Promise<E>, _ promiseF: Promise<F>) -> Promise<(SettledResult<A>, SettledResult<B>, SettledResult<C>, SettledResult<D>, SettledResult<E>, SettledResult<F>)> {
        allSettled(allSettled(promiseA, promiseB), promiseC, promiseD, promiseE, promiseF)
            .then { value in
                guard case let .fulfilled(result) = value.0 else {
                    throw PromiseError.impossible
                }
                return (result.0, result.1, value.1, value.2, value.3, value.4)
            }
    }
    
}
