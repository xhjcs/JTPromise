//
//  ViewController.m
//  Example
//
//  Created by xinghanjie on 2024/10/4.
//

#import "Example-Swift.h"
#import "ViewController.h"
@import JTPromise;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Playground play];
    JTPromise *promise = [JTPromise promiseWithExecutor:^(void (^_Nonnull resolve)(id _Nullable), void (^_Nonnull reject)(NSError *_Nonnull)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                           if (arc4random_uniform(2)) {
                               resolve(@100);
                           } else {
                               reject([NSError errorWithDomain:@"com.example.error"
                                                          code:500
                                                      userInfo:@{ NSLocalizedDescriptionKey: @"Something went wrong" }]);
                           }
                       });
    }];

    promise
    .finally(^{
        NSLog(@"finally");
    })
    .then(^id (NSNumber *value) {
        NSLog(@"then: %@", value);
        return value;
    })
    .finally(^{
        NSLog(@"finally1");
    })
    .catch(^id (NSError *error) {
        NSLog(@"catch: %@", error);
        return [JTPromise promiseWithExecutor:^(void (^_Nonnull resolve)(id _Nullable), void (^_Nonnull reject)(NSError *_Nonnull)) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                               resolve(@101);
                           });
        }];
    })
    .finally(^{
        NSLog(@"finally2");
    })
    .then(^id (NSNumber *value) {
        NSLog(@"then1: %@", value);
        return nil;
    })
    .finally(^{
        NSLog(@"finally3");
    })
    .finally(^{
        NSLog(@"finally4");
    });
}

@end
