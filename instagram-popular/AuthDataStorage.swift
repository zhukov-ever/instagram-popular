//
//  AuthDataManager.swift
//  instagram-popular
//
//  Created by Zhn on 19/09/2015.
//  Copyright (c) 2015 zhn. All rights reserved.
//

import Foundation

let kAuthTokenKey = "kAuthTokenKey"
let kClientId = "684d63b043754662ac5787b3bff22838"
let kRedirectUri = "https://github.com/zhukov-ever/instagram-popular"
let kInstagramAuthTokenKey = "access_token"

class AuthDataStorage {
    
    static var authToken:String?{
        get {
            let _ud = NSUserDefaults.standardUserDefaults()
            let _value:AnyObject? = _ud.objectForKey(kAuthTokenKey)
            if (_value != nil && _value is String){
                return _value as! String?
            }
            return nil;
        }
        set {
            let _ud = NSUserDefaults.standardUserDefaults()
            _ud.setValue(newValue, forKey: kAuthTokenKey)
            
            if (newValue == nil) {
                let _arrayCookies = NSArray(array: NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!)
                for i:Int in 0..<_arrayCookies.count {
                    let _cookie:NSHTTPCookie? = _arrayCookies[i] as? NSHTTPCookie
                    if (_cookie != nil &&
                        _cookie?.domain.rangeOfString("instagram.com") != nil) {
                            NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(_cookie!)
                    }
                }
            }
        }
    }
    
    class func isAutenticated() -> Bool {
        return AuthDataStorage.authToken != nil
    }

    
}
