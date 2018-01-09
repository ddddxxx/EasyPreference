⚠️ This repo is deprecated. Please migrate to [GenericID](https://github.com/ddddxxx/GenericID).

# EasyPreference

[![Build Status](https://travis-ci.org/XQS6LB3A/EasyPreference.svg?branch=master)](https://travis-ci.org/XQS6LB3A/EasyPreference)
![platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Swift extension to use `UserDefaults` in a simple, elegant, type-safe way. This library also supports key-value observing with block.

## Requirements

- macOS 10.9+ / iOS 8.0+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8+
- Swift 3.0+

## Introduction

This library aims to make it super-easy to read, write and observeing the defaults from `UserDefaults `, even supporting coding/decoding with `NSKeyedArchiver`.

#### before
```swift
let Defaults = UserDefaults.standard
let Name = "Name"
let Age = "Age"
let Photo = "Photo"

class Man: NSObject {
    
    let name: String?
    let age: Int
    let photo: NSImage?
    
    override init() {
        name = Defaults.string(forKey: Name)
        age = Defaults.integer(forKey: Age)
        if let photoData = Defaults.data(forKey: Photo) {
            photo = NSKeyedUnarchiver.unarchiveObject(with: photoData) as? NSImage
        } else {
            photo = nil
        }
        super.init()
        
        Defaults.addObserver(self, forKeyPath: Age, options: [.old, .new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {
            return
        }
        
        guard let change = change,
            let oldValue = change[.oldKey], let newValue = change[.newKey] else {
            return
        }
        
        switch keyPath {
        case Age:
            print("\(oldValue) -> \(newValue)")
        default:
            break
        }
    }
    
    deinit {
        Defaults.removeObserver(self, forKeyPath: Age)
    }
    
}
```

#### after
```swift
let Defaults = EasyPreference(defaults: .standard)
let Name: PreferenceKey<String> = "Name"
let Age: PreferenceKey<Int> = "Age"
let Photo: PreferenceKey<NSImage> = "Photo"

class Man {
    
    let name: String?
    let age: Int
    let photo: NSImage?
    
    init() {
        name = Defaults[Name]
        age = Defaults[Age]
        photo = Preference.object(for: Photo)
        
        Defaults.subscribe(key: Age) { change in
            print("\(change.oldValue) -> \(change.newValue)")
        }
    }
    
}
```

## Installation

### [Carthage](https://github.com/Carthage/Carthage)

Add the project to your `Cartfile`:

```
github "XQS6LB3A/EasyPreference"
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Add the project to your `Package.swift` file:

```swift
let package = Package(
    dependencies: [
        .Package(url: "https://github.com/XQS6LB3A/EasyPreference", majorVersion: 0)
    ]
)
```

## License

EasyPreference is available under the MIT license. See the [LICENSE file](LICENSE).
