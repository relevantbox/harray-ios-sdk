//
//  SDKEventProcessorHandler.swift
//  harray-ios-sdk
//
//  Created by YILDIRIM ADIGÜZEL on 22.04.2020.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import Foundation

class SDKEventProcessorHandler {

    private let HEART_BEAT_INTERVAL: Int64 = 55000
    private let applicationContextHolder: ApplicationContextHolder
    private let sessionContextHolder: SessionContextHolder
    private let httpService: HttpService
    private let entitySerializerService: EntitySerializerService
    private let deviceService: DeviceService

    init(applicationContextHolder: ApplicationContextHolder,
         sessionContextHolder: SessionContextHolder, httpService: HttpService,
         entitySerializerService: EntitySerializerService,
         deviceService: DeviceService) {
        self.applicationContextHolder = applicationContextHolder
        self.sessionContextHolder = sessionContextHolder
        self.httpService = httpService
        self.entitySerializerService = entitySerializerService
        self.deviceService = deviceService
    }

    func sessionStart() {
        let sessionStartEvent = RBEvent.create(name: "SS", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .addHeader(key: "sv", value: applicationContextHolder.getSdkVersion())
                .memberId(memberId: sessionContextHolder.getMemberId())
                .addBody(key: "os", value: Constants.IOS.rawValue)
                .addBody(key: "osv", value: deviceService.getOsVersion())
                .addBody(key: "mn", value: deviceService.getManufacturer())
                .addBody(key: "br", value: deviceService.getBrand())
                .addBody(key: "md", value: deviceService.getDeviceModel())
                .addBody(key: "op", value: deviceService.getCarrier())
                .addBody(key: "av", value: deviceService.getAppVersion())
                .addBody(key: "zn", value: applicationContextHolder.getTimezone())
                .addBody(key: "sw", value: deviceService.getScreenWidth())
                .addBody(key: "sh", value: deviceService.getScreenHeight())
                .addBody(key: "ln", value: deviceService.getLanguage())
                .addBody(key: "rt", value: !applicationContextHolder.isNewInstallation())
                .appendExtra(params: sessionContextHolder.getExternalParameters())
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: sessionStartEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }
    
    func newInstallation() {
        let pageViewEvent = RBEvent.create(name: "NI", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                .memberId(memberId: sessionContextHolder.getMemberId())
                .toMap()
        let serializedEvent = entitySerializerService.serializeToBase64(event: pageViewEvent)
        httpService.postFormUrlEncoded(payload: serializedEvent)
    }

    func heatBeat() {
        if (sessionContextHolder.getLastActivityTime() < ClockUtils.getTime() - HEART_BEAT_INTERVAL) {
            let pageViewEvent = RBEvent.create(name: "HB", persistentId: applicationContextHolder.getPersistentId(), sessionId: sessionContextHolder.getSessionId())
                    .memberId(memberId: sessionContextHolder.getMemberId())
                    .toMap()
            let serializedEvent = entitySerializerService.serializeToBase64(event: pageViewEvent)
            httpService.postFormUrlEncoded(payload: serializedEvent)
        }
    }
}
