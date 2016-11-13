//
//  JwConnectionSessionJson.swift
//  tohoyaLibrary
//
//  Created by Jin Youngho on 2016. 11. 13..
//  Copyright © 2016년 Jin Youngho. All rights reserved.
//

import UIKit

@objc protocol JwConnectionSessionJsonDelegate {
    @objc optional func returnGetJson(_ json: NSMutableDictionary?)
    @objc optional func returnNetworkError()
}

@objc class JwConnectionSessionJson: NSObject, MBProgressHUDDelegate {
    
    var lhUtil: LHUtility? = LHUtility()
    var delegate: JwConnectionSessionJsonDelegate? = nil
    var load_url: String = ""
    var reachability: Reachability?
    var isNetwork: Bool = false
    
    var HUD: MBProgressHUD?
    var expectedLength: Int64 = 0
    var currentLength: Int64 = 0
    var printDebug: Bool = false
    
    func initWithNetwork(_ initComplete: @escaping ((Bool) -> Void)) {
        
        print("JwConnectionSessionJson INIT")
        
        do {
            self.reachability = try Reachability.reachabilityForInternetConnection()
            
            self.reachability!.whenUnreachable = { reachability in
                // this is called on a background thread, but UI updates must
                // be on the main thread, like this:
                DispatchQueue.main.async {
                    print("Not reachable")
                    self.isNetwork = false
                    initComplete(self.isNetwork)
                    self.reachability = nil
                }
            }
            self.reachability!.whenReachable = { reachability in
                // this is called on a background thread, but UI updates must
                // be on the main thread, like this:
                DispatchQueue.main.async {
                    if reachability.isReachableViaWiFi() {
                        print("Reachable via WiFi")
                    } else {
                        print("Reachable via Cellular")
                    }
                    self.isNetwork = true
                    initComplete(self.isNetwork)
                    self.reachability = nil
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
    }
    
    func networkError(_ complete: (() -> Void)) {
        OperationQueue.main.addOperation {
            if self.HUD != nil {
                self.HUD?.hide(true, afterDelay: 0)
            }
            self.delegate?.returnNetworkError!()
        }
    }
    
    // MARK : LHJsonConnection
    
    func urlConnection(_ url: String = "", complete: @escaping ((NSMutableDictionary, String, Bool) -> Void)) {
        if url != "" {
            self.load_url = url
        }
        if self.isNetwork == true {
            if let nsurl = URL(string: self.load_url) {
                let request = NSMutableURLRequest(url: nsurl)
                let configuration = URLSessionConfiguration.default
                configuration.httpCookieStorage = HTTPCookieStorage.shared
                
                let session = URLSession(configuration: configuration)
                
                let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                    if self.HUD != nil {
                        self.HUD?.hide(true, afterDelay: 0.2)
                    }
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    do {
                        if data == nil {
                            complete(NSMutableDictionary(), self.load_url, self.isNetwork)
                            return
                        }
                        if let result_data:Data = data! as Data {
                            var json = try JSONSerialization.jsonObject(with: result_data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSMutableDictionary
                            if json == nil {
                                json = NSMutableDictionary()
                            }
                            complete(json!, self.load_url, self.isNetwork)
                        } else {
                            complete(NSMutableDictionary(), self.load_url, self.isNetwork)
                        }
                    } catch {
                        complete(NSMutableDictionary(), self.load_url, self.isNetwork)
                    }
                })
                
                task.resume()
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
    }
    
    func connectionSetUrl(_ url: String) {
        self.urlConnection(url, complete: { json, url, network in
            OperationQueue.main.addOperation {
                self.delegate?.returnGetJson!(json)
            }
        })
    }
    
    func connectionSetUrl(_ url: String, complete: @escaping ((NSMutableDictionary, String, Bool) -> Void)) {
        self.urlConnection(url, complete: { json, url, network in
            OperationQueue.main.addOperation {
                complete(json, url, network)
            }
        })
    }
    
    
    func connectionSetUrl(_ url: String, view: UIView) {
        if self.HUD != nil {
            self.HUD = nil
        }
        
        if isEqual(view) {
            self.HUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
            self.HUD?.delegate = self;
        }
        
        self.urlConnection(url, complete: { json, url, network in
            OperationQueue.main.addOperation {
                self.delegate?.returnGetJson!(json)
            }
        })
    }
    
    // MARK : MBProgressHUDDelegate
    
    func hudWasHidden(_ hud: MBProgressHUD) {
        if self.HUD != nil {
            self.HUD?.removeFromSuperview()
            self.HUD = nil
        }
    }
}
