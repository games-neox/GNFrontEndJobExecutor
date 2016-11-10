# GNFrontEndJobExecutor

[![CI Status](http://img.shields.io/travis/games-neox/GNFrontEndJobExecutor.svg?style=flat)](https://travis-ci.org/games-neox/GNFrontEndJobExecutor)
[![Version](https://img.shields.io/cocoapods/v/GNFrontEndJobExecutor.svg?style=flat)](http://cocoapods.org/pods/GNFrontEndJobExecutor)
[![License](https://img.shields.io/cocoapods/l/GNFrontEndJobExecutor.svg?style=flat)](http://cocoapods.org/pods/GNFrontEndJobExecutor)
[![Platform](https://img.shields.io/cocoapods/p/GNFrontEndJobExecutor.svg?style=flat)](http://cocoapods.org/pods/GNFrontEndJobExecutor)

Diagram representing possible interactions between dedicated threads:

    +------+       +-------+       +--------+
    | main | <---> | logic | <---> | bridge |
    +------+       +-------+       +--------+

The purpose of the single `logic` thread is to handle all the app logic that normally would be done in the `main` thread, thus slowing down user interactions & touch event reactions.
The idea of the signle `bridge` thread is to make communication with an external system/framework/library much easier and not to affect the performance of the `main-logic` pair.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Minimum supported `iOS` version: `8.x`  
Dependencies: `GNExceptions`, `GNLog`, `GNPreconditions` & `GNThreadPool`  

## Installation

GNFrontEndJobExecutor is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "GNFrontEndJobExecutor"
```  

## Author

Games Neox, games.neox@gmail.com

## License

GNFrontEndJobExecutor is available under the MIT license. See the LICENSE file for more info.
