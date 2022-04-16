//
//  RBConfig.swift
//  harray-ios-sdk
//
//  Created by Bay Batu on 20.04.2021.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import Foundation

@objc public class RBConfig: NSObject {
    
    private let sdkKey: String
    private var apiUrl: String = Constants.RB_API_URL.rawValue
    private var collectorUrl: String = Constants.RB_COLLECTOR_URL.rawValue
    private var inAppNotificationLinkClickHandler: ((_ deepLink: String) -> ())? = nil
    
    private init(sdkKey: String) {
        self.sdkKey = sdkKey
    }
    
    public static func create(sdkKey: String) -> RBConfig {
        return RBConfig(sdkKey: sdkKey)
    }
    
    public func collectorUrl(url: String) -> RBConfig {
        self.collectorUrl = RBConfig.getValidUrl(url: url)
        return self
    }
    
    public func inAppNotificationLinkClickHandler(_ handler: ((_ deepLink: String) -> ())? = nil) -> RBConfig {
        self.inAppNotificationLinkClickHandler = handler
        return self
    }

    public func apiUrl(url: String) -> RBConfig {
        self.apiUrl = RBConfig.getValidUrl(url: url)
        return self
    }

    public func getSdkKey() -> String {
        return self.sdkKey
    }

    public func getCollectorUrl() -> String {
        return self.collectorUrl
    }

    public func getApiUrl() -> String {
        return self.apiUrl
    }
    
    public func getInAppNotificationLinkClickHandler() -> ((_ deepLink: String) -> ())? {
        return self.inAppNotificationLinkClickHandler
    }
    
    private static func getValidUrl(url: String) -> String {
        return UrlUtils.removeTrailingSlash(url: url)
    }
}
