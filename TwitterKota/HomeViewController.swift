//
//  HomeViewController.swift
//  TwitterKota
//
//  Created by Kotaro Suto on 2015/10/03.
//  Copyright (c) 2015年 Kotaro Suto. All rights reserved.
//

import UIKit
import TwitterKit
//import CoreBluetooth

class HomeViewController: UIViewController{
    @IBOutlet var label:UILabel!
    var loginString : String = "Signed as a"
    var userID : NSString = ""
    //let logoutClass = Logout()
      override func viewDidLoad() {
        super.viewDidLoad()
        //logoutClass.addObserver(self, forKeyPath:"valueOfUserID" , options: .New , context: nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        self.login()
    }
    override func viewWillDisappear(animated: Bool) {
        //self.removeObserver(self, forKeyPath: "valueOfUserID", context: nil)
    }
    func login (){
        //        let sessionStore = Twitter.sharedInstance().sessionStore
        //        let lastSession = sessionStore.session
        let userDefaultOfSession = NSUserDefaults.standardUserDefaults()
        
        
        if  self.isLogin() {
            let userSession = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaultOfSession.objectForKey("USERSESSION") as! NSData) as! TWTRSession
            println("Segue is failed \(userSession.userName)")
            self.label.text = "Signed as \(userSession.userName)"
            userID = userSession.userID
        }else{
            self.performSegueWithIdentifier("toLogin", sender: nil)
            println("Segue is successful ")
        }
        
        
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        println("observer is called")
        if userID == "---" {
            self.login()
        }
    }
    
    @IBAction func logout (){
        let userDefaultOfSession = NSUserDefaults.standardUserDefaults()
        //let userSession = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaultOfSession.objectForKey("USERSESSION") as! NSData) as! TWTRSessionStore
        
        let userSessionStore = Twitter.sharedInstance().sessionStore
        if userID != "" {
            userSessionStore.logOutUserID(userID as String)
            userDefaultOfSession.removeObjectForKey("USERSESSION")
            let userName = ""
            self.label.text = "\(userName)"
            userID = "---"
             var valueOfUserID : NSString = userID
            println("Logout is succesful")
            self.performSegueWithIdentifier("toLogin", sender: nil)
        }else{
                println("Logout is failed")
            }
//        logoutClass.logout()
        }
    

//    class Logout:HomeViewController {
//        let userDefaultOfSession = NSUserDefaults.standardUserDefaults()
//        //let userSession = NSKeyedUnarchiver.unarchiveObjectWithData(userDefaultOfSession.objectForKey("USERSESSION") as! NSData) as! TWTRSessionStore
//        
//        let userSessionStore = Twitter.sharedInstance().sessionStore
//        let i = userID
//        func logout(){
//        if userID != "" {
//        userSessionStore.logOutUserID(userID as String)
//        userDefaultOfSession.removeObjectForKey("USERSESSION")
//        let userName = ""
//        self.label.text = "\(userName)"
//        userID = "---"
//        dynamic var valueOfUserID : NSString = userID
//        println("Logout is succesful")
//        }else{
//        println("Logout is failed")
//        }
//        }
//    }
    
    
    func isLogin() -> Bool{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let loginStatus = userDefaults.objectForKey("USERSESSION")
        if loginStatus != nil {
            return true
            
        }else{
            return false
        }
    }

}
