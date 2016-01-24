//
//  SurechigaiTableViewController.swift
//  TwitterKota
//
//  Created by Kotaro Suto on 2015/11/21.
//  Copyright (c) 2015年 Kotaro Suto. All rights reserved.
//

import UIKit

class SurechigaiTableViewController: UITableViewController ,BSREncounterDelegate{
    var items = []
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Start Searching")
        if Defaults.objectForKey(kUserDefaultsEncounters) == nil {
            print("Defaults init in SurechigaiTableViewController")
            let array : NSMutableArray = []
            Defaults.setObject((array), forKey: kUserDefaultsEncounters)
        }
        self.items = BSRUserDefaults.encounters()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("View appeared")
        // セントラル側は初期化＆スキャン開始する
        BSRCentralManager.sharedManager().delegate = self
        // ペリフェラル側はキャラクタリスティックを更新する
        BSRPeripheralManager.sharedManager().updateUsername()
        NSLog("Start with username: %@", BSRUserDefaults.username())
        
    }
    
    // MARK: TableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.items.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier : String = "Cell";
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)
        // var encounterDic : Dictionary = items[indexPath.row] as Dictionary
        //cell.textLabel?.text = encounterDic.

        var encounterDic: [NSObject : AnyObject] = self.items[indexPath.row] as! [NSObject : AnyObject]
        cell.textLabel!.text = encounterDic[kEncouterDictionaryKeyUsername] as? String
        //cell.detailTextLabel.text = encounterDic[kEncouterDictionaryKeyDate] as! NSDate.descriptionWithLocale;(NSLocale.currentLocale())
        return cell
        
    }
    
    // MARK: BSREncounterDelegate
    func didEncounterUserWithName(username: String) {
        print("didEncounterUserWithName")
        dispatch_async(dispatch_get_main_queue(), {() -> Void in
            // アラート表示
            self.alertWithUsername(username)
            print("\(username)とすれ違いました。")
            // すれちがいリストに追加
            let date = NSDate()
            BSRUserDefaults.addEncounterWithName(username)(date:date)
            self.items = BSRUserDefaults.encounters()
            self.tableView.reloadData()
        })
    }
    
    // MARK: Private
    
    func alertWithUsername(username: String) {
        let msg: String = "\(username)とすれ違いました！"
        // バックグラウンド時はローカル通知
        if UIApplication.sharedApplication().applicationState != .Active {
            let notification: UILocalNotification = UILocalNotification()
            notification.alertBody = msg
            notification.fireDate = NSDate()
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
        else {
            print(msg)
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
