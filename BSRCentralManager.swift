//
//  BSRCentralManager.swift
//  TwitterKota
//
//  Created by Kotaro Suto on 2016/01/09.
//  Copyright © 2016年 Kotaro Suto. All rights reserved.
//

import UIKit
import CoreBluetooth


class BSRCentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    var centralManager : CBCentralManager
    var peripherals : NSMutableArray = []
    var serviceUUID : CBUUID
    var characteristicUUIDRead : CBUUID
    var characteristicUUIDWrite : CBUUID
    var bsrEncounter : BSREncounter!
    var delegate: BSREncounterDelegate?
    
    override init(){
        print(__FUNCTION__)
        centralManager = CBCentralManager()
        self.serviceUUID = CBUUID(string: Constants.kServiceUUIDEncounter)
        self.characteristicUUIDRead = CBUUID(string: Constants.kCharacteristicUUIDEncounterRead)
        self.characteristicUUIDWrite = CBUUID(string: Constants.kCharacteristicUUIDEncounterWrite)
        self.peripherals = NSMutableArray(array: [])
        super.init()
    }
    
    
    class var sharedInstance : BSRCentralManager{
        struct Static {
            static var instance : BSRCentralManager = BSRCentralManager()
        }
        Static.instance.initInstance()
        return Static.instance
    }
    
    
//    class func sharedManager() -> BSRCentralManager {
//        print(__FUNCTION__)
//        var instance : BSRCentralManager!
//        var token = dispatch_once_t()
//        
//        dispatch_once(&token, {
//            instance = BSRCentralManager()
//            instance.initInstance()
//        })
//        return instance;
//    }
    
    func initInstance() {
        print(__FUNCTION__)
        let options : NSDictionary = ["CBCentralManagerOptionShowPowerAlertKey" : true]
        self.centralManager = CBCentralManager.init(delegate: self, queue: nil, options: options as? [String : AnyObject])
        
        self.serviceUUID = CBUUID(string: Constants.kServiceUUIDEncounter)
        self.characteristicUUIDRead = CBUUID(string: Constants.kCharacteristicUUIDEncounterRead)
        self.characteristicUUIDWrite = CBUUID(string: Constants.kCharacteristicUUIDEncounterWrite)
        
        self.peripherals = NSMutableArray(array: [])
    }
    
    // MARK: Private
    func writeData(data: NSData, peripheral: CBPeripheral) {
        print(__FUNCTION__)
        if peripheral.services != nil {
            print(peripheral.services)
            for aService : CBService in peripheral.services! {
                if aService.characteristics != nil {
                    print(aService.characteristics)
                    for aCharacteristic : CBCharacteristic in aService.characteristics! {
                        print(aCharacteristic)
                        print(aCharacteristic.UUID)
                        if (aCharacteristic.UUID == self.characteristicUUIDWrite){
                            //ペリフェラルに情報を送る(Writeする)
                            print(aCharacteristic.UUID)
                            peripheral.writeValue(data, forCharacteristic: aCharacteristic, type: CBCharacteristicWriteType.WithResponse)
                            break
                        }
                    }
                }
            }
        }
    }
    
    // MARK: CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print(__FUNCTION__)
        print("Updated state:\(central.state)")
        
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            print("スキャン開始\(__FUNCTION__)")
            self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
            break
        default:
            break
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print(__FUNCTION__)
        //print("\nperipheral:\(peripheral) \nadvertisementData:\(advertisementData) \nRSSI\(RSSI)")
        if peripheral.name != nil {
            print("\n======\n\n名前 : \(peripheral.name!)\nUUID : \(peripheral.identifier)\n\n======\n")
        }
        // 配列に保持
        if !self.peripherals.containsObject(peripheral) {
            self.peripherals.addObject(peripheral)
        }
        
        // 発見したペリフェラルへの接続を開始する
        central.connectPeripheral(peripheral, options: nil)
        
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print(__FUNCTION__)
        //print("peripheral:\(peripheral)")
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print(__FUNCTION__)
        
        if (error != nil) {
            print("error:\(error)")
        }
        
        self.peripherals.removeObject(peripheral)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print(__FUNCTION__)
        
        if (error != nil) {
            print("error:\(error)")
        }
        self.peripherals.removeObject(peripheral)
    }
    
    // MARK: CBPeripheralDelegate
    
    // サービス発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("サービス発見",__FUNCTION__)
        if (error != nil) {
            print("error:\(error)")
        }
        
        if peripheral.services?.count == nil {
            print("No services are found.")
            return
        }
        
        print("services: \(peripheral.services)")
        
        // 目的のサービスを提供しているペリフェラルかどうかを判定
        var hasTargetService = false
        for aService: CBService in peripheral.services! {
            // 目的のサービスを提供していれば、キャラクタリスティック探索を開始する
            print("目的のサービスを提供していれば、キャラクタリスティック探索を開始する")
            if aService.UUID.isEqual(self.serviceUUID) {
                print("===\nTarget is found\n===")
                peripheral.discoverCharacteristics(nil, forService: aService)
                hasTargetService = true
            }
        }
        
        // 目的とするサービスを提供していないペリフェラルの参照を解放する
        if !hasTargetService {
            self.peripherals.removeObject(peripheral)
        }
    }
    
    // キャラクタリスティック発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("キャラクタリスティック発見",__FUNCTION__)
        
        if (error != nil) {
            print("error:\(error)")
            return
        }
        if service.characteristics?.count == nil  {
            print("No characteristics are found.")
            return
        }
        
        for aCharacteristic: CBCharacteristic in service.characteristics! {
            if aCharacteristic.UUID.isEqual(self.characteristicUUIDRead) {
                // 現在値をRead
                print("現在値をRead")
                peripheral.readValueForCharacteristic(aCharacteristic)
            }
        }


    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print(__FUNCTION__)
        if (error != nil) {
            print("error:\(error)")
            return
        }
        print("キャラクタリスティク\(characteristic, characteristic.value)")
        // キャラクタリスティックの値から相手のユーザー名を取得
        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd/ hh:mm"
        let string = formatter.stringFromDate(now)
        let username: String = "C\(String(data: characteristic.value!, encoding: NSUTF8StringEncoding)!)さんとすれ違いました。\(string)"
        //let username: String = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)!
        NSLog("peripheral:%@, username:%@", peripheral, username)
        // 自分のユーザー名をNSUserDefaultsから取り出す
        let myUsername: String = BSRUserDefaults.username()
        // 相手のユーザー名が入っていて、自分のユーザー名も入力済みのときのみすれちがい処理を行う
        //        if /*username.characters.count !=  nil && */myUsername.characters.count != nil {
        // 結果表示処理をViewControllerに移譲
        // すれちがいリストに追加
        let date = NSDate()
        BSRUserDefaults.addEncounterWithName(username)(date:date)
        self.delegate?.didEncounterUserWithName(username)
        if delegate?.didEncounterUserWithName(username) == nil {
            print("didEncounterUserWithName\(username) is nil")
        }
        print("self.writeData",username)
        // 自分のユーザー名をペリフェラル側に伝える
        print("peripheral -> \(peripheral)")

        let data: NSData = myUsername.dataUsingEncoding(NSUTF8StringEncoding)!
        self.writeData(data, peripheral: peripheral)
        //        }
        //        else {
        //            NSLog("すれちがい失敗！%@, %@", username, myUsername)
        //            self.centralManager.cancelPeripheralConnection(peripheral)
        //        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print(__FUNCTION__)
        if (error != nil) {
            print("error:\(error)")
        }
        
        // 相手への情報送信が成功でも失敗でも、接続を解除する
        self.centralManager.cancelPeripheralConnection(peripheral)
    }
    
    // アプリケーション復元時に呼ばれる
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        print(__FUNCTION__)
        // 復元された、接続を試みている、あるいは接続済みのペリフェラル
        let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey]
        
        // プロパティに保持しなおす
        for aPeripheral : CBPeripheral in peripherals as! [CBPeripheral] {
            
            if !self.peripherals.containsObject(aPeripheral) {
                self.peripherals.addObject(aPeripheral)
                
                aPeripheral.delegate = self
            }
        }
    }
    

    
}
