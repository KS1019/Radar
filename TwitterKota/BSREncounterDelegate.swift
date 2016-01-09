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
    var delegate : BSREncounterDelegate?
}

