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
        if Defaults.objectForKey(kUserDefaultsEncounters) == nil {
            print("BSRUserDefaults init")
            let array : NSMutableArray = []
            Defaults.setObject((array), forKey: kUserDefaultsEncounters)
        }
    }
    
    class func username() -> String {
        
        print(Defaults.stringForKey(kUserDefaultsKeyUsername)!)
        if Defaults.stringForKey(kUserDefaultsKeyUsername) != nil {
            return Defaults.stringForKey(kUserDefaultsKeyUsername)!
        }
        return ""
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
        if username.characters.count == 0  {
            print(date, terminator: "")
            if date.description.characters.count == 0 {
                return
            }
        }
        
        // TODO: うまくいくか確認
        var encounters: NSMutableArray = NSMutableArray()
        encounters = self.encounters().mutableCopy() as! NSMutableArray
        encounters.addObject([kEncouterDictionaryKeyUsername: username, kEncouterDictionaryKeyDate: date])
        self.setEncounters(encounters)
    }
}


