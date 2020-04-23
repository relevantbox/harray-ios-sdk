//
// Created by YILDIRIM ADIGÜZEL on 23.04.2020.
// Copyright (c) 2020 xennio. All rights reserved.
//

import XCTest

class SDKEventProcessorHandlerTest: XCTestCase {

    func test_it_should_construct_session_start_event_and_make_api_call() {
        let sessionContextHolder = FakeSessionContextHolder().withExtraParameters(["utm_medium": "xennio"])
        let applicationContextHolder = FakeApplicationContextHolder(userDefaults: InitializedUserDefaults(), sdkKey: "SDK-KEY")

        let httpService = FakeHttpService(collectorUrl: "collector-url")
        let entitySerializerService = CapturingEntitySerializerService.init()
        let fakeDeviceService = FakeDeviceService()
        let sdkEventProcessorHandler = SDKEventProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder,
                httpService: httpService, entitySerializerService: entitySerializerService,
                deviceService: fakeDeviceService)

        entitySerializerService.givenSerializeReturns(callWith: TestUtils.anyDictionary(), expect: "serialized_event")
        httpService.givenPostWithPayload(callWith: "serialized_event")

        sdkEventProcessorHandler.sessionStart()

        let captured = entitySerializerService.getCapturedEvent()

        XCTAssertFalse(httpService.hasError)
        XCTAssertTrue(httpService.invoked)

        let header = captured["h"] as! Dictionary<String, Any>
        let body = captured["b"] as! Dictionary<String, Any>

        XCTAssertTrue("SS" == header["n"] as! String)
        XCTAssertTrue(applicationContextHolder.getPersistentId() == header["p"] as! String)
        XCTAssertTrue(sessionContextHolder.getSessionId() == header["s"] as! String)
        XCTAssertTrue(sessionContextHolder.getMemberId() == body["memberId"] as! String)
        XCTAssertTrue(applicationContextHolder.getSdkVersion() == header["sv"] as! String)
        XCTAssertTrue("IOS \(fakeDeviceService.getOsVersion())" == body["os"] as! String)
        XCTAssertTrue(fakeDeviceService.getManufacturer() == body["mn"] as! String)
        XCTAssertTrue(fakeDeviceService.getBrand() == body["br"] as! String)
        XCTAssertTrue(fakeDeviceService.getCarrier() == body["op"] as! String)
        XCTAssertTrue(fakeDeviceService.getAppVersion() == body["av"] as! String)
        XCTAssertTrue(applicationContextHolder.getTimezone() == body["zn"] as! String)
        XCTAssertTrue("xennio" == body["utm_medium"] as! String)
    }

    func test_it_should_not_invoke_http_service_when_serializer_service_has_error_on_session_start() {
        let sessionContextHolder = FakeSessionContextHolder().withExtraParameters(["utm_medium": "xennio"])
        let applicationContextHolder = FakeApplicationContextHolder(userDefaults: InitializedUserDefaults(), sdkKey: "SDK-KEY")

        let httpService = FakeHttpService(collectorUrl: "collector-url")
        let entitySerializerService = CapturingEntitySerializerService.init()

        let fakeDeviceService = FakeDeviceService()
        let sdkEventProcessorHandler = SDKEventProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder,
                httpService: httpService, entitySerializerService: entitySerializerService,
                deviceService: fakeDeviceService)

        entitySerializerService.givenSerializeReturns(callWith: TestUtils.anyDictionary(), expect: nil)

        sdkEventProcessorHandler.sessionStart()

        XCTAssertFalse(httpService.invoked)
    }


    func test_it_should_construct_heart_beat_event_and_make_api_call() {
        ClockUtils.freeze(expectedTime: 1587237170000)
        let sessionContextHolder = FakeSessionContextHolder().withExtraParameters(["utm_medium": "xennio"]).withLastActivityTime(1584558770000)
        let applicationContextHolder = FakeApplicationContextHolder(userDefaults: InitializedUserDefaults(), sdkKey: "SDK-KEY")

        let httpService = FakeHttpService(collectorUrl: "collector-url")
        let entitySerializerService = CapturingEntitySerializerService.init()
        let fakeDeviceService = FakeDeviceService()
        let sdkEventProcessorHandler = SDKEventProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder,
                httpService: httpService, entitySerializerService: entitySerializerService,
                deviceService: fakeDeviceService)

        entitySerializerService.givenSerializeReturns(callWith: TestUtils.anyDictionary(), expect: "serialized_event")
        httpService.givenPostWithPayload(callWith: "serialized_event")

        sdkEventProcessorHandler.heatBeat()

        let captured = entitySerializerService.getCapturedEvent()

        XCTAssertFalse(httpService.hasError)
        XCTAssertTrue(httpService.invoked)

        let header = captured["h"] as! Dictionary<String, Any>
        let body = captured["b"] as! Dictionary<String, Any>

        XCTAssertTrue("HB" == header["n"] as! String)
        XCTAssertTrue(applicationContextHolder.getPersistentId() == header["p"] as! String)
        XCTAssertTrue(sessionContextHolder.getSessionId() == header["s"] as! String)
        XCTAssertTrue(sessionContextHolder.getMemberId() == body["memberId"] as! String)
        XCTAssertNil(body["utm_medium"])
        ClockUtils.unFreeze()
    }

    func it_should_not_send_heart_beat_event_when_last_event_time_is_not_before_current_time_minus_interval() {
        ClockUtils.freeze(expectedTime: 1587237294000)
        let sessionContextHolder = FakeSessionContextHolder().withExtraParameters(["utm_medium": "xennio"]).withLastActivityTime(1587237260000)
        let applicationContextHolder = FakeApplicationContextHolder(userDefaults: InitializedUserDefaults(), sdkKey: "SDK-KEY")

        let httpService = FakeHttpService(collectorUrl: "collector-url")
        let entitySerializerService = CapturingEntitySerializerService.init()
        let fakeDeviceService = FakeDeviceService()
        let sdkEventProcessorHandler = SDKEventProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder,
                httpService: httpService, entitySerializerService: entitySerializerService,
                deviceService: fakeDeviceService)

        entitySerializerService.givenSerializeReturns(callWith: TestUtils.anyDictionary(), expect: "serialized_event")
        httpService.givenPostWithPayload(callWith: "serialized_event")

        sdkEventProcessorHandler.heatBeat()

        XCTAssertFalse(httpService.invoked)

        ClockUtils.unFreeze()
    }

    func test_it_should_not_invoke_http_service_when_serializer_service_has_error_on_heart_beat() {
        ClockUtils.freeze(expectedTime: 1587237170000)
        let sessionContextHolder = FakeSessionContextHolder().withExtraParameters(["utm_medium": "xennio"]).withLastActivityTime(1584558770000)
        let applicationContextHolder = FakeApplicationContextHolder(userDefaults: InitializedUserDefaults(), sdkKey: "SDK-KEY")

        let httpService = FakeHttpService(collectorUrl: "collector-url")
        let entitySerializerService = CapturingEntitySerializerService.init()

        let fakeDeviceService = FakeDeviceService()
        let sdkEventProcessorHandler = SDKEventProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder,
                httpService: httpService, entitySerializerService: entitySerializerService,
                deviceService: fakeDeviceService)

        entitySerializerService.givenSerializeReturns(callWith: TestUtils.anyDictionary(), expect: nil)
        sdkEventProcessorHandler.heatBeat()

        XCTAssertFalse(httpService.invoked)
        ClockUtils.unFreeze()
    }


}