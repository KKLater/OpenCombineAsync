# OpenCombineAsync

[![Release](https://img.shields.io/badge/Release-v0.0.1-green)]()
![Install](https://img.shields.io/badge/Install-SPM-orange)
![Platform](https://img.shields.io/badge/Platform-macOS%2010.15%2B%20%7C%20iOS%2013.0%2B%20%7C%20tvOS%2013.0%2B%20%7C%20watchOS%206.0%2B-lightgrey)

`OpenCombineAsync` 是基于 `OpenCombine Future` 的封装。其对 `Future`  进行封装，提供 `async` 和 `await` `api`，以优雅的处理异步事件。

## 必备条件

* macOS 10.10+/iOS 9.0+/tvOS 9.0+/watchOS 2.0+
* Swift 5.0+

如果你的项目是基于系统 `Combine` 框架，即项目环境为 `macOS 10.15+/iOS 10.0+/tvOS 10.0+/watchOS 6.0+` 那么你可以选择使用 [`CombineAsync`](https://github.com/KKLater/CombineAsync) 框架。如果你的项目采用的是 [`CombineX`](https://github.com/cx-org/CombineX) 框架，那么你可以选择 [`CombineXAsync`](https://github.com/KKLater/CombineXAsync)框架。


## 安装

### Swift Package Manager (SPM)

`Swift` 包管理器是一个管理 `Swift` 代码分发的工具。它与 `Swift` 构建系统集成，以自动化下载、编译和链接依赖项的过程。

> 使用 `Swift` 包管理器构建 `OpenCombineAsync` 需要 `Xcode 11+` 以上版本

要使用 `Swift` 包管理器将 `OpenCombineAsync` 集成到 `Xcode` 项目中，请将其添加到 `Package.swift` 中：
```swift
dependencies: [
    .package(url: "https://github.com/KKLater/OpenCombineAsync.git", .upToNextMajor(from: "0.0.1"))
]
```

## 使用

异步操作需要包裹成 `OpenCombineAsync` 的 `Future` 对象

```swift
func background1() -> Future<Int, Error> {
    return Future<Int, Error> { promise in
        let i:Int = Int(arc4random() % 10)
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.microseconds(i)) {
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
```

使用 `async` `await` `api` 之前：
```swift
self.background1().sink { (error) in
    print(error)
} receiveValue: { (a) in
    self.background2(c: a).sink { (error) in
        print(error)
    } receiveValue: { (b) in
        self.background3(c: b).sink { (error) in
            print(error)
        } receiveValue: { (c) in
            print(c) // 111
        }.store(in: &self.cancels)

    }.store(in: &self.cancels)
}.store(in: &cancels)
```

使用 `async` 和 `await` api 后：

```swift
async {
    do {
        let a = try await(self.background1())
        let b = try await(self.background2(c: a))
        let c = try await(self.background3(c: b))
        main {
            print(c) // 111
        }
    } catch {
        throw error
    }
}
```

## License

`OpenCombineAsync` 以 `MIT` 协议发布，查看 `LICENSE` 获取更多信息。
