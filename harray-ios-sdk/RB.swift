//
//  RB.swift
//  harray-ios-sdk
//
//  Created by YILDIRIM ADIGÜZEL on 21.04.2020.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import Foundation
import UIKit

@objc public final class RB: NSObject {

    static var instance: RB?

    let sessionContextHolder: SessionContextHolder
    private let rbConfig: RBConfig
    private var pushNotificationToken: String = ""
    private let applicationContextHolder: ApplicationContextHolder
    private let eventProcessorHandler: EventProcessorHandler
    private let sdkEventProcessorHandler: SDKEventProcessorHandler
    private let notificationProcessorHandler: NotificationProcessorHandler
    private let ecommerceEventProcessorHandler: EcommerceEventProcessorHandler
    private let recommendationProcessorHandler: RecommendationProcessorHandler
    private let browsingHistoryProcessorHandler: BrowsingHistoryProcessorHandler
    private let pushMessagesHistoryProcessorHandler: PushMessagesHistoryProcessorHandler

    private init(rbConfig: RBConfig,
                 sessionContextHolder: SessionContextHolder,
                 applicationContextHolder: ApplicationContextHolder,
                 eventProcessorHandler: EventProcessorHandler,
                 sdkEventProcessorHandler: SDKEventProcessorHandler,
                 notificationProcessorHandler: NotificationProcessorHandler,
                 ecommerceEventProcessorHandler: EcommerceEventProcessorHandler,
                 recommendationProcessorHandler: RecommendationProcessorHandler,
                 browsingHistoryProcessorHandler: BrowsingHistoryProcessorHandler,
                 pushMessagesHistoryProcessorHandler: PushMessagesHistoryProcessorHandler
                 ) {
        self.sessionContextHolder = sessionContextHolder
        self.applicationContextHolder = applicationContextHolder
        self.eventProcessorHandler = eventProcessorHandler
        self.sdkEventProcessorHandler = sdkEventProcessorHandler
        self.notificationProcessorHandler = notificationProcessorHandler
        self.ecommerceEventProcessorHandler = ecommerceEventProcessorHandler
        self.rbConfig = rbConfig
        self.recommendationProcessorHandler = recommendationProcessorHandler
        self.browsingHistoryProcessorHandler = browsingHistoryProcessorHandler
        self.pushMessagesHistoryProcessorHandler = pushMessagesHistoryProcessorHandler
    }
    
    @available(iOSApplicationExtension,unavailable)
    @objc public class func configure(rbConfig: RBConfig) {
        let sessionContextHolder = SessionContextHolder()
        let applicationContextHolder = ApplicationContextHolder(userDefaults: UserDefaults.standard)
        let httpService = HttpService(sdkKey: rbConfig.getSdkKey(), session: URLSession.shared, collectorUrl: rbConfig.getCollectorUrl(), apiUrl: rbConfig.getApiUrl())
        let inAppNotificationsHttpService = HttpService(sdkKey: rbConfig.getSdkKey(), session: URLSession.shared, collectorUrl: rbConfig.getCollectorUrl(), apiUrl: rbConfig.getInAppNotificationsUrl())
        let entitySerializerService = EntitySerializerService(encodingService: EncodingService(), jsonSerializerService: JsonSerializerService())
        let deviceService = DeviceService(bundle: Bundle.main, uiDevice: UIDevice.current, uiScreen: UIScreen.main, locale: Locale.current)
        let chainProcessorHandler = ChainProcessorHandler()
        
        let eventProcessorHandler = EventProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder, httpService: httpService, entitySerializerService: entitySerializerService, chainProcessorHandler: chainProcessorHandler)
        let sdkEventProcessorHandler = SDKEventProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder, httpService: httpService, entitySerializerService: entitySerializerService, deviceService: deviceService)
        let notificationProcessorHandler = NotificationProcessorHandler(httpService: httpService, entitySerializerService: entitySerializerService)
        let ecommerceEventProcessorHandler = EcommerceEventProcessorHandler(eventProcessorHandler: eventProcessorHandler)
        let jsonDeserializerService = JsonDeserializerService()
        let recommendationProcessorHandler = RecommendationProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder, httpService: httpService, sdkKey: rbConfig.getSdkKey(), jsonDeserializerService: jsonDeserializerService)
        let browsingHistoryProcessorHandler = BrowsingHistoryProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder, httpService: httpService, sdkKey: rbConfig.getSdkKey(), jsonDeserializerService: jsonDeserializerService)
        let pushMessagesHistoryProcessorHandler = PushMessagesHistoryProcessorHandler(sessionContextHolder: sessionContextHolder, httpService: httpService, sdkKey: rbConfig.getSdkKey(), jsonDeserializerService: jsonDeserializerService)
        
        let inAppNotificationProcessorHandler =
            InAppNotificationProcessorHandler(applicationContextHolder: applicationContextHolder, sessionContextHolder: sessionContextHolder, httpService: inAppNotificationsHttpService, eventProcessorHandler: eventProcessorHandler, rbConfig: rbConfig, jsonDeserializerService: jsonDeserializerService, deviceService: deviceService)
        
        chainProcessorHandler.addHandler(handler: inAppNotificationProcessorHandler)

        instance = RB(rbConfig: rbConfig,
                          sessionContextHolder: sessionContextHolder,
                          applicationContextHolder: applicationContextHolder,
                          eventProcessorHandler: eventProcessorHandler,
                          sdkEventProcessorHandler: sdkEventProcessorHandler,
                          notificationProcessorHandler: notificationProcessorHandler,
                          ecommerceEventProcessorHandler: ecommerceEventProcessorHandler,
                          recommendationProcessorHandler: recommendationProcessorHandler,
                          browsingHistoryProcessorHandler: browsingHistoryProcessorHandler,
                          pushMessagesHistoryProcessorHandler: pushMessagesHistoryProcessorHandler
        )
    }


    class func getInstance() -> RB {
        return instance!
    }

    @objc public class func eventing() -> EventProcessorHandler {
        let rbioInstance = getInstance()
        let sessionContextHolder = rbioInstance.sessionContextHolder
        if (sessionContextHolder.getSessionState() != SessionState.SESSION_STARTED) {
            rbioInstance.sdkEventProcessorHandler.sessionStart()
            sessionContextHolder.startSession()
            if (rbioInstance.applicationContextHolder.isNewInstallation()){
                rbioInstance.sdkEventProcessorHandler.newInstallation()
                rbioInstance.applicationContextHolder.setInstallationCompleted()
            }
        }
        return rbioInstance.eventProcessorHandler
    }

    @objc public class func notifications() -> NotificationProcessorHandler {
        let entitySerializerService = EntitySerializerService(encodingService: EncodingService(), jsonSerializerService: JsonSerializerService())
        let httpService = HttpService(sdkKey: "feedback", session: URLSession.shared, collectorUrl: Constants.RB_COLLECTOR_URL.rawValue,
                                      apiUrl: Constants.RB_API_URL.rawValue)
        return NotificationProcessorHandler(httpService: httpService, entitySerializerService: entitySerializerService)
    }

    @objc public class func login(memberId: String) {
        let rbInstance = getInstance()
        let sessionContextHolder = getInstance().sessionContextHolder
        if ("" != memberId) && sessionContextHolder.getMemberId() != memberId {
            sessionContextHolder.login(memberId: memberId)
            sessionContextHolder.restartSession()
            if "" != getInstance().pushNotificationToken {
                rbInstance.eventProcessorHandler.savePushToken(deviceToken: getInstance().pushNotificationToken)
            }
        }
    }

    @objc public class func savePushToken(deviceToken: String) {
        getInstance().pushNotificationToken = deviceToken
        getInstance().eventProcessorHandler.savePushToken(deviceToken: deviceToken)
    }
    
    @objc public class func logout() {
        getInstance().eventProcessorHandler.removeTokenAssociation(deviceToken: getInstance().pushNotificationToken);
        getInstance().pushNotificationToken = ""
        getInstance().sessionContextHolder.logout()
        getInstance().sessionContextHolder.restartSession()
    }

    @objc public class func synchronizeWith(externalParameters: Dictionary<String, Any>) {
        getInstance().sessionContextHolder.updateExternalParameters(data: externalParameters)
        getInstance().sessionContextHolder.restartSession()
    }

    @objc public class func ecommerce() -> EcommerceEventProcessorHandler {
        return getInstance().ecommerceEventProcessorHandler
    }
    
    @objc public class func recommendations() -> RecommendationProcessorHandler {
        return getInstance().recommendationProcessorHandler
    }

    @objc public class func browsingHistory() -> BrowsingHistoryProcessorHandler {
        return getInstance().browsingHistoryProcessorHandler
    }
    
    @objc public class func pushMessagesHistory() -> PushMessagesHistoryProcessorHandler {
        return getInstance().pushMessagesHistoryProcessorHandler
    }
}
