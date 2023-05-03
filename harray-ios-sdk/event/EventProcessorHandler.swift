//
//  EventProcessorHandler.swift
//  harray-ios-sdk
//
//  Created by YILDIRIM ADIGÜZEL on 21.04.2020.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import Foundation

@objc public class EventProcessorHandler: NSObject {

    private let applicationContextHolder: ApplicationContextHolder
    private let sessionContextHolder: SessionContextHolder
    private let httpService: HttpService
    private let entitySerializerService: EntitySerializerService
    private let chainProcessorHandler : ChainProcessorHandler

    init(applicationContextHolder: ApplicationContextHolder, sessionContextHolder: SessionContextHolder, httpService: HttpService, entitySerializerService: EntitySerializerService, chainProcessorHandler : ChainProcessorHandler) {
        self.applicationContextHolder = applicationContextHolder
        self.sessionContextHolder = sessionContextHolder
        self.httpService = httpService
        self.entitySerializerService = entitySerializerService
        self.chainProcessorHandler = chainProcessorHandler
    }

    @objc public func pageView(pageType: String) {
        pageView(pageType: pageType, params: Dictionary<String, Any>())
    }

    @objc public func pageView(pageType: String, params: Dictionary<String, Any>) {
        let event = RBEvent.create(name: "PV", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .addBody(key: "pageType", value: pageType)
                .memberId(memberId: sessionContextHolder.getMemberId())
                .appendExtra(params: params)
        let serializedEvent = entitySerializerService.serializeToBase64(event: event.toMap())
        httpService.postFormUrlEncoded(payload: serializedEvent)
        chainProcessorHandler.callAll(event: event)
    }

    @objc public func actionResult(type: String) {
        actionResult(type: type, params: Dictionary<String, Any>())
    }

    @objc public func actionResult(type: String, params: Dictionary<String, Any>) {
        let event = RBEvent.create(name: "AR", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .addBody(key: "type", value: type)
                .memberId(memberId: sessionContextHolder.getMemberId())
                .appendExtra(params: params)
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: event)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }

    @objc public func impression(pageType: String) {
        impression(pageType: pageType, params: Dictionary<String, Any>())
    }

    @objc public func impression(pageType: String, params: Dictionary<String, Any>) {
        let event = RBEvent.create(name: "IM", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .addBody(key: "type", value: pageType)
                .memberId(memberId: sessionContextHolder.getMemberId())
                .appendExtra(params: params)
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: event)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }

    @objc public func custom(eventName: String, params: Dictionary<String, Any>) {
        let event = RBEvent.create(name: eventName, persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .memberId(memberId: sessionContextHolder.getMemberId())
                .appendExtra(params: params)
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: event)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }

    @objc func savePushToken(deviceToken: String) {
        let event = RBEvent.create(name: "Collection", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .memberId(memberId: sessionContextHolder.getMemberId())
                .addBody(key: "name", value: "pushToken")
                .addBody(key: "type", value: "iosToken")
                .addBody(key: "appType", value: "iosAppPush")
                .addBody(key: "deviceToken", value: deviceToken)
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: event)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }
    
    func removeTokenAssociation(deviceToken: String) {
        let event = RBEvent.create(name: "TR", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .memberId(memberId: sessionContextHolder.getMemberId())
                .addBody(key: "name", value: "pushToken")
                .addBody(key: "type", value: "iosToken")
                .addBody(key: "appType", value: "iosAppPush")
                .addBody(key: "deviceToken", value: deviceToken)
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: event)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }
}
