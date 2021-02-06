import XCTest
@testable import OpenCombineAsync
import OpenCombine

final class OpenCombineAsyncTests: XCTestCase {
    
    func testForNormalExample() {
        
        let exp = expectation(description: "")
        
        async {
            do {
                let a = try await(self.background1())
                let b = try await(self.background2(c: a))
                let c = try await(self.background3(c: b))
                main {
                    print(c)
                    exp.fulfill()
                }
            } catch {
                throw error
            }
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testForCancelExample() {
        
        let exp = expectation(description: "")
        
        let future = async { () -> Int in
            let a = try await(self.background1())
            let b = try await(self.background2(c: a))
            let c = try await(self.background3(c: b))
            return c
        }
        let cancel = future.sink { (completion) in
            exp.fulfill()
            future.cancel?.cancel()
        } receiveValue: { (int) in
            print(int)
        }
        cancel.cancel()
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    
    func background1() -> Future<Int, Error> {
        return Future<Int, Error> { promise in
            let i:Int = Int(arc4random() % 10)
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.microseconds(i)) {
//                promise(.failure(NSError(domain: "a", code: -1, userInfo: nil)))
                promise(.success(1))

            }
        }
    }
    
    func background2(c: Int) -> Future<Int, Error> {
        return Future<Int, Error> { promise in
            let i:Int = Int(arc4random() % 10)
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.microseconds(i)) {
                promise(.success(c + 10))
            }
        }
    }
    
    func background3(c: Int) -> Future<Int, Error> {
        return Future<Int, Error> { promise in
            let i:Int = Int(arc4random() % 10)
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.microseconds(i)) {
                promise(.success(c + 100))
            }
        }
    }

    static var allTests = [
        ("testForNormalExample", testForNormalExample),
        ("testForCancelExample", testForCancelExample),

    ]
}
