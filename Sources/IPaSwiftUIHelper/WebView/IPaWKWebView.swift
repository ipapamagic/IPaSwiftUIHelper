//
//  IPaWebView.swift
//  IPaSwiftUIView
//
//  Created by IPa Chen on 2020/10/26.
//

import UIKit
import WebKit
import IPaLog
public class IPaWKWebView: WKWebView {
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    deinit {
        configuration.userContentController.removeScriptMessageHandler(forName: "sizeNotification")
        configuration.userContentController.removeScriptMessageHandler(forName: "windowLoaded")
        
        
//        removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: &observerContext)
    }
    func initialJSScript(_ scriptHandler:WKScriptMessageHandler) {
        let source = "window.onload=function () {window.webkit.messageHandlers.windowLoaded.postMessage({});};"
        
        //UserScript object
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        
        //fit content size script
        let metaSource = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width initial-scale=1'); document.getElementsByTagName('head')[0].appendChild(meta);"
        //Content Controller object
        let controller = self.configuration.userContentController
        
        controller.addUserScript(script)
        
        //Add message handler reference
        controller.add(scriptHandler, name: "windowLoaded")
        
        let metaScript = WKUserScript(source: metaSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        controller.addUserScript(metaScript)
        
        
        let resizeSource = "document.body.addEventListener( 'resize', incrementCounter); function incrementCounter() {window.webkit.messageHandlers.sizeNotification.postMessage({height: document.body.scrollHeight});};"
        
        //UserScript object

        let resizeScript = WKUserScript(source: resizeSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
       
        controller.addUserScript(resizeScript)
        //Add message handler reference
        controller.add(scriptHandler, name: "sizeNotification")
        
    }
    public override func load(_ request: URLRequest) -> WKNavigation? {
        if let method = request.httpMethod, method.lowercased() == "post" {
            post(request)
            return nil
        }
        return super.load(request)
    }
    func post(_ request:URLRequest,encoding: String.Encoding = .utf8) {
        guard let bodyData = request.httpBody,let bodyString = String(data: bodyData, encoding: encoding),let urlString = request.url?.absoluteString else {
            return
        }
        let bodyParams = (bodyString as NSString).components(separatedBy: "&")
        var params = [String]()
        for param in bodyParams {
            let data = (param as NSString).components(separatedBy:"=")
            guard data.count == 2 else {
                continue
            }
            params.append("\"\(data[0])\":\"\(data[1])\"")
        }
        let paramsString = params.joined(separator: ",")
        let postSource = """
        function post(url, params) {
        var method = "post";
        var form = document.createElement("form");
        form.setAttribute("method", method);
        form.setAttribute("action", url);
        
        for(var key in params) {
        if(params.hasOwnProperty(key)) {
        var hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("name", key);
        hiddenField.setAttribute("value", params[key]);
        form.appendChild(hiddenField);
        }
        }
        document.body.appendChild(form);
        form.submit();
        }
        post('\(urlString)',{\(paramsString)});
        """
        self.evaluateJavaScript(postSource) { (result, error) in
            if let error = error {
                IPaLog("IPaWebView - post error: \(error)")
            }
        }
        
    }
}
