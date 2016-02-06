//
//  BSREncounterDelegate.swift
//  TwitterKota
//
//  Created by Kotaro Suto on 2015/11/21.
//  Copyright (c) 2015年 Kotaro Suto. All rights reserved.
//

import Foundation

public protocol BSREncounterDelegate{
func didEncounterUserWithName(username : String)
}

class BSREncounter{
    weak var deleagte : AnyObject?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

