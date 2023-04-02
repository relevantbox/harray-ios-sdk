//
//  InAppView.swift
//  harray-ios-sdk
//
//  Created by Yildirim Adiguzel on 22.09.2021.
//  Copyright © 2022 relevantboxio. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class InAppView : UIView {
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var webViewContainerView: UIView!
    private let jsonDeserializerService: JsonDeserializerService = JsonDeserializerService()
    
    
    var onNavigation: ((_ navigateTo: String) -> ())?
    var onClose: ((_ closeClicked: Bool) -> ())?
    
    let kCONTENT_XIB_NAME = "InAppView"
    
    func closingEvent(_ closeClicked: Bool){
        self.removeFromSuperview()
        self.onClose?(closeClicked)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadPopup(content: String) {
        let bundle = Bundle(identifier: "org.cocoapods.RB")
        bundle?.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        containerView.fixInView(self)
     
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController.add(self, name: "RBIos")
        
        let webView = WKWebView(frame: webViewContainerView.frame, configuration: webViewConfiguration)
        webView.fixInView(webViewContainerView)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        
        webViewContainerView.addSubview(webView)
        webView.navigationDelegate = self
        webView.loadHTMLString(content, baseURL: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

extension CGRect {
    var center : CGPoint {
        return CGPoint(x:self.midX, y:self.midY)
    }
    
    var bottom: CGPoint {
        return CGPoint(x:self.maxX, y:self.maxY)
    }
    
    var top: CGPoint {
        return CGPoint(x:self.minX, y:self.minY)
    }
}

extension InAppView: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let response = message.body as? String else {
            self.closingEvent(true)
            return
        }
        let event : InAppNotificationEvent? = jsonDeserializerService.deserialize(jsonString: response)
        
        if (event != nil){
            if ("close" == event?.eventType) {
                self.closingEvent(true)
            }else if ("linkClicked" == event?.eventType) {
                self.onNavigation?(event?.link ?? "")
                self.closingEvent(false)
            }
            else if ("renderCompleted" == event?.eventType) {
               
            }
        }else{
            self.closingEvent(true)
        }
    }
}

extension InAppView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {
        let url = navigationAction.request.url?.absoluteString ?? ""
        if(!url.contains("about:blank")){
                self.onNavigation?(url)
                self.closingEvent(false)
            }
            decisionHandler(.allow)
        }
}

extension UIView {
    func fixInView(_ container: UIView!) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        
        container.addSubview(self)
        
        NSLayoutConstraint(item: self,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: container,
                           attribute: .leading,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: container,
                           attribute: .trailing,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: container,
                           attribute: .top,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: container,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: 0).isActive = true
    }
}
