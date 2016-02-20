//
//  BSRPeripheralManager.swift
//  TwitterKota
//
//  Created by Kotaro Suto on 2015/11/21.
//  Copyright (c) 2015年 Kotaro Suto. All rights reserved.
//

import UIKit
import CoreBluetooth

class BSRPeripheralManager: NSObject, CBPeripheralManagerDelegate{
    
    let kLocalName : NSString = "Surechigai"
    
    var peripheralManager : CBPeripheralManager = CBPeripheralManager()
    var serviceUUID : CBUUID = CBUUID()
    var characteristicUUIDRead : CBUUID = CBUUID()
    var characteristicUUIDWrite : CBUUID = CBUUID()
    var characteristicRead : CBMutableCharacteristic //= CBMutableCharacteristic()
    var characteristicWrite : CBMutableCharacteristic //= CBMutableCharacteristic()
    var delegate : BSREncounterDelegate?

    override init() {
        print(__FUNCTION__)
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
        //        self.peripheralManager.addService(service)
        super.init()
    }
    //Swift
    class func sharedManager() -> BSRPeripheralManager {
        print(__FUNCTION__,__FILE__)
        var instance : BSRPeripheralManager!
        var token = dispatch_once_t()
        
        dispatch_once(&token, {
            instance = BSRPeripheralManager()
            instance.initInstance()
            print("in \(__FUNCTION__)")
        })
        return instance;
    }
    
    class var sharedInstance : BSRPeripheralManager{
        struct Static {
            static var instance : BSRPeripheralManager = BSRPeripheralManager()
        }
        Static.instance.initInstance()
        return Static.instance
    }
    
    func initInstance() {
        print(__FUNCTION__)
        let options : NSDictionary = ["CBCentralManagerOptionShowPowerAlertKey" : true, "CBPeripheralManagerOptionRestoreIdentifierKey" : Constants.kRestoreIdentifierKey]
        
        self.peripheralManager = CBPeripheralManager.init(delegate: self, queue: nil, options: options as? [String : AnyObject])
        self.serviceUUID = CBUUID(string: Constants.kServiceUUIDEncounter)
        self.characteristicUUIDRead = CBUUID(string: Constants.kCharacteristicUUIDEncounterRead)
        self.characteristicUUIDWrite = CBUUID(string: Constants.kCharacteristicUUIDEncounterWrite)
        
        self.publishService()
    }
    
    // MARK: Private
    
    func publishService() {
        print(__FUNCTION__)
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
        print(__FUNCTION__)
        if self.peripheralManager.isAdvertising {
            return
        }
        let advertisementData: [NSObject : AnyObject] = [CBAdvertisementDataLocalNameKey: kLocalName, CBAdvertisementDataServiceUUIDsKey: [self.serviceUUID]]
        self.peripheralManager.startAdvertising(advertisementData as? [String : AnyObject])
    }
    
    func stopAdvertising() {
        print(__FUNCTION__)
        if self.peripheralManager.isAdvertising {
            self.peripheralManager.stopAdvertising()
        }
    }
    
    // MARK: Public
    func updateUsername() {
        print(__FUNCTION__)
        print("updateUsername")
        if self.characteristicRead.description.characters.count == 0 {
            print("Failed", terminator: "")
        }else{
            print("else in updateUsername")
            //return
        }
        
        // ユーザー名がまだなければ更新しない
        if BSRUserDefaults.username().characters.count == 0 {
            print("Failed", terminator: "")
        }else{
            //return
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
        print(__FUNCTION__)
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
        print(__FUNCTION__)
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
        print(__FUNCTION__)
        if error.debugDescription.characters.count == 0 {
            
        }else{
            print("error:%@", error, terminator: "")
            return
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        print("peripheralManager ->", __FUNCTION__)
        // CBCharacteristicのvalueをCBATTRequestのvalueにセット
        request.value = self.characteristicRead.value
        // リクエストに応答
        self.peripheralManager.respondToRequest(request, withResult: .Success)
        print("request.value -> \(request.value)")
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        print(__FUNCTION__)
        for aRequest: CBATTRequest in requests {
            NSLog("Requested value:%@ service uuid:%@ characteristic uuid:%@", aRequest.value!, aRequest.characteristic.service.UUID, aRequest.characteristic.UUID)
            // CBCharacteristicのvalueに、CBATTRequestのvalueをセット
            self.characteristicWrite.value = aRequest.value
            // ViewControllerに移譲
            //let name = "\(NSString(data: aRequest.value!, encoding: NSUTF8StringEncoding)! as String)さんとすれ違いました。"
            let name = NSString(data: aRequest.value!, encoding: NSUTF8StringEncoding)! as String
            // すれちがいリストに追加
            let date = NSDate()
            BSRUserDefaults.addEncounterWithName(name)(date:date)
            self.delegate?.didEncounterUserWithName(name)
            print("name -> ",name)
            if delegate?.didEncounterUserWithName(name) == nil {
                print("didEncounterUserWithName(name) is nil")
            }

        }
        // リクエストに応答
        self.peripheralManager.respondToRequest(requests[0], withResult: .Success)
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print(__FUNCTION__)
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        print(__FUNCTION__)
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        print(__FUNCTION__)
        print("peripheralManagerIsReadyToUpdateSubscribers")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject]) {
        print(__FUNCTION__)
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

