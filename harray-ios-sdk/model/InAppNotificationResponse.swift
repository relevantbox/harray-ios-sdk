//
//  InAppNotificationResponse.swift
//  harray-ios-sdk
//
//  Created by Yildirim Adiguzel on 28.09.2021.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import Foundation

class InAppNotificationResponse: Decodable{
    let id: String?
    let style: String?
    let html: String?
    let imageUrl: String?
    let position: String?
}

class InAppNotificationEvent: Decodable{
    let eventType: String
    let link: String?
}
