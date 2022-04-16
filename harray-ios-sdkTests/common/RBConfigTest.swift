//
//  RBConfigTest.swift
//  harray-ios-sdkTests
//
//  Created by Bay Batu on 21.04.2021.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import XCTest

class RBConfigTest: XCTestCase {
    
    func test_it_should_create_rb_config() {
        
        let rbConfig = RBConfig.create(sdkKey: "sdkKey")
        
        XCTAssertEqual("sdkKey", rbConfig.getSdkKey())
        XCTAssertEqual("https://c.relevantbox.io", rbConfig.getCollectorUrl())
        XCTAssertEqual("https://api.relevantbox.io", rbConfig.getApiUrl())
    }
    
    func test_it_should_create_rb_config_with_custom_api_url_and_collector_url() {
        
        let rbConfig = RBConfig
            .create(sdkKey: "sdkKey")
            .collectorUrl(url: "https://collector.rb.io/")
            .apiUrl(url: "https://myapi.rb.io/")
        
        XCTAssertEqual("sdkKey", rbConfig.getSdkKey())
        XCTAssertEqual("https://collector.rb.io", rbConfig.getCollectorUrl())
        XCTAssertEqual("https://myapi.rb.io", rbConfig.getApiUrl())
    }
}
