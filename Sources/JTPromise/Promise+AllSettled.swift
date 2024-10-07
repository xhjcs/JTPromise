//
//  Promise+AllSettled.swift
//  JTPromise
//
//  Created by xinghanjie on 2024/9/29.
//

import Foundation

public enum PromiseSettledResult<T> {
    case fulfilled(T)
    case rejected(Error)
}

public extension Promise {
    static func allSettled(_ promises: [Promise<Value>]) -> Promise<[PromiseSettledResult<Value>]> {
        guard !promises.isEmpty else {
            return Promise<[PromiseSettledResult<Value>]>(resolve: [PromiseSettledResult<Value>]())
        }
        let count = promises.count
        var results = [PromiseSettledResult<Value>?](repeating: nil, count: count)
        var remaining = count
        let lock = PromiseLock()
        return Promise<[PromiseSettledResult]> { resolve, _ in
            func handleFinally() {
                remaining -= 1
                if remaining == 0 {
                    resolve(results.compactMap { $0 })
                }
            }
            for i in 0 ..< count {
                let promise = promises[i]
                promise
                    .then { value in
                        lock.lock()
                        results[i] = .fulfilled(value)
                        handleFinally()
                        lock.unlock()
                    }
                    .catch { error -> Void in
                        lock.lock()
                        results[i] = .rejected(error)
                        handleFinally()
                        lock.unlock()
                    }
            }
        }
    }

    static func allSettled<A, B>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>
    ) -> Promise<(
        PromiseSettledResult<A>,
        PromiseSettledResult<B>
    )> {
        let empty = Promise<Int>(resolve: 0)
        return allSettled(promiseA,
                          promiseB,
                          empty,
                          empty,
                          empty,
                          empty)
            .then { ($0.0, $0.1) }
    }

    static func allSettled<A, B, C>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>,
        _ promiseC: Promise<C>
    ) -> Promise<(
        PromiseSettledResult<A>,
        PromiseSettledResult<B>,
        PromiseSettledResult<C>
    )> {
        let empty = Promise<Int>(resolve: 0)
        return allSettled(promiseA,
                          promiseB,
                          promiseC,
                          empty,
                          empty,
                          empty)
            .then { ($0.0, $0.1, $0.2) }
    }

    static func allSettled<A, B, C, D>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>,
        _ promiseC: Promise<C>,
        _ promiseD: Promise<D>
    ) -> Promise<(
        PromiseSettledResult<A>,
        PromiseSettledResult<B>,
        PromiseSettledResult<C>,
        PromiseSettledResult<D>
    )> {
        let empty = Promise<Int>(resolve: 0)
        return allSettled(promiseA,
                          promiseB,
                          promiseC,
                          promiseD,
                          empty,
                          empty)
            .then { ($0.0, $0.1, $0.2, $0.3) }
    }

    static func allSettled<A, B, C, D, E>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>,
        _ promiseC: Promise<C>,
        _ promiseD: Promise<D>,
        _ promiseE: Promise<E>
    ) -> Promise<(
        PromiseSettledResult<A>,
        PromiseSettledResult<B>,
        PromiseSettledResult<C>,
        PromiseSettledResult<D>,
        PromiseSettledResult<E>
    )> {
        let empty = Promise<Int>(resolve: 0)
        return allSettled(promiseA,
                          promiseB,
                          promiseC,
                          promiseD,
                          promiseE,
                          empty)
            .then { ($0.0, $0.1, $0.2, $0.3, $0.4) }
    }

    static func allSettled<A, B, C, D, E, F>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>,
        _ promiseC: Promise<C>,
        _ promiseD: Promise<D>,
        _ promiseE: Promise<E>,
        _ promiseF: Promise<F>
    ) -> Promise<(
        PromiseSettledResult<A>,
        PromiseSettledResult<B>,
        PromiseSettledResult<C>,
        PromiseSettledResult<D>,
        PromiseSettledResult<E>,
        PromiseSettledResult<F>
    )> {
        let lock = PromiseLock()
        return Promise<(
            PromiseSettledResult<A>,
            PromiseSettledResult<B>,
            PromiseSettledResult<C>,
            PromiseSettledResult<D>,
            PromiseSettledResult<E>,
            PromiseSettledResult<F>
        )> { resolve, _ in
            var resultA: PromiseSettledResult<A>?
            var resultB: PromiseSettledResult<B>?
            var resultC: PromiseSettledResult<C>?
            var resultD: PromiseSettledResult<D>?
            var resultE: PromiseSettledResult<E>?
            var resultF: PromiseSettledResult<F>?

            func handleResult(handler: () -> Void) {
                lock.lock()
                handler()
                if let resultA = resultA,
                   let resultB = resultB,
                   let resultC = resultC,
                   let resultD = resultD,
                   let resultE = resultE,
                   let resultF = resultF {
                    lock.unlock()
                    resolve(
                        (resultA,
                         resultB,
                         resultC,
                         resultD,
                         resultE,
                         resultF)
                    )
                } else {
                    lock.unlock()
                }
            }

            promiseA
                .then { value in
                    handleResult {
                        resultA = PromiseSettledResult.fulfilled(value)
                    }
                }
                .catch { error in
                    handleResult {
                        resultA = PromiseSettledResult.rejected(error)
                    }
                }

            promiseB
                .then { value in
                    handleResult {
                        resultB = PromiseSettledResult.fulfilled(value)
                    }
                }
                .catch { error in
                    handleResult {
                        resultB = PromiseSettledResult.rejected(error)
                    }
                }

            promiseC
                .then { value in
                    handleResult {
                        resultC = PromiseSettledResult.fulfilled(value)
                    }
                }
                .catch { error in
                    handleResult {
                        resultC = PromiseSettledResult.rejected(error)
                    }
                }

            promiseD
                .then { value in
                    handleResult {
                        resultD = PromiseSettledResult.fulfilled(value)
                    }
                }
                .catch { error in
                    handleResult {
                        resultD = PromiseSettledResult.rejected(error)
                    }
                }

            promiseE
                .then { value in
                    handleResult {
                        resultE = PromiseSettledResult.fulfilled(value)
                    }
                }
                .catch { error in
                    handleResult {
                        resultE = PromiseSettledResult.rejected(error)
                    }
                }

            promiseF
                .then { value in
                    handleResult {
                        resultF = PromiseSettledResult.fulfilled(value)
                    }
                }
                .catch { error in
                    handleResult {
                        resultF = PromiseSettledResult.rejected(error)
                    }
                }
        }
    }
}
