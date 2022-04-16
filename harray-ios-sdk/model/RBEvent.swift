//
//  RBEvent.swift
//  harray-ios-sdk
//
//  Created by YILDIRIM ADIGÜZEL on 21.04.2020.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import Foundation

class RBEvent{
    
    private var h : Dictionary<String, Any> = Dictionary<String, Any>()
    private var b : Dictionary<String, Any> = Dictionary<String, Any>()
    
    class func create(name:String, persistentId: String, sessionId: String) -> RBEvent {
        let rbEvent = RBEvent()
        rbEvent.h["n"] = name
        rbEvent.h["p"] = persistentId
        rbEvent.h["s"] = sessionId
        return rbEvent
    }

    func addHeader(key:String, value: Any) -> RBEvent {
        h[key] = value
        return self
    }
    
    func addBody(key:String, value: Any) -> RBEvent {
        b[key] = value
        return self
    }
    
    func memberId(memberId: String?) -> RBEvent {
        if memberId != nil{
            if memberId != "" {
                return addBody(key: "memberId", value: memberId!)
            }
        }
        return self
    }
    
    func appendExtra(params: Dictionary<String, Any>) -> RBEvent {
        for eachParam in params {
            b[eachParam.key] = eachParam.value
        }
        return self
    }
    
    func toMap() -> Dictionary<String, Any> {
        var map = Dictionary<String,Any>()
        map["h"] = h
        map["b"] = b
        return map
    }
    
}
