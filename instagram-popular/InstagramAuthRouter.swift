//
//  InstagramAuthRouter.swift
//  instagram-popular
//
//  Created by Zhn on 19/09/2015.
//  Copyright (c) 2015 zhn. All rights reserved.
//

import UIKit

class InstagramAuthRouter: NSObject {
   
    class func show(superview: UIViewController?, animated:Bool) {
        let _sb = UIStoryboard(name: "Main", bundle: nil)
        let _vc:UIViewController = _sb.instantiateViewControllerWithIdentifier("InstagramAuthVC") as! UIViewController
        
        assert(superview != nil, "superview must be defined")
        let _nvc = UINavigationController(rootViewController: _vc)
        _nvc.navigationBarHidden = true
        superview?.presentViewController(_nvc, animated: animated, completion: nil)
    }
    
}
