//
//  BLE.swift
//  Junction_2018_MobilePay
//
//  Created by Antonio Antonino on 11/25/18.
//  Copyright © 2018 Antonio Antonino. All rights reserved.
//

import Foundation
import BluetoothKit

private let SERVICE_UUID = UUID(uuidString: "43C104AB-E3AD-4C58-92A2-EB70C26DFAB0")!
private let CHARACTERISTIC_UUID = UUID(uuidString: "8613510D-E6B3-4348-9B96-4DD69E661CA2")!

class BLEPeripheral {
    
    static let instance = BLEPeripheral()
    
    private lazy var peripheral: BKPeripheral = {
        let peripheral = BKPeripheral()
        peripheral.delegate = self
        peripheral.addAvailabilityObserver(self)
        
        return peripheral
    }()
    
    typealias BLEPeripheralMessageHandler = (Data) -> Void
    private var messageHandler: BLEPeripheralMessageHandler?
    
    private init() {}
    
    func start(withMessageHandler messageHandler: BLEPeripheralMessageHandler?=nil) {
        self.messageHandler = messageHandler
        do {
            try self.peripheral.startWithConfiguration(BKPeripheralConfiguration(dataServiceUUID: SERVICE_UUID, dataServiceCharacteristicUUIDs: [CHARACTERISTIC_UUID]))
            print("Peripheral started")
        } catch let error as BKError {
            switch (error) {
            case .internalError:
                do {
                    try self.peripheral.resume()
                    print("Peripheral resumed")
                } catch {
                    print("Error with peripheral: \(error.localizedDescription)")
                }
            default:
                fatalError("Should never reach here!")
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func stop() {
        self.messageHandler = nil
        do {
            try self.peripheral.stop()
            print("Peripheral stopped")
        } catch {
            print("Error stopping peripheral: \(error.localizedDescription)")
        }
    }
    
    func send(message: Data) {
        print("Remote centrals connected: \(self.peripheral.connectedRemoteCentrals)")
        self.peripheral.connectedRemoteCentrals.forEach { self.peripheral.sendData(message, toRemotePeer: $0, forUUID: CHARACTERISTIC_UUID, completionHandler: nil) }
    }
}

extension BLEPeripheral: BKPeripheralDelegate {
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral, toCharactersticUUID characteristicUUID: UUID) {
        remoteCentral.delegate = self
    }
    
    func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral, fromCharacteristicUUID characteristicUUID: UUID?) {
        print("Central disconnected")
    }
}

extension BLEPeripheral: BKAvailabilityObserver {
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        print("Peripheral availability changed...\(availability)")
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        print("Peripheral availability cause changed...")
    }
}

extension BLEPeripheral: BKRemotePeerDelegate {
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        self.messageHandler?(data)
    }
}





class BLECentral {
    
    static let instance = BLECentral()
    
    private lazy var central: BKCentral = {
        let central = BKCentral()
        central.delegate = self
        central.addAvailabilityObserver(self)
        
        return central
    }()
    
    typealias BLECentralMessageHandler = (Data) -> Void
    private var messageHandler: BLECentralMessageHandler?
    
    private init() {}
    
    func start(withMessageHandler messageHandler: BLECentralMessageHandler?=nil) {
        self.messageHandler = messageHandler
        do {
            try self.central.startWithConfiguration(BKConfiguration(dataServiceUUID: SERVICE_UUID, dataServiceCharacteristicUUIDs: [CHARACTERISTIC_UUID]))
            print("Central started")
        } catch {
            print("Error starting central: \(error.localizedDescription)")
        }
    }
    
    func send(message: Data) {
        self.central.connectedRemotePeripherals.forEach { self.central.sendData(message, toRemotePeer: $0, forUUID: CHARACTERISTIC_UUID, completionHandler: nil) }
    }
    
    func stop() {
        do {
            try self.central.stop()
            print("Central stopped")
        } catch {
            print("Error stopping central: \(error.localizedDescription)")
        }
    }
    
}

extension BLECentral: BKCentralDelegate {
    
    func central(_ central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        print("Remote peripheral did disconnect")
    }
}

extension BLECentral: BKAvailabilityObserver {
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        print("Central availability did change...\(availability)")
        self.central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            changes.map { $0.discovery.remotePeripheral }.forEach {
                print($0)
                if $0.state == .disconnected {
                    print("Found disconnected peripheral")
                    self.central.connect(remotePeripheral: $0, completionHandler: { _ , _ in })
                    $0.delegate = self
                    $0.peripheralDelegate = self
                }
            }
        }, stateHandler: nil, errorHandler: nil)
    }
    
    func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        print("Central unavailability cause did change...")
    }
}

extension BLECentral: BKRemotePeerDelegate {
    
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        print("Data received from peripheral")
        self.messageHandler?(data)
    }
}

extension BLECentral: BKRemotePeripheralDelegate {
    
    func remotePeripheral(_ remotePeripheral: BKRemotePeripheral, didUpdateName name: String) {
        print("Peripheral did update name")
    }
    
    func remotePeripheralIsReady(_ remotePeripheral: BKRemotePeripheral) {
        print("Peripheral is ready")
    }
}
