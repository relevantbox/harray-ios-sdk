//
//  UrlUtilsTest.swift
//  harray-ios-sdkTests
//
//  Created by Bay Batu on 21.04.2021.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import Foundation

import XCTest

class UrlUtilsTest: XCTestCase {
    
    func test_it_should_remove_trailing_slash_from_url_if_exists() {
        XCTAssertEqual("http://rb.io", UrlUtils.removeTrailingSlash(url: "http://rb.io/"))
        XCTAssertEqual("http://rb.io", UrlUtils.removeTrailingSlash(url: "http://rb.io"))
    }    
}
