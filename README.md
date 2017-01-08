<p align="center">
  <img src="https://github.com/AndrewBoryk/ABMediaView/blob/master/ABMediaViewLogo.png?raw=true" alt="ABMediaView custom logo"/>
</p>
[![CI Status](http://img.shields.io/travis/Andrew Boryk/ABMediaView.svg?style=flat)](https://travis-ci.org/Andrew Boryk/ABMediaView)
[![Version](https://img.shields.io/cocoapods/v/ABMediaView.svg?style=flat)](http://cocoapods.org/pods/ABMediaView)
[![License](https://img.shields.io/cocoapods/l/ABMediaView.svg?style=flat)](http://cocoapods.org/pods/ABMediaView)
[![Platform](https://img.shields.io/cocoapods/p/ABMediaView.svg?style=flat)](http://cocoapods.org/pods/ABMediaView)

## Screenshots

![alt tag](ABMediaViewDemo.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* Requires iOS 8.0 or later
* Requires Automatic Reference Counting (ARC)

## Features

* Display for image and video
* Easy Lazy-loading for images and video
* Fullscreen display with minimization
* Queue for presenting mediaViews in fullscreen
* Track for buffer, progress, and scrubbing 

## Installation

ABMediaView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ABMediaView"
```

## Usage
### Calling the manager
As a singleton class, the manager can be accessed from anywhere within your app via the + sharedInstance function:

## Author

Andrew Boryk, andrewcboryk@gmail.com

## License

ABMediaView is available under the MIT license. See the LICENSE file for more info.
