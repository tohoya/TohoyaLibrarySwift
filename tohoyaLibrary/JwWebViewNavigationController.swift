//
//  JwWebViewNavigationController.swift
//  tohoyaLibrary
//
//  Created by Jin Youngho on 2016. 11. 13..
//  Copyright © 2016년 Jin Youngho. All rights reserved.
//

import UIKit

@objc class JwWebViewNavigationController: UIViewController, UIWebViewDelegate , UIAlertViewDelegate/*, MBProgressHUDDelegate*/ {
    
    //    var HUD: MBProgressHUD?
    var lhUtil: JwUtility = JwUtility()
    var backBarButtonItem: UIBarButtonItem?
    var forwardBarButtonItem: UIBarButtonItem?
    var reloadBarButtonItem: UIBarButtonItem?
    var stopBarButtonItem: UIBarButtonItem?
    
    @IBOutlet var webView: UIWebView? = nil
    //var webView: UIWebView? = nil
    var expectedLength: Int64 = 0
    var currentLength: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_list_arrow_prev"), style: UIBarButtonItemStyle.done, target: self, action: #selector(JwWebViewNavigationController.goBackPage(_:)))
        self.forwardBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_list_arrow_next"), style: UIBarButtonItemStyle.done, target: self, action: #selector(JwWebViewNavigationController.goForwardPage(_:)))
        //        self.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Rewind, target: self, action: "goBackPage:")
        //        self.forwardBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FastForward, target: self, action: "goForwardPage:")
        self.reloadBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(JwWebViewNavigationController.reloadPage(_:)))
        self.stopBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(JwWebViewController.stopLoading(_:)))
        
        self.backBarButtonItem?.isEnabled = false
        self.forwardBarButtonItem?.isEnabled = false
        //        self.reloadBarButtonItem?.enabled = false
        //        self.stopBarButtonItem?.enabled = false
        
        self.navigationItem.leftBarButtonItems = [self.backBarButtonItem!, self.forwardBarButtonItem!]
        self.navigationItem.rightBarButtonItems = [self.stopBarButtonItem!]
        self.webView?.delegate = self
        //self.webView?.suppressesIncrementalRendering = true
    }
    
    func goBackPage(_ sender: AnyObject?) {
        if self.webView?.canGoBack == true {
            self.webView?.goBack()
        }
    }
    
    func goForwardPage(_ sender: AnyObject?) {
        if self.webView?.canGoForward == true {
            self.webView?.goForward()
        }
    }
    
    func stopLoading(_ sender: AnyObject?) {
        self.webView?.stopLoading()
        self.loadChangeStop()
    }
    
    func reloadPage(_ sender: AnyObject?) {
        self.webView?.reload()
    }
    
    func loadChangeStop() {
        self.backBarButtonItem?.isEnabled = (self.webView?.canGoBack)!
        self.forwardBarButtonItem?.isEnabled = (self.webView?.canGoForward)!
        self.navigationItem.rightBarButtonItems = [self.reloadBarButtonItem!]
        print("[ JwWebViewController : webViewDidFinishLoad ]")
        //HUD?.hide(true, afterDelay: 0.1)
    }
    
    func loadChangeStart() {
        self.navigationItem.rightBarButtonItems = [self.stopBarButtonItem!]
        print("[ JwWebViewController : webViewDidStartLoad ]")
        /*if HUD != nil {
         HUD?.removeFromSuperview()
         HUD = nil
         }
         HUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
         self.view.addSubview(HUD!)
         HUD?.delegate = self*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.webView?.reload()
    }
    
    func webPageLoaderUrlToString(_ url: String) {
        print("[ JwWebViewController : webPageLoaderUrlToString ( \(url) ) ]")
        self.webView?.stopLoading()
        self.webView?.loadRequest(URLRequest(url: URL(string: url)!))
    }
    
    // MARK : MBProgressHUD
    /*func hudWasHidden(hud: MBProgressHUD) {
     print("[ JwWebViewController : hudWasHidden ]")
     HUD?.removeFromSuperview()
     HUD = nil
     }*/
    
    // MARK : UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("[ JwWebViewController : didFailLoadWithError ]")
        if(error._code != -999) {
            print("Web Error Code : \(error._code)")
            if let viewController = self.view.window!.rootViewController {
                DispatchQueue.main.async(execute: {
                    let alertController: UIAlertController;
                    let message = "네트워크 상태가 원할하지 않아 페이지를 열 수 없습니다."
                    if viewController.presentedViewController?.isKind(of: UIAlertController.self) == true {
                        alertController = viewController.presentedViewController as! UIAlertController
                        alertController.message = message
                    } else {
                        alertController = UIAlertController(title: "Network Error", message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                            //self.badgeReset(0)
                        }))
                        viewController.present(alertController, animated: true, completion: nil)
                    }
                })
            }
        }
        self.loadChangeStop();
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print(self.webView?.suppressesIncrementalRendering as Any);
        self.loadChangeStart();
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.loadChangeStop();
    }
    
    
}
