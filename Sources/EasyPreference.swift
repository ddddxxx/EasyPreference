//
//  EasyPreference.swift
//  EasyPreference
//
//  Created by 邓翔 on 2017/3/16.
//
//

import Foundation

public struct ValueChange<T> {
    
    public let oldValue: T
    
    public let newValue: T
    
    init(_ old: T, _ new: T) {
        oldValue = old
        newValue = new
    }
}

public class EasyPreference: NSObject {
    
    let defaults: UserDefaults
    
    var events = [String: Event]()
    
    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    @discardableResult public func subscribe<T: NSCoding>(key: PreferenceKey<T>, initial: Bool = false, using: @escaping (ValueChange<T>) -> Void) -> EventSubscription {
        if !events.keys.contains(key.rawValue) {
            let option: NSKeyValueObservingOptions = initial ? [.old, .new, .initial] : [.old, .new]
            defaults.addObserver(self, forKeyPath: key.rawValue, options: option, context: nil)
            events[key.rawValue] = Event()
        }
        let subscription = EventSubscription() { old, new in
            guard let oldData = old as? Data, let newData = new as? Data else {
                return
            }
            guard let oldValue = NSKeyedUnarchiver.unarchiveObject(with: oldData) as? T,
                let newValue = NSKeyedUnarchiver.unarchiveObject(with: newData) as? T else {
                return
            }
            using(ValueChange(oldValue, newValue))
        }
        events[key.rawValue]?.add(subscription: subscription)
        return subscription
    }
    
    @discardableResult public func subscribe<T>(key: PreferenceKey<T>, initial: Bool = false, using: @escaping (ValueChange<T>) -> Void) -> EventSubscription {
        if !events.keys.contains(key.rawValue) {
            let option: NSKeyValueObservingOptions = initial ? [.old, .new, .initial] : [.old, .new]
            defaults.addObserver(self, forKeyPath: key.rawValue, options: option, context: nil)
            events[key.rawValue] = Event()
        }
        let subscription = EventSubscription() { old, new in
            if let old = old as? T, let new = new as? T {
                using(ValueChange(old, new))
            }
        }
        events[key.rawValue]?.add(subscription: subscription)
        return subscription
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath,
            let event = events[keyPath] else {
                return
        }
        
        guard let old = change?[.oldKey], let new = change?[.newKey] else {
            return
        }
        
        event.notify(old, new)
        if event.subscriptions.count == 0 {
            events.removeValue(forKey: keyPath)
        }
    }
    
    deinit {
        for key in events.keys {
            defaults.removeObserver(self, forKeyPath: key)
        }
    }
    
}

extension EasyPreference {
    
    public subscript(_ key: PreferenceKey<String>) -> String? {
        get { return defaults.string(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: PreferenceKey<[Any]>) -> [Any]? {
        get { return defaults.array(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: PreferenceKey<[String: Any]>) -> [String: Any]? {
        get { return defaults.dictionary(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: PreferenceKey<Data>) -> Data? {
        get { return defaults.data(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: PreferenceKey<[String]>) -> [String]? {
        get { return defaults.stringArray(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: PreferenceKey<Int>) -> Int {
        get { return defaults.integer(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: PreferenceKey<Float>) -> Float {
        get { return defaults.float(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: PreferenceKey<Double>) -> Double {
        get { return defaults.double(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: PreferenceKey<Bool>) -> Bool {
        get { return defaults.bool(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: PreferenceKey<URL>) -> URL? {
        get { return defaults.url(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: PreferenceKey<Any>) -> Any? {
        get { return defaults.object(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    // Generic Subscripts has implemented in Swift 4.
    // before that, use getter/setter instead.
    
    public func unarchive<T: NSCoding>(for key: PreferenceKey<T>) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
    }
    
    public func archive<T: NSCoding>(_ newValue: T, for key: PreferenceKey<T>) {
        let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
        defaults.set(data, forKey: key.rawValue)
    }
}

public class PreferenceKeys {}

public class PreferenceKey<T>: PreferenceKeys, RawRepresentable, Hashable, ExpressibleByStringLiteral {
    
    public let rawValue: String
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    public required convenience init(rawValue: String) {
        self.init(rawValue)
    }
    
    public required convenience init(stringLiteral value: String) {
        self.init(value)
    }
}

extension ExpressibleByUnicodeScalarLiteral where Self: ExpressibleByStringLiteral, Self.StringLiteralType == String {
    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension ExpressibleByExtendedGraphemeClusterLiteral where Self: ExpressibleByStringLiteral, Self.StringLiteralType == String {
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}
