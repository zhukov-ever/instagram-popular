//
//  PopularDataManager.swift
//  instagram-popular
//
//  Created by Zhn on 19/09/2015.
//  Copyright (c) 2015 zhn. All rights reserved.
//

import UIKit

let kApiReloadSuccessKey = "kApiReloadSuccessKey"
let kApiReloadFailKey = "kApiReloadFailKey"
let kApiReloadFailUserInfoKey = "kApiReloadFailUserInfoKey"


class PopularDataManager {
    
    let urlServer = NSURL(string:"v1/", relativeToURL: kServerUrl)
    
    var data:NSArray? = nil
    weak var delegate: PopularDataManagerDelegate?
    
    func apiReload() {
        if AuthDataStorage.authToken == nil {
            return;
        }
        let _queue:NSOperationQueue = NSOperationQueue()
        let _url = NSURL(string: "media/popular?access_token=\(AuthDataStorage.authToken!)", relativeToURL: self.urlServer)
        let _request = NSURLRequest(URL: _url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 20)
        
        NSURLConnection.sendAsynchronousRequest(_request, queue: _queue) { (responce:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            if data != nil && error == nil {
                var _errorTmp: NSError?
                var dict = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: &_errorTmp) as? NSDictionary
                if let _error = _errorTmp {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.delegate?.dataManagerReloadApiFailed(self, error: _error)
                    })
                    
                } else {
                    
                    var _dataArray:NSArray? = dict?["data"] as? NSArray
                    if _dataArray != nil {
                        var _rezult = NSMutableArray()
                        for i:Int in 0..<_dataArray!.count {
                            var _dictDataEntry = _dataArray![i] as? NSDictionary
                            if (_dictDataEntry != nil) {
                                _rezult.addObject(PopularInfo(dictionary: _dictDataEntry!))
                            }
                        }
                        self.data = NSArray(array: _rezult)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.delegate?.dataManagerReloadApiSuccessfully(self)
                    })
                    
                }
            }
        }
        
    }
    
    
}


protocol PopularDataManagerDelegate : NSObjectProtocol {
    
    func dataManagerReloadApiSuccessfully(dataManager:PopularDataManager)
    func dataManagerReloadApiFailed(dataManager:PopularDataManager, error:NSError)
    
}

