//
//  PopularInfo.swift
//  instagram-popular
//
//  Created by Zhn on 19/09/2015.
//  Copyright (c) 2015 zhn. All rights reserved.
//

import UIKit

let kImageDidLoadNotification = "kImageDidLoadNotification"
let kImageDidLoadUrlKey = "kImageDidLoadUrlKey"

class PopularInfo: NSObject, NSCoding {
    
    var caption:String?
    var imageUrl:String?
    
    var image:UIImage?
    
    
    init(dictionary: NSDictionary) {
        super.init()
        
        let _images = dictionary["images"] as? NSDictionary
        let _caption = dictionary["caption"] as? NSDictionary
        
        if _images != nil {
            let _standartImage = _images!["standard_resolution"] as? NSDictionary
            
            if (_standartImage != nil) {
                self.imageUrl = _standartImage!["url"] as? String
                
                self.loadImageWithUrl(self.imageUrl!)
            }
        }
        
        if _caption != nil {
            self.caption = _caption!["text"] as? String
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        self.caption = aDecoder.decodeObjectForKey("caption") as? String
        self.imageUrl = aDecoder.decodeObjectForKey("imageUrl") as? String
        if self.imageUrl != nil {
            self.loadImageWithUrl(self.imageUrl!)
        }

    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.caption, forKey: "caption")
        aCoder.encodeObject(self.imageUrl, forKey: "imageUrl")
    }
    
    
    
    func imageFileName(imageStringUrl:String) -> String {
        let _documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        NSUUID(UUIDString: imageStringUrl)

        return "\(_documentsPath)/\(imageStringUrl.md5)"
    }
    
    func loadImageWithUrl(imageStringUrl:String) {
        self.image = UIImage(contentsOfFile: self.imageFileName(imageStringUrl))
        if self.image == nil && self.imageUrl != nil {
            
            let _queue:NSOperationQueue = NSOperationQueue()
            let _url = NSURL(string: imageStringUrl)
            let _request = NSURLRequest(URL: _url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 20)
            
            NSURLConnection.sendAsynchronousRequest(_request, queue: _queue) { (responce:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
                if data != nil && error == nil {
                    self.image = UIImage(data: data)
                    let b = NSFileManager.defaultManager().createFileAtPath(self.imageFileName(imageStringUrl), contents:data, attributes: nil)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName(kImageDidLoadNotification, object: nil, userInfo:[kImageDidLoadUrlKey : self.imageUrl!])
                    })

                }
            }
            
        }
        
    }
    
}

extension String  {
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return String(format: hash as String)
    }
}

