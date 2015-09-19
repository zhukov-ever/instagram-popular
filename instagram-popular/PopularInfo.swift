//
//  PopularInfo.swift
//  instagram-popular
//
//  Created by Zhn on 19/09/2015.
//  Copyright (c) 2015 zhn. All rights reserved.
//

import UIKit

class PopularInfo {
    var caption:String?
    var imageUrl:String?
    
    init(dictionary: NSDictionary) {
        let _images = dictionary["images"] as? NSDictionary
        let _caption = dictionary["caption"] as? NSDictionary
        
        if _images != nil {
            let _standartImage = _images!["standard_resolution"] as? NSDictionary
            
            if (_standartImage != nil) {
                self.imageUrl = _standartImage!["url"] as? String
            }
        }
        
        if _caption != nil {
            self.caption = _caption!["text"] as? String
        }
        
    }
    
}
