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
            for (i, promise) in promises.enumerated() {
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
    
    static func all<A, B>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>
    ) -> Promise<(A, B)> {
        Promise<Any>.all([
            promiseA.asAny(),
            promiseB.asAny()
        ]).then {(
            $0[0] as! A,
            $0[1] as! B
        )}
    }

    static func all<A, B, C>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>,
        _ promiseC: Promise<C>
    ) -> Promise<(A, B, C)> {
        Promise<Any>.all([
            promiseA.asAny(),
            promiseB.asAny(),
            promiseC.asAny()
        ]).then {(
            $0[0] as! A,
            $0[1] as! B,
            $0[2] as! C
        )}
    }

    static func all<A, B, C, D>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>,
        _ promiseC: Promise<C>,
        _ promiseD: Promise<D>
    ) -> Promise<(A, B, C, D)> {
        Promise<Any>.all([
            promiseA.asAny(),
            promiseB.asAny(),
            promiseC.asAny(),
            promiseD.asAny()
        ]).then {(
            $0[0] as! A,
            $0[1] as! B,
            $0[2] as! C,
            $0[3] as! D
        )}
    }

    static func all<A, B, C, D, E>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>,
        _ promiseC: Promise<C>,
        _ promiseD: Promise<D>,
        _ promiseE: Promise<E>
    ) -> Promise<(A, B, C, D, E)> {
        Promise<Any>.all([
            promiseA.asAny(),
            promiseB.asAny(),
            promiseC.asAny(),
            promiseD.asAny(),
            promiseE.asAny()
        ]).then {(
            $0[0] as! A,
            $0[1] as! B,
            $0[2] as! C,
            $0[3] as! D,
            $0[4] as! E
        )}
    }

    static func all<A, B, C, D, E, F>(
        _ promiseA: Promise<A>,
        _ promiseB: Promise<B>,
        _ promiseC: Promise<C>,
        _ promiseD: Promise<D>,
        _ promiseE: Promise<E>,
        _ promiseF: Promise<F>
    ) -> Promise<(A, B, C, D, E, F)> {
        Promise<Any>.all([
            promiseA.asAny(),
            promiseB.asAny(),
            promiseC.asAny(),
            promiseD.asAny(),
            promiseE.asAny(),
            promiseF.asAny()
        ]).then {(
            $0[0] as! A,
            $0[1] as! B,
            $0[2] as! C,
            $0[3] as! D,
            $0[4] as! E,
            $0[5] as! F
        )}
    }
}
