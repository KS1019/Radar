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
        centralManager = CBCentralManager()
        self.serviceUUID = CBUUID(string: Constants.kServiceUUIDEncounter)
        self.characteristicUUIDRead = CBUUID(string: Constants.kCharacteristicUUIDEncounterRead)
        self.characteristicUUIDWrite = CBUUID(string: Constants.kCharacteristicUUIDEncounterWrite)
        self.peripherals = NSMutableArray(array: [])
        super.init()
    }
    
    
    class func sharedManager() -> BSRCentralManager {
        print(__FUNCTION__)
        var instance : BSRCentralManager!
        var token = dispatch_once_t()
        
        dispatch_once(&token, {
            instance = BSRCentralManager()
            instance.initInstance()
        })
        return instance;
    }
    
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
        for aService : CBService in peripheral.services! {
            for aCharacteristic : CBCharacteristic in aService.characteristics! {
                if (aCharacteristic.UUID .isEqual(self.characteristicUUIDWrite)){
                    // ペリフェラルに情報を送る（Writeする）
                    peripheral.writeValue(data, forCharacteristic: aCharacteristic, type: CBCharacteristicWriteType.WithResponse)
                    break
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
        print("\nperipheral:\(peripheral) \nadvertisementData:\(advertisementData) \nRSSI\(RSSI)")
        
        // 配列に保持
        if !self.peripherals.containsObject(peripheral) {
            self.peripherals.addObject(peripheral)
        }
        
        // 発見したペリフェラルへの接続を開始する
        central.connectPeripheral(peripheral, options: nil)
        
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("peripheral:\(peripheral)")
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        if (error != nil) {
            print("error:\(error)")
        }
        
        self.peripherals.removeObject(peripheral)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        if (error != nil) {
            print("error:\(error)")
        }
        self.peripherals.removeObject(peripheral)
    }
    
    // MARK: CBPeripheralDelegate
    
    // サービス発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
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
            if aService.UUID.isEqual(self.serviceUUID) {
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
                peripheral.readValueForCharacteristic(aCharacteristic)
            }
        }


    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if (error != nil) {
            print("error:\(error)")
            return
        }
        
        // キャラクタリスティックの値から相手のユーザー名を取得
        let username: String = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)!
        NSLog("peripheral:%@, username:%@", peripheral, username)
        // 自分のユーザー名をNSUserDefaultsから取り出す
        let myUsername: String = BSRUserDefaults.username()
        // 相手のユーザー名が入っていて、自分のユーザー名も入力済みのときのみすれちがい処理を行う
        //        if /*username.characters.count !=  nil && */myUsername.characters.count != nil {
        // 結果表示処理をViewControllerに移譲
        self.delegate?.didEncounterUserWithName(username)
        if delegate?.didEncounterUserWithName(username) == nil {
            print("didEncounterUserWithName(username) is nil")
        }
        // 自分のユーザー名をペリフェラル側に伝える
        let data: NSData = myUsername.dataUsingEncoding(NSUTF8StringEncoding)!
        self.writeData(data, peripheral: peripheral)
        //        }
        //        else {
        //            NSLog("すれちがい失敗！%@, %@", username, myUsername)
        //            self.centralManager.cancelPeripheralConnection(peripheral)
        //        }
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil) {
            print("error:\(error)")
        }
        
        // 相手への情報送信が成功でも失敗でも、接続を解除する
        self.centralManager.cancelPeripheralConnection(peripheral)
    }
    
    // アプリケーション復元時に呼ばれる
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
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
