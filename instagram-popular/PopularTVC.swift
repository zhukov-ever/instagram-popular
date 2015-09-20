//
//  ViewController.swift
//  instagram-popular
//
//  Created by Zhn on 19/09/2015.
//  Copyright (c) 2015 zhn. All rights reserved.
//

import UIKit

class PopularCell: UITableViewCell {
    
    @IBOutlet weak var imageViewPopular: UIImageView!
    @IBOutlet weak var labelCaption: UILabel!
    
    var info:PopularInfo? {
        didSet {
            if info == nil || info?.caption == nil {
                self.labelCaption.hidden = true
            } else {
                self.labelCaption.hidden = false
                self.labelCaption.text = info?.caption;
            }
            
            self.imageViewPopular.sd_setImageWithURL(NSURL(string: info!.imageUrl!))
        }
    }
    
}

class PopularTVC: UITableViewController {

    let dataManager = PopularDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataManager.delegate = self
        self.dataManager.apiReload()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refreshHandler", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func refreshHandler() {
        self.dataManager.apiReload()
    }
    
    @IBAction func logoutHandler(sender: AnyObject) {
        AuthDataStorage.authToken = nil
        InstagramAuthRouter.show(self, animated: true)
    }
    
    func showAlert() {
        if self.presentedViewController != nil {
            return
        }
        
        let _alert = UIAlertController.new()
        _alert.title = "Ошибка"
        _alert.message = "Не удалось обновить данные. Попробовать еще раз?"
        
        let _alertActionOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action:UIAlertAction!) -> Void in
            self.dataManager.apiReload()
        }
        let _alertActionCancel = UIAlertAction(title: "Отмена", style: UIAlertActionStyle.Cancel) { (action:UIAlertAction!) -> Void in }
            
        _alert.addAction(_alertActionOk)
        _alert.addAction(_alertActionCancel)
        self.presentViewController(_alert, animated: true, completion: nil)
    }
}


extension PopularTVC: PopularDataManagerDelegate {
    
    func dataManagerReloadApiFailed(dataManager: PopularDataManager, error: NSError) {
        self.showAlert()
        self.refreshControl?.endRefreshing()
    }
    
    func dataManagerReloadApiSuccessfully(dataManager: PopularDataManager) {
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
}


extension PopularTVC: UITableViewDelegate, UITableViewDataSource {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGRectGetWidth(UIScreen.mainScreen().bounds)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataManager.data != nil {
            return self.dataManager.data!.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let _cell = tableView.dequeueReusableCellWithIdentifier("cell") as! PopularCell
        
        let _info = self.dataManager.data![indexPath.row] as! PopularInfo
        
        _cell.info = _info
        
        return _cell;
    }
    
}