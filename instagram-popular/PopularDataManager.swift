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

let kArchName = "_arch"

class PopularDataManager {
    
    let urlServer = NSURL(string:"v1/", relativeToURL: kServerUrl)
    
    var data:NSArray? = nil
    weak var delegate: PopularDataManagerDelegate?
    
    func clearCache() {
        let _documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        let _fileManager = NSFileManager.defaultManager()
        let _enumerator = _fileManager.enumeratorAtPath(_documentsPath)
        while let file = _enumerator?.nextObject() as? String {
            if file != kArchName {
                _fileManager.removeItemAtPath("\(_documentsPath)/\(file)", error: nil)
            }
        }
    }
    
    func cacheReload() {
        self.data = NSKeyedUnarchiver.unarchiveObjectWithFile(self.archivePath()) as? NSArray
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.delegate?.dataManagerReloadApiSuccessfully(self)
        })
    }
    
    func apiReload() {
        if AuthDataStorage.authToken == nil {
            return;
        }
        let _queue:NSOperationQueue = NSOperationQueue()
        let _url = NSURL(string: "media/popular?access_token=\(AuthDataStorage.authToken!)", relativeToURL: self.urlServer)
        let _request = NSURLRequest(URL: _url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        NSURLConnection.sendAsynchronousRequest(_request, queue: _queue) { (responce:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            if data != nil && error == nil {
                var _errorTmp: NSError?
                var dict = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: &_errorTmp) as? NSDictionary
                if let _error = _errorTmp {
                    self.cacheReload()
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
                        if self.data != nil {
                            self.clearCache()
                            NSKeyedArchiver.archiveRootObject(self.data!, toFile:self.archivePath())
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.delegate?.dataManagerReloadApiSuccessfully(self)
                    })
                    
                }
            } else {
                self.cacheReload()
            }
        }
        
    }
    
    func archivePath() -> String {
        let _documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        return "\(_documentsPath)/\(kArchName)"
    }
    
}


protocol PopularDataManagerDelegate : NSObjectProtocol {
    
    func dataManagerReloadApiSuccessfully(dataManager:PopularDataManager)
    func dataManagerReloadApiFailed(dataManager:PopularDataManager, error:NSError)
    
}

