import Foundation
import EasyPreference

let Preference = EasyPreference.init(defaults: .standard)
let Name:   PreferenceKey<String>   = "Name"
let Age:    PreferenceKey<Int>      = "Age"
let Color:  PreferenceKey<NSColor>  = "Color"

Preference[Name] = "Xander"
Preference[Age]  = 20
Preference.setObject(.red, for: Color)

Preference[Name]
Preference[Age]
Preference.object(for: Color)

let token = Preference.subscribe(key: Age) { change in
    print("\(change.oldValue) -> \(change.newValue)")
}

Preference[Age] = 21

token.invalidate()

Preference[Age] = 22
