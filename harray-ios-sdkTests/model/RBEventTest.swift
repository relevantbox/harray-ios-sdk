//
//  RBEventTest.swift
//  harray-ios-sdkTests
//
//  Created by YILDIRIM ADIGÜZEL on 21.04.2020.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import XCTest

class RBEventTest: XCTestCase {

    func test_it_should_construct_fields_properly(){
        let eventName = "test"
        let extraParams: Dictionary<String, Any> = [
            "body3": "extra1",
            "body4": "extra2"
        ]

        let rbEvent = RBEvent
                .create(name: eventName, persistentId: "pid", sessionId: "sid")
                .memberId(memberId: "memberId")
                .addHeader(key: "header2", value: "value1")
                .addHeader(key:"header1", value: "value2")
                .addBody(key:"body1", value: 1)
                .addBody(key:"body2", value: "stringValue")
                .appendExtra(params: extraParams)

        let rbEventMap = rbEvent.toMap()
        let header = rbEventMap["h"] as! Dictionary<String, Any>
        let body = rbEventMap["b"] as! Dictionary<String, Any>

        XCTAssertTrue(eventName == header["n"] as! String)
        XCTAssertTrue("pid" == header["p"] as! String)
        XCTAssertTrue("sid" == header["s"] as! String)
        XCTAssertTrue("value1" == header["header2"] as! String)
        XCTAssertTrue("value2" == header["header1"] as! String)
        XCTAssertTrue(1 == body["body1"] as! Int)
        XCTAssertTrue("stringValue" == body["body2"] as! String)
        XCTAssertTrue("memberId" == body["memberId"] as! String)
        XCTAssertTrue("extra1" == body["body3"] as! String)
        XCTAssertTrue("extra2" == body["body4"] as! String)
    }

    func test_it_should_not_add_member_id_when_empty_string_set_to_member_id(){
        let eventName = "test"
        let extraParams: Dictionary<String, Any> = [
            "body3": "extra1",
            "body4": "extra2"
        ]

        let rbEvent = RBEvent
                .create(name: eventName, persistentId: "pid", sessionId: "sid")
                .memberId(memberId: "")
                .addHeader(key: "header2", value: "value1")
                .addHeader(key:"header1", value: "value2")
                .addBody(key:"body1", value: 1)
                .addBody(key:"body2", value: "stringValue")
                .appendExtra(params: extraParams)

        let rbEventMap = rbEvent.toMap()
        let header = rbEventMap["h"] as! Dictionary<String, Any>
        let body = rbEventMap["b"] as! Dictionary<String, Any>

        XCTAssertTrue(eventName == header["n"] as! String)
        XCTAssertTrue("pid" == header["p"] as! String)
        XCTAssertTrue("sid" == header["s"] as! String)
        XCTAssertTrue("value1" == header["header2"] as! String)
        XCTAssertTrue("value2" == header["header1"] as! String)
        XCTAssertTrue(1 == body["body1"] as! Int)
        XCTAssertTrue("stringValue" == body["body2"] as! String)
        XCTAssertTrue("extra1" == body["body3"] as! String)
        XCTAssertTrue("extra2" == body["body4"] as! String)

        XCTAssertNil(body["memberId"])
    }
}
