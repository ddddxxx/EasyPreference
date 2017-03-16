//
//  Event.swift
//  EasyPreference
//
//  Created by 邓翔 on 2017/3/16.
//
//

import Foundation

public class EventSubscription {
    
    typealias HandlerType = (_ old: Any, _ new: Any) -> Void
    
    var handler: HandlerType
    
    var isValid: Bool = true
    
    init(_ handler: @escaping HandlerType) {
        self.handler = handler
    }
    
    public func invalidate() {
        handler = {_,_ in }
        isValid = false
    }
    
}

class Event {
    
    var subscriptions: [EventSubscription]
    
    init() {
        subscriptions = []
    }
    
    func notify(_ old: Any, _ new: Any) {
        subscriptions = subscriptions.filter() {$0.isValid}
        for subscription in subscriptions {
            subscription.handler(old, new)
        }
    }
    
    func add(subscription: EventSubscription) {
        subscriptions.append(subscription)
    }
    
}
