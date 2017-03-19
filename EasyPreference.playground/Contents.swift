import Foundation
import EasyPreference

let Preference = EasyPreference(defaults: .standard)
let Name:   PreferenceKey<String>   = "Name"
let Age:    PreferenceKey<Int>      = "Age"
let Color:  PreferenceKey<NSColor>  = "Color"

Preference[Name] = "Xander"
Preference[Age]  = 20
Preference.setObject(.red, for: Color)

Preference[Name]
Preference[Age]
Preference.object(for: Color)

let token1 = Preference.subscribe(key: Age) { change in
    print("\(change.oldValue) -> \(change.newValue)")
}

let token2 = Preference.subscribe(key: Color) { change in
    print("\(change.oldValue) -> \(change.newValue)")
}

Preference[Age] = 21

token1.invalidate()

Preference[Age] = 22

Preference.setObject(.green, for: Color)

token2.invalidate()

Preference.setObject(.blue, for: Color)
