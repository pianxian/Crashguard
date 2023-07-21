# Crashguard

[![CI Status](https://img.shields.io/travis/huweiwei/Crashguard.svg?style=flat)](https://travis-ci.org/huweiwei/Crashguard)
[![Version](https://img.shields.io/cocoapods/v/Crashguard.svg?style=flat)](https://cocoapods.org/pods/Crashguard)
[![License](https://img.shields.io/cocoapods/l/Crashguard.svg?style=flat)](https://cocoapods.org/pods/Crashguard)
[![Platform](https://img.shields.io/cocoapods/p/Crashguard.svg?style=flat)](https://cocoapods.org/pods/Crashguard)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Crashguard is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Crashguard'
```

## Author

pianxian, 935932000@qq.com

## License

Crashguard is available under the MIT license. See the LICENSE file for more info.

UseAge
启动崩溃防护
 ```
    [MiKiCrashGuard enableCrashGuardInstantly:true];
 ```

设置 ANR 时间，如果主线程卡顿超过 3 秒，输出 ANR
 ```
    [MiKiCrashGuard setStackDetectDuration:3];
 ```
发生 ANR 的回调
 ```
    [MiKiCrashGuard setANRStackDetectCallback:^(NSString *msg) {
      NSLog(msg);
    }];
    [MiKiCrashGuard startANRDetect];
    [MiKiCrashGuard startDispatchOnceDeadLockGuard];
 ```

