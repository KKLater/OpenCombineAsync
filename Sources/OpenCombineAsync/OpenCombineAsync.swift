import Foundation
import Dispatch
import OpenCombine

var maxSemaphoreCount: Int = 8 {
    didSet {
        semaphore = DispatchSemaphore(value: maxSemaphoreCount)
    }
}

fileprivate var workConcurrentQueue: DispatchQueue = DispatchQueue(label: "com.async.workConcurrentQueue", attributes: .concurrent)

fileprivate var serialQueue: DispatchQueue = DispatchQueue(label: "com.async.serialQueue")

fileprivate var semaphore: DispatchSemaphore = DispatchSemaphore(value: maxSemaphoreCount)

public func main(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}

public func background(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async(execute: block)
}

public func `default`(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .default).async(execute: block)
}

public func unspecified(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .unspecified).async(execute: block)
}

public func userInitiated(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .userInitiated).async(execute: block)
}


public func userInteractive(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .userInteractive).async(execute: block)
}

public func utility(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: .utility).async(execute: block)
}

public func async(label: String, attributes: DispatchQueue.Attributes = .concurrent, block: @escaping () -> Void) {
    DispatchQueue(label: label, attributes: attributes).async(execute: block)
}

@discardableResult
public func async<T>(block:@escaping () throws -> T) -> Future<T, Error> {
    let p = Future<T, Error> { promise in
        serialQueue.async {
            semaphore.wait()
            workConcurrentQueue.async {
                do {
                    let t = try block()
                    promise(.success(t))
                    semaphore.signal()
                } catch {
                    promise(.failure(error))
                    semaphore.signal()
                }
            }

        }
    }

    return p
}

@discardableResult public func await<T>(_ future: Future<T, Error>) throws -> T {
    var result: T!
    var error: Error?
    let group = DispatchGroup()
    group.enter()
    future.cancel = future.sink { (completione) in
        switch completione {
            
        case .finished: break
            
        case .failure(let err):
            error = err
            break
            
        }
        group.leave()
    } receiveValue: { (t) in
        result = t
    }
    group.wait()
    if let e = error {
        throw e
    }
    return result
}

private var actionsKey: UInt8 = 0
private var catchKey: UInt8 = 0
private var receiveKey: UInt8 = 0

extension Future {
    
    var cancel: AnyCancellable? {
        set {
            objc_setAssociatedObject(self, &actionsKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self,  &actionsKey) as? AnyCancellable
        }
    }

    var `catch`: ((Error?) -> Void)? {
        set {
            objc_setAssociatedObject(self, &catchKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self,  &catchKey) as? ((Error?) -> Void)
        }
    }
    var receive: ((Any) -> Void)? {
        set {
            objc_setAssociatedObject(self, &receiveKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self,  &receiveKey) as? ((Any) -> Void)
        }
    }
}

