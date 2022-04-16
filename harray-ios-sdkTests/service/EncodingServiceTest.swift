//
//  EncodingServiceTest.swift
//  harray-ios-sdkTests
//
//  Created by YILDIRIM ADIGÜZEL on 21.04.2020.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import XCTest

class EncodingServiceTest: XCTestCase  {
    
    func test_it_should_convert_url_encoded_version_of_given_text(){
        let text =  "http://www.rb.io?foo=bar&a=b+c"
        let encodingService = EncodingService()
        let result = encodingService.getUrlEncodedString(value: text)
        
        XCTAssertEqual("http%3A%2F%2Fwww.rb.io%3Ffoo=bar&a=b+c", result)
    }
    
    func test_it_should_encode_string_to_base_64_string(){
        let value = "plain text value"
        let encodingService = EncodingService()
        let result = encodingService.getBase64EncodedString(value: value)
        XCTAssertEqual("cGxhaW4gdGV4dCB2YWx1ZQ==", result)
    }
    
}
