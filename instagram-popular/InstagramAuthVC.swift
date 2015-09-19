//
//  InstagramAuthVC.swift
//  instagram-popular
//
//  Created by Zhn on 19/09/2015.
//  Copyright (c) 2015 zhn. All rights reserved.
//

import UIKit

class InstagramAuthVC: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self
        self.loadUrl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func showAlertReloadPage() {
        if self.presentedViewController != nil {
            return
        }
        let _alert = UIAlertController.new()
        _alert.title = "Ошибка"
        _alert.message = "Не удалось загрузить страницу. Попробовать еще раз?"
        
        let _alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action:UIAlertAction!) -> Void in
            self.loadUrl()
        }
        
        _alert.addAction(_alertAction)
        self.presentViewController(_alert, animated: true, completion: nil)
    }
    
}


extension InstagramAuthVC: UIWebViewDelegate {
    
    func stringForAuth() -> String {
        return "https://api.instagram.com/oauth/authorize/?client_id=\(kClientId)&redirect_uri=\(kRedirectUri)&response_type=token"
    }
    
    func loadUrl() {
        let _request:NSURLRequest = NSURLRequest(URL: NSURL(string: self.stringForAuth())!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 30.0)
        self.webView.loadRequest(_request)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if (request.URL != nil) {
            let _redirectUrl = NSURL(string: kRedirectUri)
            let _compTarget = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: false)
            let _compRedirect = NSURLComponents(URL: _redirectUrl!, resolvingAgainstBaseURL: false)

            if (_compTarget != nil && _compRedirect != nil && _compTarget!.fragment != nil && _compTarget!.host == _compRedirect?.host) {
                let _arr = NSArray(array:_compTarget!.fragment!.componentsSeparatedByString("="))
                if (_arr.count == 2) {
                    let _key = _arr[0] as? String
                    let _value = _arr[1] as? String
                    
                    if _key != nil && _key == kInstagramAuthTokenKey && _value != nil {
                        AuthDataStorage.authToken = _value
                        self.dismissViewControllerAnimated(true, completion: nil)
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        activityIndicator.stopAnimating()
        
        if (error.code != 102) {
            self.showAlertReloadPage()            
        }

    }
    
}
