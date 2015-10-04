//
//  HomeViewController.swift
//  TwitterKota
//
//  Created by Kotaro Suto on 2015/10/03.
//  Copyright (c) 2015年 Kotaro Suto. All rights reserved.
//

import UIKit
import TwitterKit
import CoreBluetooth

class HomeViewController: UIViewController, CBCentralManagerDelegate {

    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.checkTwitterLogin()
    }

    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        println("state: \(central.state)")
    }
    
    func checkTwitterLogin() {
        Twitter.sharedInstance().logInWithCompletion { session, error in
            
            if (session != nil) {
                println("signed in as \(session!.userName)");
//                let baseString = "https://api.twitter.com/v1.1"
//                let path = "/followers/ids.json"
//                let parameters : NSDictionary = ["screen_name":"@\(session!.userName)","stringify_ids":true]
//                let twtrRequest = Twitter.sharedInstance().APIClient.URLRequestWithMethod("GET", URL: baseString + path, parameters:parameters as [NSObject : AnyObject], error: nil)
//                Twitter.sharedInstance().APIClient.sendTwitterRequest(twtrRequest) {
//                    (response, data, err) in
//                    switch (response, data, err) {
//                    case (.Some, .Some, .None):
//                        let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers, error: nil)
//                        // JSONObject をアレコレする操作
//                        println("\(json)");
//                    default:
//                        //エラー
//                        println("error");
//                  }
//              }
                self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
            } else {
                println("error: \(error!.localizedDescription)");
                let modalView = ViewController()
                modalView.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                self.presentViewController(modalView, animated: true, completion: nil)
            
            }
        }
    }
    
    func loadFollowersData() {

    }
    
    func centralManager(central: CBCentralManager!,
        didDiscoverPeripheral peripheral: CBPeripheral!,
        advertisementData: [NSObject : AnyObject]!,
        RSSI: NSNumber!)
    {
        println("peripheral: \(peripheral)")
        self.centralManager.stopScan()
    }

}
