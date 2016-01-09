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
    var characteristicRead : CBMutableCharacteristic //= CBMutableCharacteristic()
    var characteristicWrite : CBMutableCharacteristic //= CBMutableCharacteristic()
    
    override init() {
        // Encounter Read キャラクタリスティックの生成
        let properties: CBCharacteristicProperties = ([CBCharacteristicProperties.Read, CBCharacteristicProperties.Notify])
        var permissions: CBAttributePermissions = .Readable
        self.characteristicRead = CBMutableCharacteristic(type: self.characteristicUUIDRead, properties: properties, value: nil,
            permissions: permissions)
        
        
        let service: CBMutableService = CBMutableService(type: self.serviceUUID, primary: true)
        // Encounter Write キャラクタリスティックの生成
        permissions = .Writeable
        self.characteristicWrite = CBMutableCharacteristic(type: self.characteristicUUIDWrite, properties: CBCharacteristicProperties.Write, value: nil, permissions: permissions)
        service.characteristics = [self.characteristicRead, self.characteristicWrite]
        self.peripheralManager.addService(service)
        
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
        
        self.peripheralManager = CBPeripheralManager.init(delegate: self, queue: nil, options: options as? [String : AnyObject])
        self.serviceUUID = CBUUID(string: Constants.kServiceUUIDEncounter)
        self.characteristicUUIDRead = CBUUID(string: Constants.kCharacteristicUUIDEncounterRead)
        self.characteristicUUIDWrite = CBUUID(string: Constants.kCharacteristicUUIDEncounterWrite)
        
        
    }
    
    // MARK: Private
    
    func publishService() {
        let service: CBMutableService = CBMutableService(type: self.serviceUUID, primary: true)
        
        // Encounter Read キャラクタリスティックの生成
        let properties: CBCharacteristicProperties = ([CBCharacteristicProperties.Read, CBCharacteristicProperties.Notify])
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
        let advertisementData: [NSObject : AnyObject] = [CBAdvertisementDataLocalNameKey: kLocalName, CBAdvertisementDataServiceUUIDsKey: [self.serviceUUID]]
        self.peripheralManager.startAdvertising(advertisementData as? [String : AnyObject])
    }
    
    func stopAdvertising() {
        if self.peripheralManager.isAdvertising {
            self.peripheralManager.stopAdvertising()
        }
    }
    
    // MARK: Public
    func updateUsername() {
        if self.characteristicRead.description.characters.count == 0 {
            print("Failed", terminator: "")
        }else{
            return
        }
        
        // ユーザー名がまだなければ更新しない
        if BSRUserDefaults.username().characters.count == 0 {
            print("Failed", terminator: "")
        }else{
            return
        }
        let data: NSData = BSRUserDefaults.username().dataUsingEncoding(NSUTF8StringEncoding)!
        // valueを更新
        self.characteristicRead.value = data
        // Notificationを発行
        let result: Bool = self.peripheralManager.updateValue(data, forCharacteristic: self.characteristicRead, onSubscribedCentrals: nil)
        NSLog("Result for update: %@", result ? "Succeeded" : "Failed")
    }
    
    // MARK: CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("Updated state:%ld", peripheral.state, terminator: "")
        switch peripheral.state {
        case .PoweredOn:
            // サービス登録
            if self.characteristicRead.description.characters.count == 0 {
                print("peripheralManagerDidUpdateState Failed", terminator: "")
            }else{
                self.publishService()
            }
        default:
            break
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if error.debugDescription.characters.count == 0 {
            
        }else{
            print("error:%@", error, terminator: "")
            return
        }
        // 現在のユーザー名を格納する
        self.updateUsername()
        // アドバタイズ開始
        self.startAdvertising()
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error.debugDescription.characters.count == 0 {
            
        }else{
            print("error:%@", error, terminator: "")
            return
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        // CBCharacteristicのvalueをCBATTRequestのvalueにセット
        request.value = self.characteristicRead.value
        // リクエストに応答
        self.peripheralManager.respondToRequest(request, withResult: .Success)

    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        for aRequest: CBATTRequest in requests {
            NSLog("Requested value:%@ service uuid:%@ characteristic uuid:%@", aRequest.value!, aRequest.characteristic.service.UUID, aRequest.characteristic.UUID)
            // CBCharacteristicのvalueに、CBATTRequestのvalueをセット
            self.characteristicWrite.value = aRequest.value
            // ViewControllerに移譲
            // var name:NSString = NSString(data: aRequest.value, encoding: NSUTF8StringEncoding)!
            // self.deleagte.didEncounterUserWithName(name)
        }
        // リクエストに応答
        self.peripheralManager.respondToRequest(requests[0], withResult: .Success)
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        print("peripheralManagerIsReadyToUpdateSubscribers")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject]) {
        
        if let services = dict[CBPeripheralManagerRestoredStateServicesKey]{
            
            for var aService : CBMutableService in services as! [CBMutableService] {
                for var aCharacteristic : CBMutableCharacteristic in aService.characteristics as! [CBMutableCharacteristic] {
                    
                    if (aCharacteristic.UUID .isEqual(self.characteristicUUIDRead)) {
                        self.characteristicRead = aCharacteristic
                    }
                        
                    else if (aCharacteristic.UUID .isEqual(self.characteristicUUIDWrite)){
                        
                        self.characteristicWrite = aCharacteristic
                        
                    }
                }
            }
        }
    }
}

