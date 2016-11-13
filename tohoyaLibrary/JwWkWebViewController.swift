//
//  JwWkWebViewController.swift
//  tohoyaLibrary
//
//  Created by Jin Youngho on 2016. 11. 13..
//  Copyright © 2016년 Jin Youngho. All rights reserved.
//

import WebKit

@objc class JwWkWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, MBProgressHUDDelegate {
    
    var HUD: MBProgressHUD?
    var lhUtil: LHUtility = LHUtility()
    var load_url: String? = ""
    var reachability: Reachability?
    var isNetwork: Bool = true
    
    
    @IBOutlet var backBarButtonItem: UIBarButtonItem?
    @IBOutlet var forwardBarButtonItem: UIBarButtonItem?
    @IBOutlet var reloadBarButtonItem: UIBarButtonItem?
    @IBOutlet var stopBarButtonItem: UIBarButtonItem?
    @IBOutlet var toolBar: UIToolbar? = nil
    
    var webView: WKWebView? = nil
    var progressView: UIProgressView?
    
    var expectedLength: Int64 = 0
    var currentLength: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backBarButtonItem?.isEnabled = false
        self.forwardBarButtonItem?.isEnabled = false
        self.reloadBarButtonItem?.isEnabled = false
        self.stopBarButtonItem?.isEnabled = false
        
        do {
            self.reachability = try Reachability.reachabilityForInternetConnection()
            
            self.reachability!.whenUnreachable = { reachability in
                // this is called on a background thread, but UI updates must
                // be on the main thread, like this:
                DispatchQueue.main.async {
                    self.networkError({})
                    print("Not reachable")
                    self.loadChangeStop()
                    self.isNetwork = false
                }
            }
            self.reachability!.whenReachable = { reachability in
                // this is called on a background thread, but UI updates must
                // be on the main thread, like this:
                DispatchQueue.main.async {
                    self.loadChangeStop()
                    if self.isNetwork == false {
                        if reachability.isReachableViaWiFi() {
                            print("Reachable via WiFi")
                        } else {
                            print("Reachable via Cellular")
                        }
                        self.isNetwork = true
                        self.urlWebLoader(self.load_url!)
                    }
                }
            }
            
            do {
                try self.reachability!.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
        } catch {
            print("Unable to create Reachability")
        }
        
        
        self.webViewInit()
    }
    
    func addWebView() {
        print("111111")
        self.view.addSubview(self.webView!)
    }
    
    func webViewInit() {
        let frame: CGRect = self.view.bounds;
        
        let preferences:WKPreferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false
        preferences.javaScriptEnabled = true
        
        let configuration:WKWebViewConfiguration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true;
        configuration.preferences = preferences
        
        self.webView = WKWebView(frame: frame, configuration: configuration)
        self.webView?.autoresizingMask = [.flexibleTopMargin, .flexibleWidth, .flexibleHeight]
        self.webView?.navigationDelegate = self
        self.webView?.uiDelegate = self
        self.webView?.allowsBackForwardNavigationGestures = true
        
        self.addWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goBackPage(_ sender: AnyObject?) {
        if self.webView?.canGoBack == true {
            // self.webView?.goBack()
            _ = webView?.goBack()
        }
    }
    @IBAction func goForwardPage(_ sender: AnyObject?) {
        if self.webView?.canGoForward == true {
            // self.webView?.goForward() 2.2
            _ = webView?.goForward()
        }
    }
    @IBAction func stopLoading(_ sender: AnyObject?) {
        // self.webView?.stopLoading() 2.2
        _ = webView?.stopLoading()
        self.loadChangeStop()
    }
    @IBAction func reloadPage(_ sender: AnyObject?) {
        //self.webView?.reload() 2.2
        _ = webView?.reload()
    }
    
    func networkError(_ complete: @escaping (() -> Void)) {
        let alertController = UIAlertController(title: "경고", message: "인터넷이 연결되어 있지 않습니다.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            complete()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setTitleView(_ title: String) {
        if title.isEmpty {
            return
        }
        
        let fadeTextAnimation: CATransition = CATransition();
        fadeTextAnimation.duration = 0.1;
        fadeTextAnimation.type = kCATransitionFade;
        
        self.navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
        self.navigationItem.title = title
    }
    
    func loadChangeStop() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.backBarButtonItem?.isEnabled = (self.webView?.canGoBack)!
        self.forwardBarButtonItem?.isEnabled = (self.webView?.canGoForward)!
        self.reloadBarButtonItem?.isEnabled = true
        self.stopBarButtonItem?.isEnabled = false
        
        if HUD != nil {
            HUD?.hide(true, afterDelay: 0.1)
        }
    }
    
    func loadChangeStart() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.reloadBarButtonItem?.isEnabled = false
        self.stopBarButtonItem?.isEnabled = true
        if HUD != nil {
            HUD?.removeFromSuperview()
            HUD = nil
        }
        HUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.view.addSubview(HUD!)
        HUD?.delegate = self
    }
    
    func urlWebLoader(_ url: String) {
        print("urlWebLoader : url(\(url))")
        if let nsurl: URL = URL(string: url) {
            if self.HUD != nil {
                self.HUD?.removeFromSuperview()
                self.HUD = nil
            }
            
            let request: NSMutableURLRequest = NSMutableURLRequest(url: nsurl)
            //self.webView?.load(request as URLRequest)
            _ = webView?.load(request as URLRequest)
        }
    }
    
    func webPageLoaderUrlToString(_ url: String = "") {
        print("webPageLoaderUrlToString : url(\(url))")
        if url != "" {
            self.load_url = url
        }
        if self.isNetwork == true {
            self.urlWebLoader(self.load_url!)
            return
        }
        
        self.networkError({})
    }
    
    // MARK : MBProgressHUD
    func hudWasHidden(_ hud: MBProgressHUD) {
        if HUD != nil {
            HUD?.removeFromSuperview()
            HUD = nil
        }
    }
    
    // MARK: - WKNavigationDelegate methods
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return nil
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        //print("webView:\(webView) didCommitNavigation:\(navigation)")
        self.loadChangeStart();
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation) {
        ///print("webView:\(webView) didCommitNavigation:\(navigation)")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        ///print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(decisionHandler)")
        
        //let url = navigationAction.request.URL
        
        switch navigationAction.navigationType {
        case .linkActivated:
            if navigationAction.targetFrame == nil {
                // self.webView?.load(navigationAction.request) 2.2
                webView.load(navigationAction.request)
            }
        default:
            break
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: (@escaping (WKNavigationResponsePolicy) -> Void)) {
        //print("webView:\(webView) decidePolicyForNavigationResponse:\(navigationResponse) decisionHandler:\(decisionHandler)")
        if let httpResponse = navigationResponse.response as? HTTPURLResponse {
            if let headers = httpResponse.allHeaderFields as? [String: String], let url = httpResponse.url {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
                
                HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
                for cookie in cookies {
                    //var cookieProperties = [String: AnyObject]()
                    var cookieProperties = Dictionary<HTTPCookiePropertyKey, Any>()
                    cookieProperties[HTTPCookiePropertyKey.name] = cookie.name
                    cookieProperties[HTTPCookiePropertyKey.value] = cookie.value
                    cookieProperties[HTTPCookiePropertyKey.domain] = cookie.domain
                    cookieProperties[HTTPCookiePropertyKey.path] = cookie.path
                    cookieProperties[HTTPCookiePropertyKey.version] = NSNumber(value: cookie.version as Int)
                    cookieProperties[HTTPCookiePropertyKey.expires] = Date().addingTimeInterval(31536000)
                    
                    let newCookie = HTTPCookie(properties: cookieProperties)
                    HTTPCookieStorage.shared.setCookie(newCookie!)
                    
                    //print("name: \(cookie.name) value: \(cookie.value)")
                }
                
                //                for cookie in cookies {
                //                    print(cookie.description)
                //                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
                //
                //                    print("found cookie " + cookie.name + " " + cookie.value)
                //                }
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        ///print("webView:\(webView) didReceiveAuthenticationChallenge:\(challenge) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: "Authentication Required", message: webView.url?.host, preferredStyle: .alert)
        weak var usernameTextField: UITextField!
        alertController.addTextField { textField in
            textField.placeholder = "Username"
            usernameTextField = textField
        }
        weak var passwordTextField: UITextField!
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            passwordTextField = textField
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completionHandler(.cancelAuthenticationChallenge, nil)
        }))
        alertController.addAction(UIAlertAction(title: "Log In", style: .default, handler: { action in
            let credential = URLCredential(user: usernameTextField.text!, password: passwordTextField.text!, persistence: URLCredential.Persistence.forSession)
            completionHandler(.useCredential, credential)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation) {
        //print("webView:\(webView) didReceiveServerRedirectForProvisionalNavigation:\(navigation)")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        ///print("webView:\(webView) didFinishNavigation:\(navigation)")
        webView.evaluateJavaScript("document.getElementById('japp-title').innerHTML") { (result, error) -> Void in
            if error != nil {
                //print("\n####### WEB TITLE(ERROR) : \(error) ######\n")
            } else {
                self.setTitleView(result as! String);
            }
        }
        self.loadChangeStop();
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        //print("webView:\(webView) didFailNavigation:\(navigation) withError:\(error)")
        //        let alertController = UIAlertController(title: "안내", message: "네트워크가 원할하지 않습니다.", preferredStyle: .Alert)
        //        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
        //        }))
        //        self.presentViewController(alertController, animated: true, completion: nil)
        self.loadChangeStop();
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        //print("webView:\(webView) didFailProvisionalNavigation:\(navigation) withError:\(error)")
        //        let alertController = UIAlertController(title: "안내 메세지", message: "네트워크가 원할하지 않습니다.", preferredStyle: .ActionSheet)
        //        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
        //        }))
        //        self.presentViewController(alertController, animated: true, completion: nil)
        if error._code <= -1001 {
            self.loadChangeStop();
        }
    }
    // MARK: WKUIDelegate methods
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (@escaping () -> Void)) {
        ///print("webView:\(webView) runJavaScriptAlertPanelWithMessage:\(message) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: "경고", message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completionHandler()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (@escaping (Bool) -> Void)) {
        ///print("webView:\(webView) runJavaScriptConfirmPanelWithMessage:\(message) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: "확인", message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completionHandler(false)
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completionHandler(true)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        ///print("webView:\(webView) runJavaScriptTextInputPanelWithPrompt:\(prompt) defaultText:\(defaultText) initiatedByFrame:\(frame) completionHandler:\(completionHandler)")
        
        let alertController = UIAlertController(title: frame.request.url?.host, message: prompt, preferredStyle: .actionSheet)
        weak var alertTextField: UITextField!
        alertController.addTextField { textField in
            textField.text = defaultText
            alertTextField = textField
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completionHandler(nil)
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completionHandler(alertTextField.text)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}
