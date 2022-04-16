//
//  Stubbings.swift
//  harray-ios-sdkTests
//
//  Created by YILDIRIM ADIGÜZEL on 22.04.2020.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import Foundation
import UIKit


enum TestError: Error {
    case suiteConfigError(message: String)
}

class TestUtils {
    class func anyDictionary() -> Dictionary<String, Any> {
        return Dictionary<String, Any>()
    }
}

class FakeDeviceService: DeviceService {

    init() {
        super.init(bundle: Bundle.main, uiDevice: UIDevice.current, uiScreen: UIScreen.main, locale: Locale.current)
    }

    override func getModel() -> String {
        return "model"
    }

    override func getManufacturer() -> String {
        return "Apple"
    }

    override func getOsVersion() -> String {
        return "uiDevice.systemVersion"
    }

    override func getAppVersion() -> String {
        return "CFBundleShortVersionString"
    }

    override func getCarrier() -> String {
        return "AT"
    }

    override func getBrand() -> String {
        return "Apple"
    }

    override func getScreenWidth() -> CGFloat {
        return CGFloat(100)
    }

    override func getScreenHeight() -> CGFloat {
        return CGFloat(250)
    }

    override func getAppName() -> String {
        return "Apple"
    }

    override func getDeviceModel() -> String {
        return "Iphone 8"
    }
    
    override func getLanguage() -> String {
        return "en"
    }
}

class FakeUrlSession: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    var data: Data?
    var error: Error?

    override func dataTask(
            with url: URL,
            completionHandler: @escaping CompletionHandler
    ) -> URLSessionDataTask {
        let data = self.data
        let error = self.error

        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }
}

class MockUrlSession: HttpSession {

    var httpResult: HttpResult?
    var httpDownloadableResult: HttpDownloadableResult?

    init(httpResult: HttpResult) {
        self.httpResult = httpResult
    }

    init(httpDownloadableResult: HttpDownloadableResult) {
        self.httpDownloadableResult = httpDownloadableResult
    }

    func doRequest(from urlRequest: URLRequest, completionHandler: @escaping (HttpResult) -> Void) {
        completionHandler(httpResult!)
    }

    func downloadTask(with endpoint: String?, completionHandler: @escaping (HttpDownloadableResult?) -> Void) {
        completionHandler(httpDownloadableResult)
    }
}

class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    // We override the 'resume' method and simply call our closure
    // instead of actually resuming any task.
    override func resume() {
        closure()
    }
}

class FakeHttpService: HttpService {

    var expectedPayload: String!
    var payloadCallWith: String = ""
    var hasError: Bool = false
    var path: String?
    var params: Dictionary<String, String>?
    var httpResult: HttpResult?

    override func postFormUrlEncoded(payload: String!) {
        if payloadCallWith != payload {
            self.hasError = true
        }
    }

    override func postJsonEncoded(payload: String?, path: String) {
        if payloadCallWith != payload {
            self.hasError = true
        }
    }
    
    override func getApiRequest<T>(path: String, params: Dictionary<String, String>, responseHandler: @escaping (HttpResult) -> T?, completionHandler: @escaping (T?) -> Void) {
        if (self.path == path && self.params == params) {
            completionHandler(responseHandler(self.httpResult!))
        }
    }

    func givenPostWithPayload(callWith: String) {
        self.payloadCallWith = callWith
    }
    
    func givenGetApiRequest(path: String, params: Dictionary<String, String>, httpResult: HttpResult) -> Void {
        self.path = path
        self.params = params
        self.httpResult = httpResult
    }
}

class CapturingEntitySerializerService: EntitySerializerService {

    private var expected: String?
    private var captured: Dictionary<String, Any> = Dictionary<String, Any>()

    init() {
        super.init(encodingService: FakeEncodingService(), jsonSerializerService: FakeJsonSerializerService())
    }

    override func serializeToBase64(event: Dictionary<String, Any>) -> String? {
        self.captured = event
        return expected
    }

    override func serializeToJson(event: Dictionary<String, Any>) -> String? {
        self.captured = event
        return expected
    }

    func givenSerializeReturns(callWith: Dictionary<String, Any>, expect: String?) {
        self.expected = expect
    }

    func getCapturedEvent() -> Dictionary<String, Any> {
        return captured
    }

}


class FakeJsonSerializerService: JsonSerializerService {

    var expectedJsonSerializedValue: String? = "fake-json-serialized-value"
    var dictionaryCallWith: Dictionary<String, Any>?

    override func serialize(value: Dictionary<String, Any>) -> String? {
        if dictionaryCallWith == nil {
            return "dictionary was not expected during suite setup"
        }
        return expectedJsonSerializedValue
    }

    func givenSerializeReturns(callWith: Dictionary<String, Any>, expect: String?) {
        self.dictionaryCallWith = callWith
        self.expectedJsonSerializedValue = expect
    }
}

class FakeJsonDeserializerService: JsonDeserializerService {
    
    var expectedValue: Any?
    var callWith: String?
    
    override func deserializeToDictArray(jsonString: String) -> Array<Dictionary<String, String>>? {
        if self.callWith! != jsonString {
            return nil
        }
        return expectedValue as! Array<Dictionary<String, String>>?
    }
    
    func givenDeserializeReturnsToDictArray(callWith: String, expect: Array<Dictionary<String, String>>?) {
        self.callWith = callWith
        self.expectedValue = expect
    }
}

class FakeEncodingService: EncodingService {

    var expectedUrlEncodedValue: String? = "fake-encoded-value"
    var expectedBase64EncodedValue = "fake-base64-value"
    var base64CallWith: String?
    var urlEncodeCallWith: String?

    override func getUrlEncodedString(value: String) -> String? {
        if urlEncodeCallWith != value {
            return value + " was not expected during suite setup"
        }
        return expectedUrlEncodedValue
    }

    override func getBase64EncodedString(value: String) -> String {
        if base64CallWith != value {
            return value + " was not expected during suite setup"
        }
        return expectedBase64EncodedValue
    }

    func givenBase64EncodedStringReturns(callWith: String, expect: String) {
        self.base64CallWith = callWith
        self.expectedBase64EncodedValue = expect
    }

    func givenUrlEncodedStringReturns(callWith: String, expect: String?) {
        self.urlEncodeCallWith = callWith
        self.expectedUrlEncodedValue = expect
    }
}

class FakeApplicationContextHolder: ApplicationContextHolder {

    override func getPersistentId() -> String {
        return "fake-persistent-id"
    }

    override func getTimezone() -> String {
        return "2"
    }
}

class FakeSessionContextHolder: SessionContextHolder {

    private var lastActivityTime: Int64?
    private var memberId: String? = "fake-member-id"

    func withLastActivityTime(_ expectedTime: Int64) -> FakeSessionContextHolder {
        lastActivityTime = expectedTime
        return self
    }

    override func getSessionIdAndExtendSession() -> String {
        return "fake-session-id"
    }

    override func getMemberId() -> String? {
        return memberId
    }

    func setMemberId(memberId: String?) -> Void {
        self.memberId = memberId
    }
    
    func withExtraParameters(_ params: Dictionary<String, Any>) -> FakeSessionContextHolder {
        super.updateExternalParameters(data: params)
        return self
    }

    override func getLastActivityTime() -> Int64 {
        return lastActivityTime!
    }
}

class NotInitializedUserDefaults: UserDefaults {

    var keyValue: String?
    var value: Any?

    override func string(forKey defaultName: String) -> String? {
        return nil
    }

    override func set(_ value: Any?, forKey defaultName: String) {
        self.keyValue = defaultName
        self.value = value
    }

}

class InitializedUserDefaults: UserDefaults {

    var value: Any?

    override func string(forKey defaultName: String) -> String? {
        return "stored-persistent-id"
    }
}

class CapturingEventProcessorHandler: EventProcessorHandler {

    var pageType: String?
    var actionType: String?
    var capturedParams: [Dictionary<String, Any>] = [Dictionary<String, Any>]()
    var actionResultInvokeCount: Int = 0
    var pageViewInvokeCount: Int = 0
    let chainProcessorHandler = ChainProcessorHandler()
    init(){
        super.init(applicationContextHolder: FakeApplicationContextHolder(userDefaults: NotInitializedUserDefaults()),
                   sessionContextHolder: FakeSessionContextHolder(), httpService: FakeHttpService(sdkKey: "", session: FakeUrlSession(), collectorUrl: "", apiUrl: ""),
                entitySerializerService: CapturingEntitySerializerService()
        ,chainProcessorHandler: chainProcessorHandler)
    }

    override func pageView(pageType: String, params: Dictionary<String, Any>) {
        self.pageType = pageType
        self.capturedParams.append(params)
        self.pageViewInvokeCount = self.pageViewInvokeCount + 1
    }

    override func actionResult(type: String, params: Dictionary<String, Any>) {
        self.actionType = type
        self.capturedParams.append(params)
        self.actionResultInvokeCount = self.actionResultInvokeCount + 1
    }
}
