//
//  Promise.swift
//  iDemo
//
//  Created by xinghanjie on 2024/9/27.
//

import Foundation

public final class Promise<Value> {
    enum State {
        case pending
        case fulfilled(Value)
        case rejected(Error)
    }

    private var state: State = .pending
    private var fulfillHandlers: [(Value) -> Void] = []
    private var rejectHandlers: [(Error) -> Void] = []

    private let lock = PromiseLock()

    public convenience init(resolve value: Value) {
        self.init { resolve, _ in
            resolve(value)
        }
    }

    public convenience init(reject error: Error) {
        self.init { _, reject in
            reject(error)
        }
    }

    public init(executor: @escaping (_ resolve: @escaping (Value) -> Void, _ reject: @escaping (Error) -> Void) -> Void) {
        executor(fulfill, reject)
    }

    private func fulfill(_ value: Value) {
        lock.lock()
        guard case .pending = state else {
            lock.unlock()
            return
        }
        state = .fulfilled(value)
        let handlers = fulfillHandlers
        lock.unlock()
        handlers.forEach { $0(value) }
    }

    private func reject(_ error: Error) {
        lock.lock()
        guard case .pending = state else {
            lock.unlock()
            return
        }
        state = .rejected(error)
        let handlers = rejectHandlers
        lock.unlock()
        handlers.forEach { $0(error) }
    }

    @discardableResult
    public func then(_ handler: @escaping (_ value: Value) throws -> Void) -> Promise<Value?> {
        return _then { value in
            Promise<Value?> { resolve, reject in
                do {
                    try handler(value)
                    resolve(nil)
                } catch {
                    reject(error)
                }
            }
        }
    }

    @discardableResult
    public func then<NewValue>(_ handler: @escaping (_ value: Value) throws -> NewValue) -> Promise<NewValue> {
        return _then { value in
            Promise<NewValue> { resolve, reject in
                do {
                    resolve(try handler(value))
                } catch {
                    reject(error)
                }
            }
        }
    }

    @discardableResult
    public func then<NewValue>(_ handler: @escaping (_ value: Value) -> Promise<NewValue>) -> Promise<NewValue> {
        _then(handler)
    }

    @discardableResult
    private func _then<NewValue>(_ handler: @escaping (_ value: Value) throws -> Promise<NewValue>) -> Promise<NewValue> {
        lock.lock()
        let currentState = state
        lock.unlock()

        switch currentState {
        case .pending:
            return Promise<NewValue> { resolve, reject in
                self.lock.lock()
                self.fulfillHandlers.append {
                    do {
                        try handler($0).then(resolve).catch(reject)
                    } catch {
                        reject(error)
                    }
                }
                self.rejectHandlers.append(reject)
                self.lock.unlock()
            }
        case let .fulfilled(value):
            do {
                return try handler(value)
            } catch {
                return Promise<NewValue>(reject: error)
            }
        case let .rejected(error):
            return Promise<NewValue>(reject: error)
        }
    }

    @discardableResult
    public func `catch`(_ handler: @escaping (_ error: Error) -> Void) -> Promise<Value?> {
        lock.lock()
        let currentState = state
        lock.unlock()

        switch currentState {
        case .pending:
            return Promise<Value?> { (resolve: @escaping (Value?) -> Void, _: @escaping (Error) -> Void) in
                self.lock.lock()
                self.fulfillHandlers.append(resolve)
                self.rejectHandlers.append {
                    handler($0)
                    resolve(nil)
                }
                self.lock.unlock()
            }
        case let .fulfilled(value):
            return Promise<Value?>(resolve: value)
        case let .rejected(error):
            handler(error)
            return Promise<Value?>(resolve: nil)
        }
    }

    @discardableResult
    public func `catch`(_ handler: @escaping (_ error: Error) -> Value) -> Promise<Value> {
        return _catch { Promise(resolve: handler($0)) }
    }

    @discardableResult
    public func `catch`(_ handler: @escaping (_ error: Error) -> Promise<Value>) -> Promise<Value> {
        return _catch(handler)
    }

    @discardableResult
    private func _catch(_ handler: @escaping (_ error: Error) -> Promise<Value>) -> Promise<Value> {
        lock.lock()
        let currentState = state
        lock.unlock()

        switch currentState {
        case .pending:
            return Promise<Value> { (resolve: @escaping (Value) -> Void, reject: @escaping (Error) -> Void) in
                self.lock.lock()
                self.fulfillHandlers.append(resolve)
                self.rejectHandlers.append { handler($0).then(resolve).catch(reject) }
                self.lock.unlock()
            }
        case let .fulfilled(value):
            return Promise(resolve: value)
        case let .rejected(error):
            return handler(error)
        }
    }

    public func finally(_ handler: @escaping () -> Void) {
        lock.lock()
        let currentState = state
        lock.unlock()

        switch currentState {
        case .fulfilled, .rejected:
            handler()
        case .pending:
            lock.lock()
            fulfillHandlers.append { _ in handler() }
            rejectHandlers.append { _ in handler() }
            lock.unlock()
        }
    }
}
