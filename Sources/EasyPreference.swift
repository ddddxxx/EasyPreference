//
//  EasyPreference.swift
//  EasyPreference
//
//  Created by 邓翔 on 2017/3/16.
//
//

import Foundation

public class EasyPreference: NSObject {
    
    let defaults: UserDefaults
    
    var events = [String: [Observing]]()
    
    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    @discardableResult public func addObserver<T: NSCoding>(key: Key<T>, initial: Bool = false, using: @escaping (ValueChange<T>) -> Void) -> Observing {
        if !events.keys.contains(key.rawValue) {
            let option: NSKeyValueObservingOptions = initial ? [.old, .new, .initial] : [.old, .new]
            defaults.addObserver(self, forKeyPath: key.rawValue, options: option, context: nil)
            events[key.rawValue] = []
        }
        let subscription = Observing() { old, new in
            guard let oldData = old as? Data, let newData = new as? Data else {
                return
            }
            guard let oldValue = NSKeyedUnarchiver.unarchiveObject(with: oldData) as? T,
                let newValue = NSKeyedUnarchiver.unarchiveObject(with: newData) as? T else {
                return
            }
            using(ValueChange(oldValue, newValue))
        }
        events[key.rawValue]?.append(subscription)
        return subscription
    }
    
    @discardableResult public func addObserver<T>(key: Key<T>, initial: Bool = false, using: @escaping (ValueChange<T>) -> Void) -> Observing {
        if !events.keys.contains(key.rawValue) {
            let option: NSKeyValueObservingOptions = initial ? [.old, .new, .initial] : [.old, .new]
            defaults.addObserver(self, forKeyPath: key.rawValue, options: option, context: nil)
            events[key.rawValue] = []
        }
        let subscription = Observing() { old, new in
            if let old = old as? T, let new = new as? T {
                using(ValueChange(old, new))
            }
        }
        events[key.rawValue]?.append(subscription)
        return subscription
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        
        events[keyPath] = observings.filter { $0.isValid }
        guard let observings = events[keyPath] else { return }
        
        guard let old = change?[.oldKey], let new = change?[.newKey] else { return }
        
        observings.forEach { $0.handler(old, new) }
        
        if observings.isEmpty {
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
    
    public struct ValueChange<T> {
        
        public let oldValue: T
        
        public let newValue: T
        
        init(_ old: T, _ new: T) {
            oldValue = old
            newValue = new
        }
    }
}

extension EasyPreference {
    
    public class Observing {
        
        typealias HandlerType = (_ old: Any, _ new: Any) -> Void
        
        var handler: HandlerType
        
        var isValid = true
        
        init(_ handler: @escaping HandlerType) {
            self.handler = handler
        }
        
        public func invalidate() {
            handler = {_,_ in }
            isValid = false
        }
    }
}

extension EasyPreference {
    
    public subscript(_ key: Key<String>) -> String? {
        get { return defaults.string(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: Key<[Any]>) -> [Any]? {
        get { return defaults.array(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: Key<[String: Any]>) -> [String: Any]? {
        get { return defaults.dictionary(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: Key<Data>) -> Data? {
        get { return defaults.data(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: Key<[String]>) -> [String]? {
        get { return defaults.stringArray(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: Key<Int>) -> Int {
        get { return defaults.integer(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: Key<Float>) -> Float {
        get { return defaults.float(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: Key<Double>) -> Double {
        get { return defaults.double(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: Key<Bool>) -> Bool {
        get { return defaults.bool(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: Key<URL>) -> URL? {
        get { return defaults.url(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    public subscript(_ key: Key<Any>) -> Any? {
        get { return defaults.object(forKey: key.rawValue) }
        set { defaults.set(newValue, forKey: key.rawValue) }
    }
    
    // Generic Subscripts has implemented in Swift 4.
    // before that, use getter/setter instead.
    
    public func unarchive<T: NSCoding>(for key: Key<T>) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
    }
    
    public func archive<T: NSCoding>(_ newValue: T, for key: Key<T>) {
        let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
        defaults.set(data, forKey: key.rawValue)
    }
}

extension EasyPreference {

    public class Keys {}

    public class Key<T>: Keys, RawRepresentable, Hashable, ExpressibleByStringLiteral {
        
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
