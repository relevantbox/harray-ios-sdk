//
// Created by YILDIRIM ADIGÜZEL on 24.04.2020.
// Copyright (c) 2022 relevantboxio. All rights reserved.
//

import XCTest
import UserNotifications

class NotificationProcessorHandlerTest: XCTestCase {

    func test_it_should_construct_push_receive_event_and_make_api_call() {
        let httpService = FakeHttpService(
            sdkKey: "sdk-key",
            session: FakeUrlSession(),
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )
        let entitySerializerService = CapturingEntitySerializerService.init()
        let notificationProcessorHandler = NotificationProcessorHandler(httpService: httpService, entitySerializerService: entitySerializerService)
        entitySerializerService.givenSerializeReturns(callWith: TestUtils.anyDictionary(), expect: "serialized_event")
        httpService.givenPostWithPayload(callWith: "serialized_event")

        notificationProcessorHandler.pushMessageDelivered(pushContent: ["nonce": "1", "campaignId": "campaignId", "customerId": "customerId"])

        let captured = entitySerializerService.getCapturedEvent()

        XCTAssertFalse(httpService.hasError)

        XCTAssertTrue("d" == captured["n"] as! String)
        XCTAssertTrue("campaignId" == captured["campaignId"] as! String)
        XCTAssertTrue("customerId" == captured["customerId"] as! String)
        XCTAssertTrue("1" == captured["nonce"] as! String)
        XCTAssertTrue("iosAppPush" == captured["pushType"] as! String)
    }

    func test_it_should_construct_push_opened_event_and_make_api_call() {
        let httpService = FakeHttpService(
            sdkKey: "sdk-key",
            session: FakeUrlSession(),
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )
        let entitySerializerService = CapturingEntitySerializerService.init()
        let notificationProcessorHandler = NotificationProcessorHandler(httpService: httpService, entitySerializerService: entitySerializerService)
        entitySerializerService.givenSerializeReturns(callWith: TestUtils.anyDictionary(), expect: "serialized_event")
        httpService.givenPostWithPayload(callWith: "serialized_event")

        notificationProcessorHandler.pushMessageOpened(pushContent: ["source": "relevantbox", "nonce": "1", "campaignId": "campaignId", "customerId": "customerId"])

        let captured = entitySerializerService.getCapturedEvent()

        XCTAssertFalse(httpService.hasError)

        XCTAssertTrue("d" == captured["n"] as! String)
        XCTAssertTrue("campaignId" == captured["campaignId"] as! String)
        XCTAssertTrue("customerId" == captured["customerId"] as! String)
        XCTAssertTrue("1" == captured["nonce"] as! String)
        XCTAssertTrue("iosAppPush" == captured["pushType"] as! String)
    }

    func test_it_should_not_construct_push_opened_event_and_make_api_call_when_source_is_not_defined() {
        let httpService = FakeHttpService(
            sdkKey: "sdk-key",
            session: FakeUrlSession(),
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )
        let entitySerializerService = CapturingEntitySerializerService.init()
        let notificationProcessorHandler = NotificationProcessorHandler(httpService: httpService, entitySerializerService: entitySerializerService)
        entitySerializerService.givenSerializeReturns(callWith: TestUtils.anyDictionary(), expect: "serialized_event")
        httpService.givenPostWithPayload(callWith: "serialized_event")

        notificationProcessorHandler.pushMessageOpened(pushContent: ["nonce": "1", "campaignId": "campaignId", "customerId": "customerId"])

        let captured = entitySerializerService.getCapturedEvent()

        XCTAssertFalse(httpService.hasError)

        XCTAssertNil(captured["n"])
        XCTAssertNil(captured["nonce"])
        XCTAssertNil(captured["campaignId"])
        XCTAssertNil(captured["customerId"])
    }

    func test_it_should_not_construct_push_opened_event_and_make_api_call_when_source_is_defined_other_than_rbio() {
        let httpService = FakeHttpService(
            sdkKey: "sdk-key",
            session: FakeUrlSession(),
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )
        let entitySerializerService = CapturingEntitySerializerService.init()
        let notificationProcessorHandler = NotificationProcessorHandler(httpService: httpService, entitySerializerService: entitySerializerService)
        entitySerializerService.givenSerializeReturns(callWith: TestUtils.anyDictionary(), expect: "serialized_event")
        httpService.givenPostWithPayload(callWith: "serialized_event")

        notificationProcessorHandler.pushMessageOpened(pushContent: ["source": "mennio", "nonce": "1", "campaignId": "campaignId", "customerId": "customerId])

        let captured = entitySerializerService.getCapturedEvent()

        XCTAssertFalse(httpService.hasError)

        XCTAssertNil(captured["n"])
        XCTAssertNil(captured["nonce"])
        XCTAssertNil(captured["campaignId"])
        XCTAssertNil(captured["customerId"])
    }
    
    func test_it_should_return_false_when_notification_is_not_rb_io_notification() {
        let httpService = FakeHttpService(
            sdkKey: "sdk-key",
            session: FakeUrlSession(),
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )
        let entitySerializerService = CapturingEntitySerializerService.init()
        let notificationProcessorHandler = NotificationProcessorHandler(httpService: httpService, entitySerializerService: entitySerializerService)
        
        let content = UNMutableNotificationContent()
        content.title = "Alert!"
        content.body = "Something happened"

        let request = UNNotificationRequest(
          identifier: "id",
          content: content,
          trigger: UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
          )
        XCTAssertFalse(notificationProcessorHandler.isRBNotification(request: request))
    }
    
    func test_it_should_return_true_when_notification_is_not_rb_io_notification() {
        let httpService = FakeHttpService(
            sdkKey: "sdk-key",
            session: FakeUrlSession(),
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )
        let entitySerializerService = CapturingEntitySerializerService.init()
        let notificationProcessorHandler = NotificationProcessorHandler(httpService: httpService, entitySerializerService: entitySerializerService)
        
        let content = UNMutableNotificationContent()
        content.title = "Alert!"
        content.body = "Something happened"
        content.userInfo = ["source": "relevantboxio"]

        let request = UNNotificationRequest(
          identifier: "id",
          content: content,
          trigger: UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
          )
        XCTAssertTrue(notificationProcessorHandler.isRBNotification(request: request))
    }
}
