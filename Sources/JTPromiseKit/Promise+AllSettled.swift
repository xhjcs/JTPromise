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

fileprivate extension SettledResult {
    func `as`<U>(_ type: U.Type) -> SettledResult<U> {
        switch self {
        case .fulfilled(let result):
            return .fulfilled(result as! U)
        case .rejected(let error):
            return .rejected(error)
        }
    }
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
            for (i, promise) in promises.enumerated() {
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
    
    static func allSettled<A, B>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>
    ) -> Promise<(
        SettledResult<A>,
        SettledResult<B>
    )> {
        Promise<Any>.allSettled([
            promiseA.asAny(),
            promiseB.asAny()
        ]).then {(
            $0[0].as(A.self),
            $0[1].as(B.self)
        )}
    }
    
    static func allSettled<A, B, C>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>,
        _ promiseC: Promise<C>
    ) -> Promise<(
        SettledResult<A>,
        SettledResult<B>,
        SettledResult<C>
    )> {
        Promise<Any>.allSettled([
            promiseA.asAny(),
            promiseB.asAny(),
            promiseC.asAny()
        ]).then {(
            $0[0].as(A.self),
            $0[1].as(B.self),
            $0[2].as(C.self)
        )}
    }
    
    static func allSettled<A, B, C, D>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>,
        _ promiseC: Promise<C>,
        _ promiseD: Promise<D>
    ) -> Promise<(
        SettledResult<A>,
        SettledResult<B>,
        SettledResult<C>,
        SettledResult<D>
    )> {
        Promise<Any>.allSettled([
            promiseA.asAny(),
            promiseB.asAny(),
            promiseC.asAny(),
            promiseD.asAny()
        ]).then {(
            $0[0].as(A.self),
            $0[1].as(B.self),
            $0[2].as(C.self),
            $0[3].as(D.self)
        )}
    }
    
    static func allSettled<A, B, C, D, E>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>,
        _ promiseC: Promise<C>,
        _ promiseD: Promise<D>,
        _ promiseE: Promise<E>
    ) -> Promise<(
        SettledResult<A>,
        SettledResult<B>,
        SettledResult<C>,
        SettledResult<D>,
        SettledResult<E>
    )> {
        Promise<Any>.allSettled([
            promiseA.asAny(),
            promiseB.asAny(),
            promiseC.asAny(),
            promiseD.asAny(),
            promiseE.asAny()
        ]).then {(
            $0[0].as(A.self),
            $0[1].as(B.self),
            $0[2].as(C.self),
            $0[3].as(D.self),
            $0[4].as(E.self)
        )}
    }
    
    static func allSettled<A, B, C, D, E, F>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>,
        _ promiseC: Promise<C>,
        _ promiseD: Promise<D>,
        _ promiseE: Promise<E>,
        _ promiseF: Promise<F>
    ) -> Promise<(
        SettledResult<A>,
        SettledResult<B>,
        SettledResult<C>,
        SettledResult<D>,
        SettledResult<E>,
        SettledResult<F>
    )> {
        Promise<Any>.allSettled([
            promiseA.asAny(),
            promiseB.asAny(),
            promiseC.asAny(),
            promiseD.asAny(),
            promiseE.asAny(),
            promiseF.asAny()
        ]).then {(
            $0[0].as(A.self),
            $0[1].as(B.self),
            $0[2].as(C.self),
            $0[3].as(D.self),
            $0[4].as(E.self),
            $0[5].as(F.self)
        )}
    }
}
