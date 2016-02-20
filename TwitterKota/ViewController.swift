//
//  ViewController.swift
//  TwitterKota
//
//  Created by Kotaro Suto on 2015/10/03.
//  Copyright (c) 2015年 Kotaro Suto. All rights reserved.
//

import UIKit
import TwitterKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(__FUNCTION__)
        let loginButton = TWTRLogInButton(logInCompletion: {
            session, error in
            let userSession = session
            let userData : NSData = NSKeyedArchiver.archivedDataWithRootObject(userSession!);
            if session != nil {
                print(session!.userName)
                // ログイン成功したら遷移する
                let loginDefaults = NSUserDefaults.standardUserDefaults()
                loginDefaults.setObject(userData, forKey: "USERSESSION")
                loginDefaults.synchronize()
                self.dismissViewControllerAnimated(false, completion: nil)
            } else {
                print(error!.localizedDescription)
                //self.performSegueWithIdentifier("toHome", sender: nil)
            }
        })
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

