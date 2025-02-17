# JTPromise

A lightweight, thread-safe Promise library for Swift and Objective-C, with a JavaScript-like API.<br/>[中文介绍](#中文介绍)

## Features

- **JavaScript-style API**: The `JTPromise` API is fully aligned with JavaScript's `Promise` design, making it intuitive for developers familiar with JavaScript.
- **Thenable chaining**: Chain multiple asynchronous operations using `.then`, `.catch`, and `.finally` handlers.
- **Promise combinators**: Supports `all`, `allSettled`, `any`, and `race` for managing multiple promises concurrently, mirroring JavaScript behavior.
- **Thread safety**: Ensures safe state transitions across multiple threads.
- **Objective-C compatibility**: Offers seamless integration with Objective-C projects.

## API Overview
JTPromise follows the same API structure as JavaScript's Promise, with familiar methods such as .then(), .catch(), .finally(), and promise combinators like all(), allSettled(), any(), and race().

### Swift
```Swift
import JTPromise

let promise = Promise<String> { resolve, reject in
    // Asynchronous task
    if success {
        resolve("Task completed")
    } else {
        reject(MyError.someError)
    }
}

let promise1 = Promise<Int> { resolve, reject in
    // Asynchronous task
    if success {
        resolve(101)
    } else {
        reject(MyError.someError)
    }
}

promise
    .then { result in
        // result: Task completed
        print("Result:", result)
    }
    .catch { error -> Void in
        print("Error:", error)
    }
    .finally {
        print("Task finished")
    }

promise
    .then { result in
        // result: Task completed
        print("Result:", result)
        return 101
    }
    .then { result in
        // result: 101
        print("Result:", result)
    }
    .catch { error -> Void in
        print("Error:", error)
    }
    .finally {
        print("Task finished")
    }

promise
    .then { result in
        // result: Task completed
        print("Result:", result)
        return promise1
    }
    .then { result in
        // result: 101
        print("Result:", result)
    }
    .catch { error -> Void in
        print("Error:", error)
    }
    .finally {
        print("Task finished")
    }

Promise.all(promise, promise1)
        .then { result in
            // result: ("Task completed", 101)
            print("Result:", result)
        }

```
### Objective-C
```objc
@import JTPromise;

JTPromise *promise = [JTPromise promiseWithExecutor:^(void (^ _Nonnull resolve)(id _Nullable), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        if (success) {
            resolve(@"Task finished");
        } else {
            reject([NSError errorWithDomain:@"com.example.error"
                                       code:500
                                   userInfo:@{NSLocalizedDescriptionKey: @"Something went wrong"}]);
        }
    }];
    
JTPromise *promise1 = [JTPromise promiseWithExecutor:^(void (^ _Nonnull resolve)(id _Nullable), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        if (success) {
            resolve(@101);
        } else {
            reject([NSError errorWithDomain:@"com.example.error"
                                       code:500
                                   userInfo:@{NSLocalizedDescriptionKey: @"Something went wrong"}]);
        }
    }];

promise
    .then(^id (NSString *result) {
        // result: Task completed
        NSLog(@"Result: %@", result);
        return nil;
    })
    .catch(^id (NSError *error) {
        NSLog(@"Error: %@", error);
        return nil;
    })
    .finally(^{
        NSLog(@"Task finished");
    });

promise
    .then(^id (NSString *result) {
        // result: Task completed
        NSLog(@"Result: %@", result);
        return @101;
    })
    .then(^id (NSNumber *result) {
        // result: 101
        NSLog(@"Result: %@", result);
        return nil;
    })
    .catch(^id (NSError *error) {
        NSLog(@"Error: %@", error);
        return nil;
    })
    .finally(^{
        NSLog(@"Task finished");
    });

promise
    .then(^id (NSString *result) {
        // result: Task completed
        NSLog(@"Result: %@", result);
        return promise1;
    })
    .then(^id (NSNumber *result) {
        // result: 101
        NSLog(@"Result: %@", result);
        return nil;
    })
    .catch(^id (NSError *error) {
        NSLog(@"Error: %@", error);
        return nil;
    })
    .finally(^{
        NSLog(@"Task finished");
    });

[JTPromise all:@[promise, promise1]]
    .then(^id (NSArray *result) {
        // result: ("Task completed", 101)
        NSLog(@"Result: %@", result);
        return nil;
    });

```


## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate JTPromise into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'JTPromise'
```

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/xhjcs/JTPromise.git", from: "1.1.7")
]
```

## Requirements
This library requires `iOS 11.0+` and `Xcode 14.0+`.

License
==============
JTPromise is provided under the MIT license. See LICENSE file for details.

<br/><br/>
---
## 中文介绍

JTPromise一个轻量级的线程安全的Promise库，适用于Swift和Objective-C，具有和JavaScript的Promise对象一致的API。

## 特性

- **JavaScript风格API**：`JTPromise` API完全符合JavaScript的`Promise`设计，对于熟悉`JavaScript`的开发者来说非常直观，非常适合同时具有`iOS`、`ReactNative`、`H5`、`鸿蒙`技术栈的开发者。
- **可链式调用**：使用`.then`、`.catch`和`.finally`处理程序链式调用多个异步操作。
- **`Promise`组合器**：支持`all`、`allSettled`、`any`和`race`，用于并发管理多个`Promise`，和`JavaScript`中`Promise`行为一致。
- **线程安全**：确保在多个线程之间安全地进行状态转换。
- **`Objective-C`兼容性**：与`Objective-C`项目无缝集成。

## API 概述
`JTPromise`遵循与`JavaScript`的`Promise`相同的API设计，如： `.then()`、`.catch()`、`.finally()` 和 `Promise` 组合方法，如： `all()`、`allSettled()`、`any()` 和 `race()`。

### Swift
```Swift
import JTPromise

let promise = Promise<String> { resolve, reject in
    // 异步任务
    if success {
        resolve("任务完成")
    } else {
        reject(MyError.someError)
    }
}

let promise1 = Promise<Int> { resolve, reject in
    // 异步任务
    if success {
        resolve(101)
    } else {
        reject(MyError.someError)
    }
}

promise
    .then { result in
        // result: 任务完成
        print("结果:", result)
    }
    .catch { error -> Void in
        print("错误:", error)
    }
    .finally {
        print("任务结束")
    }

promise
    .then { result in
        // result: 任务完成
        print("结果:", result)
        return 101
    }
    .then { result in
        // result: 101
        print("结果:", result)
    }
    .catch { error -> Void in
        print("错误:", error)
    }
    .finally {
        print("任务结束")
    }

promise
    .then { result in
        // result: 任务完成
        print("结果:", result)
        return promise1
    }
    .then { result in
        // result: 101
        print("结果:", result)
    }
    .catch { error -> Void in
        print("错误:", error)
    }
    .finally {
        print("任务结束")
    }

Promise.all(promise, promise1)
    .then { result in
        // result: ("任务完成", 101)
        print("结果:", result)
    }
```

### Objective-C
```objc
@import JTPromise;

JTPromise *promise = [JTPromise promiseWithExecutor:^(void (^ _Nonnull resolve)(id _Nullable), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        if (success) {
            resolve(@"任务完成");
        } else {
            reject([NSError errorWithDomain:@"com.example.error"
                                       code:500
                                   userInfo:@{NSLocalizedDescriptionKey: @"出现错误"}]);
        }
    }];
    
JTPromise *promise1 = [JTPromise promiseWithExecutor:^(void (^ _Nonnull resolve)(id _Nullable), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        if (success) {
            resolve(@101);
        } else {
            reject([NSError errorWithDomain:@"com.example.error"
                                       code:500
                                   userInfo:@{NSLocalizedDescriptionKey: @"出现错误"}]);
        }
    }];

[[[promise then:^id _Nullable (NSString *result) {
    // result: Task completed
    NSLog(@"Result: %@", result);
    return nil;
}] catch:^id _Nullable (NSError *error) {
    NSLog(@"Error: %@", error);
    return nil;
}] finally:^{
    NSLog(@"Task finished");
}];

[[[[promise then:^id _Nullable (NSString *result) {
    // result: Task completed
    NSLog(@"Result: %@", result);
    return @101;
}] then:^id _Nullable (NSNumber *result) {
    // result: 101
    NSLog(@"Result: %@", result);
    return nil;
}] catch:^id _Nullable (NSError *error) {
    NSLog(@"Error: %@", error);
    return nil;
}] finally:^{
    NSLog(@"Task finished");
}];

[[[[promise then:^id _Nullable (NSString *result) {
    // result: Task completed
    NSLog(@"Result: %@", result);
    return promise1;
}] then:^id _Nullable (NSNumber *result) {
    // result: 101
    NSLog(@"Result: %@", result);
    return nil;
}] catch:^id _Nullable (NSError *error) {
    NSLog(@"Error: %@", error);
    return nil;
}] finally:^{
    NSLog(@"Task finished");
}];

[[JTPromise all:@[promise, promise1]] then:^id _Nullable (NSArray *result) {
    // result: ("Task completed", 101)
    NSLog(@"Result: %@", result);
    return nil;
}];
```


## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) 是一个用于Cocoa项目的依赖管理工具。有关用法和安装说明，请访问它的官方网站。要在Xcode项目中集成JTPromise，请在您的`Podfile`中添加:

```ruby
pod 'JTPromise'
```

### Swift Package Manager

在您的`Package.swift`文件中添加以下内容：

```swift
dependencies: [
    .package(url: "https://github.com/xhjcs/JTPromise.git", from: "1.1.7")
]
```

## 系统要求
This library requires `iOS 11.0+` and `Xcode 14.0+`.

许可证
==============
JTPromise is provided under the MIT license. See LICENSE file for details.
