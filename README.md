# EasyPreference

![platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Requirements

- macOS 10.9+ / iOS 8.0+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8+
- Swift 3.0+

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

## Usage

### Quick Start

```swift
import EasyPreference

let Preference = EasyPreference(defaults: .standard)
let Name:   PreferenceKey<String>   = "Name"
let Age:    PreferenceKey<Int>      = "Age"
let Color:  PreferenceKey<NSColor>  = "Color"

Preference[Name] = "Xander"
Preference[Age]  = 20
Preference.setObject(.red, for: Color)

Preference[Name]
// "Xander"
Preference[Age]
// 20
Preference.object(for: Color)
// NSColor: #FF0000FF

let token = Preference.subscribe(key: Age) { change in
    print("\(change.oldValue) -> \(change.newValue)")
}

Preference[Age] = 21
// 20 -> 21

token.invalidate()

Preference[Age] = 22
// nothing happes
```

## License

EasyPreference is available under the MIT license. See the [LICENSE file](LICENSE).
