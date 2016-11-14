//
//  JwUtility.swift
//  tohoyaLibrary
//
//  Created by Jin Youngho on 2016. 11. 13..
//  Copyright © 2016년 Jin Youngho. All rights reserved.
//

import UIKit
import CoreData
import CommonCrypto

extension UIColor {
    convenience init(hex:String) {
        let hexStr:NSString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        let scan = Scanner(string: hexStr as String)
        
        if (hexStr.hasPrefix("#")) {
            scan.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scan.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexStr() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
}

extension String {
    func MD5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deinitialize()
        
        return String(format: hash as String)
        //        let data = (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        //        let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))
        //        let resultBytes = UnsafeMutablePointer<CUnsignedChar>(result!.mutableBytes)
        //        CC_MD5(data!.bytes, CC_LONG(data!.length), resultBytes)
        //
        //        let a = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: result!.length)
        //        let hash:NSMutableString = NSMutableString()
        //
        //        for i in a {
        //            hash.appendFormat("%02x", i)
        //        }
        //
        //        return hash as String
    }
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)
    }
}

extension Dictionary {
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map() { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}

extension UILabel {
    func sizeWithFont(_ text:String?, font:UIFont, width:CGFloat) -> CGSize {
        let lhutil:JwUtility = JwUtility()
        return lhutil.sizeWithFont(text, font: font, width: width)
    }
}

extension Date {
    func stringDateTime(_ format: String = "yyyy-MM-dd HH:mm:ss") ->String {
        
        let dateFormetter: DateFormatter = DateFormatter()
        dateFormetter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dataString:String = dateFormetter.string(from: self)
        dateFormetter.timeZone = TimeZone(identifier: "GMT")
        let date:Date = dateFormetter.date(from: dataString)!
        dateFormetter.dateFormat = format
        return dateFormetter.string(from: date)
    }
}


@objc class JwUtility: NSObject, NSFetchedResultsControllerDelegate {
    
    func md5(_ string: String) ->String {
        return string.MD5()
    }
    
    func sizeWithFont(_ text:String?, font:UIFont, width:CGFloat) -> CGSize {
        if text == nil {
            return CGSize(width: width, height: 0.0)
        }
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        
        let outSize: CGSize = label.frame.size
        
        return outSize
    }
    
    // MARK : CoreData - NSFetchedResultsControllerDelegate
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "kr.co.intcompany.SplitMaster_swift" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    func JSONStringify(_ value: AnyObject,prettyPrinted:Bool = false) -> String{
        
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        
        
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: options)// .dataWithJSONObject(value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            } catch {
                
            }
        }
        return ""
        
    }
    
    
    func JSONParseArray(_ string: String) -> [AnyObject]{
        if let data = string.data(using: String.Encoding.utf8){
            do {
                if let array = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [AnyObject] {
                    return array
                }
            } catch {
                
            }
        }
        return [AnyObject]()
    }
    
    
    func JSONParseDictionary(_ string: String) -> [String: AnyObject]{
        if let data = string.data(using: String.Encoding.utf8){
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]{
                    
                    return dictionary
                    
                }
            } catch {
                
            }
        }
        return [String: AnyObject]()
    }
}
