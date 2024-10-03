# JTPromise

A lightweight, thread-safe Promise library for Swift and Objective-C, with a JavaScript-like API.

## Features

- **JavaScript-style API**: The `JTPromise` API is fully aligned with JavaScript's `Promise` design, making it intuitive for developers familiar with JavaScript.
- **Thenable chaining**: Chain multiple asynchronous operations using `.then`, `.catch`, and `.finally` handlers.
- **Promise combinators**: Supports `all`, `allSettled`, `any`, and `race` for managing multiple promises concurrently, mirroring JavaScript behavior.
- **Thread safety**: Ensures safe state transitions across multiple threads.
- **Objective-C compatibility**: Offers seamless integration with Objective-C projects.

## API Overview
JTPromise follows the same API structure as JavaScript's Promise, with familiar methods such as .then(), .catch(), .finally(), and promise combinators like all(), any(), and race().

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
```objective-c
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

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Alamofire into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'JTPromise'
```

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/JTPromise.git", from: "1.0.5")
]
```