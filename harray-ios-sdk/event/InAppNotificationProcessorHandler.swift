//
//  InAppNotificationProcessorHandler.swift
//  harray-ios-sdk
//
//  Created by Yildirim Adiguzel on 28.09.2021.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import Foundation
import UIKit

@available(iOSApplicationExtension,unavailable)
@objc public class InAppNotificationProcessorHandler: NSObject, AfterPageViewEventHandler {
    
    private let rbConfig: RBConfig
    private let applicationContextHolder: ApplicationContextHolder
    private let sessionContextHolder: SessionContextHolder
    private let httpService: HttpService
    private let eventProcessorHandler: EventProcessorHandler
    private let jsonDeserializerService: JsonDeserializerService
    private let deviceService: DeviceService
    
    init(applicationContextHolder: ApplicationContextHolder, sessionContextHolder: SessionContextHolder, httpService: HttpService, eventProcessorHandler: EventProcessorHandler, rbConfig: RBConfig,jsonDeserializerService: JsonDeserializerService,deviceService: DeviceService) {
        self.applicationContextHolder = applicationContextHolder
        self.sessionContextHolder = sessionContextHolder
        self.httpService = httpService
        self.eventProcessorHandler = eventProcessorHandler
        self.rbConfig = rbConfig
        self.jsonDeserializerService = jsonDeserializerService
        self.deviceService = deviceService
    }

    
    func showPopup(data: InAppNotificationResponse?){
        if let notificationResponse = data {
            var params = Dictionary<String, String>()
            params["entity"] = "banners"
            params["id"] = notificationResponse.id!
            eventProcessorHandler.impression(pageType: "bannerShow", params: params)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                if let frame = self.topViewController()?.view.frame {
                    
                    let mView = InAppView(frame: frame)
                    
                    let position = notificationResponse.position ?? "center"
                    
                    if ("center" == position) {
                        mView.bounds.origin.y = frame.center.y / 2 * -1
                    } else  if ("top" == position) {
                        mView.bounds.origin.y = frame.top.y / 2 * -1
                    } else  if ("bottom" == position) {
                        mView.bounds.origin.y = frame.bottom.y / 2 * -1
                    }else  if ("full" == position) {
                        mView.bounds.origin.y = frame.top.y / 2 * -1
                        
                    }
                    
                    mView.loadPopup(content: notificationResponse.html!)
                    mView.onNavigation = {
                        navigateTo in
                        params["action"] = "click"
                        self.eventProcessorHandler.actionResult(type: "bannerClick", params: params)
                        self.rbConfig.getInAppNotificationLinkClickHandler()?(navigateTo)
                    }
                    mView.onClose = {
                        closeClicked in
                        if (closeClicked) {
                            params["action"] = "close"
                            self.eventProcessorHandler.actionResult(type: "bannerClose", params: params)
                        }
                    }
                    self.topViewController()?.view.addSubview(mView)
                }
            }
        }
        
    }
    
    
    func callAfter(event: RBEvent) {
        var params = Dictionary<String, String>()
        params["sdkKey"] = rbConfig.getSdkKey()
        params["source"] = "ios"
        params["pid"] = applicationContextHolder.getPersistentId()
        params["deviceLang"] = deviceService.getLanguage()
        let pageType = event.getStringParameterValue(key: "pageType")
        if pageType != nil {
            params["pageType"] = pageType
        }
        let entity = event.getStringParameterValue(key: "entity")
        if entity != nil {
            params["entity"] = pageType
        }
        let entityId = event.getStringParameterValue(key: "entityId")
        if entityId != nil {
            params["entityId"] = pageType
        }
        let collectionId = event.getStringParameterValue(key: "collectionId")
        if collectionId != nil {
            params["collectionId"] = pageType
        }
        if sessionContextHolder.getMemberId() != nil {
            params["memberId"] = sessionContextHolder.getMemberId()
        }
        
        let price = event.getStringParameterValue(key: "price")
        if price != nil {
            params["price"] = price
        }

        let responseHandler: (HttpResult) -> InAppNotificationResponse? = { hr in
            if let body = hr.getBody() {
                return self.jsonDeserializerService.deserialize(jsonString: body)
            } else {
                return nil
            }
        }
        
        let callback: (InAppNotificationResponse?) -> Void = {data in
            self.showPopup(data: data)
        }

        
        httpService.getApiRequest(
                path: "/in-app-notifications",
                params: params,
                responseHandler: responseHandler,
                completionHandler: callback)
        
    }
   
    
    func topViewController() -> UIViewController? {
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            return nil
        }

        var topViewController = rootViewController

        while let newTopViewController = topViewController.presentedViewController {
            topViewController = newTopViewController
        }

        return topViewController
    }
    
    
}


