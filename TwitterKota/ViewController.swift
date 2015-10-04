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
        let loginButton = TWTRLogInButton(logInCompletion: {
            session, error in
            if session != nil {
                println(session!.userName)
                // ログイン成功したらクソ遷移する
            } else {
                println(error!.localizedDescription)
                self.dismissViewControllerAnimated(true, completion:nil)
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

