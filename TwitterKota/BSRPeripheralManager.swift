//
//  BSRPeripheralManager.swift
//  TwitterKota
//
//  Created by Kotaro Suto on 2015/11/21.
//  Copyright (c) 2015年 Kotaro Suto. All rights reserved.
//

import UIKit
import CoreBluetooth

class BSRPeripheralManager: NSObject, CBPeripheralManagerDelegate {
    
    let kLocalName : NSString = "Surechigai"
    
    var peripheralManager : CBPeripheralManager = CBPeripheralManager()
    var serviceUUID : CBUUID = CBUUID()
    var characteristicUUIDRead : CBUUID = CBUUID()
    var characteristicUUIDWrite : CBUUID = CBUUID()
    var characteristicRead : CBMutableCharacteristic = CBMutableCharacteristic()
    var characteristicWrite : CBMutableCharacteristic = CBMutableCharacteristic()
    
    override init() {
        super.init()
        var delegate : BSREncounterDelegate
    }
    //Swift
    
    class func sharedManager() -> BSRPeripheralManager {
        var instance : BSRPeripheralManager!
        var token = dispatch_once_t()
        
        dispatch_once(&token, {
            instance = BSRPeripheralManager()
            instance.initInstance()
        })
        return instance;
    }
    
    func initInstance() {
        let options : NSDictionary = ["CBCentralManagerOptionShowPowerAlertKey" : true,"CBPeripheralManagerOptionRestoreIdentifierKey" : Constants.kRestoreIdentifierKey]
        
    }
    
    // MARK: Private
    
    func publishService() {
        var service: CBMutableService = CBMutableService(type: self.serviceUUID, primary: true)
        
        // Encounter Read キャラクタリスティックの生成
        var properties: CBCharacteristicProperties = (CBCharacteristicProperties.Read | CBCharacteristicProperties.Notify)
        var permissions: CBAttributePermissions = .Readable
        self.characteristicRead = CBMutableCharacteristic(type: self.characteristicUUIDRead, properties: properties, value: nil, permissions: permissions)
        
        // Encounter Write キャラクタリスティックの生成
        permissions = .Writeable
        self.characteristicWrite = CBMutableCharacteristic(type: self.characteristicUUIDWrite, properties: CBCharacteristicProperties.Write, value: nil, permissions: permissions)
        service.characteristics = [self.characteristicRead, self.characteristicWrite]
        self.peripheralManager.addService(service)
    }
    
    func startAdvertising() {
        if self.peripheralManager.isAdvertising {
            return
        }
        var advertisementData: [NSObject : AnyObject] = [CBAdvertisementDataLocalNameKey: kLocalName, CBAdvertisementDataServiceUUIDsKey: [self.serviceUUID]]
        self.peripheralManager.startAdvertising(advertisementData)
    }
    
    func stopAdvertising() {
        if self.peripheralManager.isAdvertising {
            self.peripheralManager.stopAdvertising()
        }
    }
    
    // MARK: Public
    func updateUsername() {
        if count(self.characteristicRead.description) == 0 {
            print("Failed")
        }else{
            return
        }
        
        // ユーザー名がまだなければ更新しない
        if count(BSRUserDefaults.username()) == 0 {
            print("Failed")
        }else{
            return
        }
        var data: NSData = BSRUserDefaults.username().dataUsingEncoding(NSUTF8StringEncoding)!
        // valueを更新
        self.characteristicRead.value = data
        // Notificationを発行
        var result: Bool = self.peripheralManager.updateValue(data, forCharacteristic: self.characteristicRead, onSubscribedCentrals: nil)
        NSLog("Result for update: %@", result ? "Succeeded" : "Failed")
    }
    
    // MARK: CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("Updated state:%ld", peripheral.state)
        switch peripheral.state {
        case .PoweredOn:
            // サービス登録
            if count(self.characteristicRead.description) == 0 {
                print("peripheralManagerDidUpdateState Failed")
            }else{
                self.publishService()
            }
        default:
            break
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didAddService service: CBService!, error: NSError!) {
        if count(error.debugDescription) == 0 {
            
        }else{
            print("error:%@", error)
            return
        }
        // 現在のユーザー名を格納する
        self.updateUsername()
        // アドバタイズ開始
        self.startAdvertising()
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        if count(error.debugDescription) == 0 {
            
        }else{
            print("error:%@", error)
            return
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveReadRequest request: CBATTRequest!) {
        // CBCharacteristicのvalueをCBATTRequestのvalueにセット
        request.value = self.characteristicRead.value
        // リクエストに応答
        self.peripheralManager.respondToRequest(request, withResult: .Success)

    }
    
//    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveWriteRequests requests: [CBATTRequest]) {
//        for aRequest: CBATTRequest in requests {
//            NSLog("Requested value:%@ service uuid:%@ characteristic uuid:%@", aRequest.value, aRequest.characteristic.service.UUID, aRequest.characteristic.UUID)
//            // CBCharacteristicのvalueに、CBATTRequestのvalueをセット
//            self.characteristicWrite.value = aRequest.value
//            // ViewControllerに移譲
//           // var name:NSString = NSString(data: aRequest.value, encoding: NSUTF8StringEncoding)!
//           // self.deleagte.didEncounterUserWithName(name)
//        }
//        // リクエストに応答
//        self.peripheralManager.respondToRequest(requests[0], withResult: .Success)
//
//    }
}

