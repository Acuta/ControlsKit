# ControlsKit

[![Version](https://img.shields.io/cocoapods/v/ControlsKit.svg?style=flat)](http://cocoapods.org/pods/ControlsKit)
[![Platform](https://img.shields.io/cocoapods/p/ControlsKit.svg?style=flat)](http://cocoapods.org/pods/ControlsKit)
[![Languages](https://img.shields.io/badge/languages-ObjC%20%7C%20Swift-orange.svg)](http://cocoapods.org/pods/ControlsKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/ControlsKit.svg?style=flat)](http://cocoapods.org/pods/Acuta)

[![Build Status](https://www.bitrise.io/app/060fa34a5010575a/status.svg?token=HXDq_G-sN4wM0p_0JzZkBg&branch=master)](https://www.bitrise.io/app/060fa34a5010575a)
[![codecov](https://codecov.io/gh/Acuta/ControlsKit/branch/master/graph/badge.svg)](https://codecov.io/gh/Acuta/ControlsKit)

## Example

To run the example project, clone the repo, open the workspace and run `ControlsKitExample`.

## Requirements

iOS 8.0

## Description

This is a list of components that have been developped over the course of multiple years, and have been used in a dozen of projects so far. They aim to either be a drop-in replacement for existing controls with more customizations, or provide additional features on top of existing controls.

### NibView

Allows to use Interface Builder to create the layout of a view inside a xib file, which can be then be loaded like any views.

### PageControl

A custom subclass of `UIView` which acts as a drop-in replacement for `UIPageControl`, but that allow for deep customizations.

### PlaceholderTextView

A subclass of `UITextView` which provides a placeholder text.

### Switch

A subclass of `UISwitch` allowing to add custom images and colors to the default iOS Switch.

## Installation

### Via CocoaPods

ControlsKit is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'ControlsKit', '~> 1.0'
```

By default, the Swift version of the library is fetched. If you want to just use the Objective-C version, just add the following line instead in your Podfile: 

```ruby
pod 'ControlsKit/ObjC', '~> 1.0'
```

Likewise, you might not want to pull all controls at once if you're just using one. So for example, if you wanted to just use the `PlaceholderTextView` in your project, just add the following:

```ruby
pod 'ControlsKit/PlaceholderTextView/Swift', '~> 1.0'
```

(You can also replace `Swift` by `ObjC` should you want to use the Objective-C version)

### Via Carthage

ControlsKit is also available through [Carthage](https://github.com/Carthage/Carthage). To install it, simply add the following line to your Cartfile:

```
github "Acuta/ControlsKit" ~> 1.0
```

If you use Carthage to build your dependencies, just add `ControlsKit.framework` to the "_Linked Frameworks and Libraries_" section of your target, and make sure you've included them in your Carthage framework copying build phase.

## Authors

- [Stéphane Copin](https://github.com/stephanecopin), stephane.copin@live.fr
- [Bastien Falcou](https://github.com/bastienFalcou), bastien.falcou@hotmail.com

## License

ControlsKit is available under the MIT license. See the LICENSE file for more info.
