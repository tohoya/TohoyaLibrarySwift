//
//  JwConnectionJson.swift
//  tohoyaLibrary
//
//  Created by Jin Youngho on 2016. 11. 13..
//  Copyright © 2016년 Jin Youngho. All rights reserved.
//

import UIKit

@objc protocol JwConnectionJsonDelegate {
    @objc optional func returnGetJson(_ json: NSMutableDictionary?)
    @objc optional func connection(_ connection: NSURLConnection, didReceiveResponse response: URLResponse)
    @objc optional func connection(_ connection: NSURLConnection, didFailWithError error: NSError)
    @objc optional func connection(_ connection: NSURLConnection, didReceiveData data: Data)
    @objc optional func connectionDidFinishLoading(_ connection: NSURLConnection)
}

@objc class JwConnectionJson: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate, MBProgressHUDDelegate {
    
    var lhUtil: JwUtility? = JwUtility()
    var delegate: JwConnectionJsonDelegate? = nil
    var connection: NSURLConnection? = nil
    var loadData: NSMutableData? = nil
    var jsonData: NSMutableDictionary? = nil
    
    var HUD: MBProgressHUD?
    var expectedLength: Int64 = 0
    var currentLength: Int64 = 0
    var printDebug: Bool = false
    
    
    // MARK : JwConnectionJson
    
    func connectionSetUrl(_ url: String) {
        if self.printDebug {
            print("[ JwConnectionJson : connectionSetUrl(\(url)) ]");
        }
        let request: URLRequest = URLRequest(url: URL(string: url)!)
        
        if self.loadData != nil {
            self.loadData = nil
        }
        
        self.connection = NSURLConnection(request: request, delegate: self)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func connectionSetUrl(_ url: String, view: UIView) {
        if self.printDebug {
            print("[ JwConnectionJson : connectionSetUrl(url: String, view: UIView) ]");
        }
        //        let URL: NSURL? = NSURL(string: url)
        //        let request: NSURLRequest = NSURLRequest(URL: URL!)
        //
        //        if self.loadData != nil {
        //            self.loadData = nil
        //        }
        //
        //        self.connection = NSURLConnection(request: request, delegate: self)
        //
        //        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.connectionSetUrl(url)
        
        if self.HUD != nil {
            self.HUD = nil
        }
        
        if isEqual(view) {
            HUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
            HUD?.delegate = self;
        }
    }
    
    
    
    // MARK : NSURLConnectionDelegate
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        if self.printDebug {
            print("[ JwConnectionJson : connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) ]");
        }
        
        if (delegate?.connection?(connection, didReceiveResponse: response) == nil) {
            
        }
        
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        if self.printDebug {
            print("[ JwConnectionJson : connection(connection: NSURLConnection, didFailWithError error: NSError) ]");
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if HUD != nil {
            HUD?.hide(true, afterDelay: 0.2)
        }
        
        if (delegate?.connection?(connection, didFailWithError: error as NSError) == nil) {
            let alertView: UIAlertView = UIAlertView(title: "ConnectionError", message: "접속에 실패하였습니다.", delegate: self, cancelButtonTitle: "확인")
            alertView.show()
        }
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        if self.printDebug {
            print("[ JwConnectionJson : connection(connection: NSURLConnection, didReceiveData data: NSData) ]");
        }
        
        if (delegate?.connection?(connection, didReceiveData: data) == nil) {
            if self.loadData == nil {
                self.loadData = NSMutableData(capacity: 2048)
            }
            self.loadData?.append(data)
            
            if HUD != nil {
                //                currentLength += data.length
                //                HUD?.progress = (currentLength / expectedLength) as Float
            }
        }
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        if self.printDebug {
            print("[ JwConnectionJson : connectionDidFinishLoading(connection: NSURLConnection) ]");
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if HUD != nil {
            HUD?.hide(true, afterDelay: 0.2)
        }
        if delegate?.connectionDidFinishLoading?(connection) == nil {
            do {
                self.jsonData = try JSONSerialization.jsonObject(with: self.loadData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSMutableDictionary
                if self.jsonData == nil {
                    self.jsonData = NSMutableDictionary()
                }
                if self.printDebug {
                    print("[ JwConnectionJson : Data : \(self.jsonData!) ]")
                }
                delegate?.returnGetJson?(self.jsonData!)
            } catch {
                print("")
            }
        }
    }
    
    // MARK : MBProgressHUDDelegate
    
    func hudWasHidden(_ hud: MBProgressHUD) {
        if HUD != nil {
            HUD?.removeFromSuperview()
            HUD = nil
        }
    }
}
