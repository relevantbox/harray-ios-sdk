//
// Created by YILDIRIM ADIGÜZEL on 22.04.2020.
// Copyright (c) 2022 relevantboxio. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

@objc public class NotificationProcessorHandler: NSObject {

    private let httpService: HttpService
    private let entitySerializerService: EntitySerializerService

    init(httpService: HttpService, entitySerializerService: EntitySerializerService) {
        self.httpService = httpService
        self.entitySerializerService = entitySerializerService
    }

    @objc public func pushMessageDelivered(pushContent: Dictionary<AnyHashable, Any>) {
        let customerId = getContentItem(key: Constants.CUSTOMER_ID_KEY.rawValue, pushContent: pushContent)
        let campaignId = getContentItem(key: Constants.CAMPAIGN_ID_KEY.rawValue, pushContent: pushContent)
        let campaignNonce = getContentItem(key: Constants.CAMPAIGN_NONCE.rawValue, pushContent: pushContent)
        let pushReceivedEvent = FeedbackEvent.create(name: "d")
                .addParameter(key: "nonce", value: campaignNonce!)
                .addParameter(key: "campaignId", value: campaignId!)
                .addParameter(key: "customerId", value: customerId!)
                .toMap()
        let serializedEvent = entitySerializerService.serializeToJson(event: pushReceivedEvent)
        httpService.postJsonEncoded(payload: serializedEvent, path: Constants.PUSH_FEED_BACK_PATH.rawValue)
    }

    @objc public func pushMessageOpened(pushContent: Dictionary<AnyHashable, Any>) {
        let source = pushContent[Constants.PUSH_PAYLOAD_SOURCE.rawValue]
        if source != nil {
            let pushChannelId = source as? String
            if Constants.PUSH_CHANNEL_ID.rawValue == pushChannelId! {
                let customerId = getContentItem(key: Constants.CUSTOMER_ID_KEY.rawValue, pushContent: pushContent)
                let campaignId = getContentItem(key: Constants.CAMPAIGN_ID_KEY.rawValue, pushContent: pushContent)
                let campaignNonce = getContentItem(key: Constants.CAMPAIGN_NONCE.rawValue, pushContent: pushContent)
                let pushOpenedEvent = FeedbackEvent.create(name: "o")
                        .addParameter(key: "nonce", value: campaignNonce!)
                        .addParameter(key: "campaignId", value: campaignId!)
                        .addParameter(key: "customerId", value: customerId!)
                        .toMap()
                let serializedEvent = entitySerializerService.serializeToJson(event: pushOpenedEvent)
                httpService.postJsonEncoded(payload: serializedEvent, path: Constants.PUSH_FEED_BACK_PATH.rawValue)
            }
        }
    }

    @objc public func handlePushNotification(userInfo: Dictionary<AnyHashable, Any>) {
        let source = userInfo[Constants.PUSH_PAYLOAD_SOURCE.rawValue]
        if source != nil {
            let pushChannelId = source as? String
            if Constants.PUSH_CHANNEL_ID.rawValue == pushChannelId! {
                pushMessageDelivered(pushContent: userInfo)
            }
        }
    }
    
    @objc public func isRBNotification(request: UNNotificationRequest) -> Bool {
        let source = request.content.userInfo[Constants.PUSH_PAYLOAD_SOURCE.rawValue]
        if source != nil {
            let pushChannelId = source as? String
            if Constants.PUSH_CHANNEL_ID.rawValue == pushChannelId!{
                return true
            }
        }
        return false
    }

    @objc public func handlePushNotification(request: UNNotificationRequest,
                                             bestAttemptContent: UNMutableNotificationContent,
                                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {

        let source = request.content.userInfo[Constants.PUSH_PAYLOAD_SOURCE.rawValue]
        if source != nil {
            let pushChannelId = source as? String
            if Constants.PUSH_CHANNEL_ID.rawValue == pushChannelId! {
                pushMessageDelivered(pushContent: request.content.userInfo)
                let imageUrl = request.content.userInfo[Constants.PUSH_PAYLOAD_IMAGE_URL.rawValue] as? String
                if imageUrl != nil {
                    httpService.downloadContent(endpoint: imageUrl) { response in
                        if response != nil {
                            do {
                                let imageAttachment = try UNNotificationAttachment(identifier: "picture", url: response!.getPath(), options: nil)
                                bestAttemptContent.attachments = [imageAttachment]
                                contentHandler(bestAttemptContent)
                            } catch {
                                contentHandler(bestAttemptContent)
                                RBLogger.log(message: "unable to handle push notification image")
                            }
                        }
                    }
                } else {
                    contentHandler(bestAttemptContent)
                }
            }
        }
    }

    @objc public func register(userNotificationCenter: UNUserNotificationCenter, uiApplication: UIApplication) {
        userNotificationCenter.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            if error != nil {
                DispatchQueue.main.async {
                    uiApplication.registerForRemoteNotifications()
                }
            }
        }
        uiApplication.applicationIconBadgeNumber = 0
    }

    private func getContentItem(key: String, pushContent: Dictionary<AnyHashable, Any>) -> String? {
        return pushContent[key] as? String
    }
}
