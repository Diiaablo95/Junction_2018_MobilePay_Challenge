//
//  PaymentViewController.swift
//  Junction_2018_MobilePay
//
//  Created by Antonio Antonino on 11/24/18.
//  Copyright © 2018 Antonio Antonino. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import Alamofire
import NotificationBannerSwift
import BluetoothKit

class OutgoingPaymentViewController: UIViewController {
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    private lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showSwitchCameraButton = false
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 90/255, green: 120/255, blue: 255/255, alpha: 1)
        self.qrCodeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapQRCodeImageView)))
        self.title = "Scan the QRCode!"
    }
    
    @objc private func onTapQRCodeImageView() {
        self.readerVC.delegate = self
        
        self.readerVC.modalPresentationStyle = .formSheet
        self.present(self.readerVC, animated: true, completion: nil)
        
        BLEPeripheral.instance.start(withMessageHandler: { messageReceived in
            
            let messageReceivedStringified = String(data: messageReceived, encoding: .utf8)!
            
            if messageReceivedStringified.starts(with: "OK") {          //OK-{amount}
                GrowingNotificationBanner(title: "Payment complete", subtitle: "You just paid \(Double(messageReceivedStringified.dropFirst(3))!)", style: .success).show()
                AppDelegate.balance -= Double(messageReceivedStringified.dropFirst(3))!
            } else if messageReceivedStringified.starts(with: "INSUFFICIENT") {
                GrowingNotificationBanner(title: "Payment unsuccesful", subtitle: "Not enough money!", style: .danger).show()
            } else {
                GrowingNotificationBanner(title: "Ops!", subtitle: "Something went wrong! Please try again...", style: .warning).show()
            }
        })
    }
}

extension OutgoingPaymentViewController: QRCodeReaderViewControllerDelegate {
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        print(result.value)
        reader.stopScanning()
        reader.dismiss(animated: true, completion: {
            let dictionary = try! JSONSerialization.jsonObject(with: result.value.data(using: .utf8)!, options: []) as! [String: Any]
            
            let receiverID = dictionary["userID"]!
            let amount = dictionary["amount"] as! Double
            let senderID = AppDelegate.USER_ID
            
            BLEPeripheral.instance.send(message: try! JSONSerialization.data(withJSONObject: ["from": senderID, "to": receiverID, "amount": amount], options: []))
        })
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        let cameraName = newCaptureDevice.device.localizedName
        print("Switching capturing to: \(cameraName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
        BLEPeripheral.instance.stop()
    }
}
