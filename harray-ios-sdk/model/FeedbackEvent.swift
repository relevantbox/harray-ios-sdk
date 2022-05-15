//
// Created by Yildirim Adiguzel on 3.05.2020.
// Copyright (c) 2022 relevantboxio. All rights reserved.
//

import Foundation

class FeedbackEvent {
    private var event: Dictionary<String, Any> = Dictionary<String, Any>()

    class func create(name: String) -> FeedbackEvent {
        let feedbackEvent = FeedbackEvent()
        feedbackEvent.event["n"] = name
        feedbackEvent.event["pushType"] = "iosAppPush"
        return feedbackEvent
    }

    func addParameter(key: String, value: Any) -> FeedbackEvent {
        event[key] = value
        return self
    }

    func toMap() -> Dictionary<String, Any> {
        return event
    }

}