//
//  BSRUserDefaults.swift
//  TwitterKota
//
//  Created by Kotaro Suto on 2015/11/21.
//  Copyright (c) 2015年 Kotaro Suto. All rights reserved.
//

import UIKit

let Defaults = NSUserDefaults.standardUserDefaults()



let kUserDefaultsKeyUsername : String = "username"
let kUserDefaultsEncounters : String = "encounters"

let kEncouterDictionaryKeyUsername : String = "username"
let kEncouterDictionaryKeyDate : String = "date"

let kDefaultUsername : String = "名無しさん"





class BSRUserDefaults: NSObject {
    override init() {
        super.init()
    }
    
    class func username() -> String {
        
        return Defaults.stringForKey(kUserDefaultsKeyUsername)!
        
    }
    
    class func setUsername(username : String) {
        Defaults.setObject(username, forKey: kUserDefaultsKeyUsername)
        Defaults.synchronize()
    }

    class func encounters() -> NSArray {
        return Defaults.arrayForKey(kUserDefaultsEncounters)!
    }
    
    class func setEncounters(encounters : NSArray){
        Defaults.setObject(encounters, forKey:kUserDefaultsEncounters)
        Defaults.synchronize()
    }
    
    class func addEncounterWithName(username : String)(date : NSDate) {
        if !count(username) || !date {
            
        }}
}


