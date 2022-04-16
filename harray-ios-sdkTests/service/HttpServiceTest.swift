//
// Created by YILDIRIM ADIGÜZEL on 25.04.2020.
// Copyright (c) 2022 relevantboxio. All rights reserved.
//

import XCTest

class HttpServiceTest: XCTestCase {

    func test_it_should_get_from_api() {
        let fakeUrlSession = MockUrlSession(httpResult: HttpResult(statusCode: 200, hasError: false, body: "get-result"))
        let httpService = HttpService(
            sdkKey: "sdk-key",
            session: fakeUrlSession,
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )
        
        var httpResult: HttpResult?
        var responseBody: String?
        
        httpService.getApiRequest(
            path: "/path",
            params: ["param1": "value1", "param2": "value2"],
            responseHandler: { (hr) in
                httpResult = hr
                return hr.getBody()
            },
            completionHandler: { (data) in
                responseBody = data
            })
        XCTAssertEqual(200, httpResult!.getStatusCode())
        XCTAssertEqual("get-result", responseBody)
    }
    
    func test_it_should_not_process_get_result_if_http_status_is_not_success() {
        let fakeUrlSession = MockUrlSession(httpResult: HttpResult(statusCode: 500, hasError: true, body: nil))
        let httpService = HttpService(
            sdkKey: "sdk-key",
            session: fakeUrlSession,
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )
        
        httpService.getApiRequest(
            path: "/path",
            params: ["param1": "value1", "param2": "value2"],
            responseHandler: { (hr) in
                XCTAssertTrue(false)
        },
            completionHandler: { (data) in
                XCTAssertTrue(false)
        })
    }
    
    func test_it_should_post_to_end_point_with_add_post_parameters() {
        let fakeUrlSession = MockUrlSession(httpResult: HttpResult(statusCode: 201, hasError: false, body: nil))
        let httpService = HttpService(
            sdkKey: "sdk-key",
            session: fakeUrlSession,
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )

        var result: HttpResult?
        httpService.postFormUrlEncoded(payload: "payload") {
            result = $0
        }
        XCTAssertEqual(201, result!.getStatusCode())
        XCTAssertTrue(result!.isSuccess())
    }

    func test_it_should_post_to_end_point_with_json_parameters() {
        let fakeUrlSession = MockUrlSession(httpResult: HttpResult(statusCode: 201, hasError: false, body: nil))
        let httpService = HttpService(
            sdkKey: "sdk-key",
            session: fakeUrlSession,
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )

        var result: HttpResult?
        httpService.postJsonEncoded(payload: "payload", path: "feedback") {
            result = $0
        }
        XCTAssertEqual(201, result!.getStatusCode())
        XCTAssertTrue(result!.isSuccess())
    }

    func test_it_should_respond_with_client_error_when_payload_is_nill() {
        let fakeUrlSession = MockUrlSession(httpResult: HttpResult.clientError())
        let httpService = HttpService(
            sdkKey: "sdk-key",
            session: fakeUrlSession,
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )

        var result: HttpResult?
        httpService.postFormUrlEncoded(payload: nil) {
            result = $0
        }
        XCTAssertEqual(0, result!.getStatusCode())
        XCTAssertFalse(result!.isSuccess())
    }

    func test_it_should_call_completion_handler_with_nil_when_endpoint_is_nil() {
        let fakeUrlSession = MockUrlSession(httpResult: HttpResult.clientError())
        let httpService = HttpService(
            sdkKey: "sdk-key",
            session: fakeUrlSession,
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )
        var result: HttpDownloadableResult?
        httpService.downloadContent(endpoint: nil) {
            result = $0
        }
        XCTAssertNil(result)
    }

    func test_it_should_call_completion_handler_with_http_downloadable_result_when_response_is_valid() {
        let fakeUrlSession = MockUrlSession(httpDownloadableResult: HttpDownloadableResult(path: URL(string: "http://www.rb.io")!))
        let httpService = HttpService(
            sdkKey: "sdk-key",
            session: fakeUrlSession,
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )
        var result: HttpDownloadableResult?
        httpService.downloadContent(endpoint: "https://c.rb.io/img.gif") {
            result = $0
        }
        XCTAssertEqual(URL(string: "http://www.rb.io")!, result?.getPath())
    }

    func test_it_should_add_sdk_key_to_collector_url() {
        let fakeUrlSession = MockUrlSession(httpDownloadableResult: HttpDownloadableResult(path: URL(string: "http://www.rb.io")!))
        let httpService = HttpService(
            sdkKey: "sdk-key",
            session: fakeUrlSession,
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )
        XCTAssertEqual("https://c.rb.io/sdk-key", httpService.getCollectorUrl())
    }

    func test_it_should_add_path_to_collector_url() {
        let fakeUrlSession = MockUrlSession(httpDownloadableResult: HttpDownloadableResult(path: URL(string: "http://www.rb.io")!))
        let httpService = HttpService(
            sdkKey: "sdk-key",
            session: fakeUrlSession,
            collectorUrl: "https://c.rb.io",
            apiUrl: "https://api.rb.io"
        )
        XCTAssertEqual("https://c.rb.io/path", httpService.getCollectorUrl(path: "path"))
    }

}
