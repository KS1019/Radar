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
    
      override func viewDidLoad() {
        super.viewDidLoad()
        self.checkTwitterLogin()

    }

    
    func checkTwitterLogin() {
        Twitter.sharedInstance().logInWithCompletion { session, error in
            
            if (session != nil) {
                println("signed in as \(session!.userName)");
                self.label.text = "signed in as \(session!.userName)"

            } else {
                let homeVC = ViewController()
                UIApplication.sharedApplication().keyWindow?.rootViewController = homeVC
            }
        }
    }
    
    func loadFollowersData() {

    }

}
