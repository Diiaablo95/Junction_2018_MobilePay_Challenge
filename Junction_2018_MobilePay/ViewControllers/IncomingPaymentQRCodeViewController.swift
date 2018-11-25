//
//  IncomingPaymentQRCodeViewController.swift
//  Junction_2018_MobilePay
//
//  Created by Antonio Antonino on 11/24/18.
//  Copyright © 2018 Antonio Antonino. All rights reserved.
//

import UIKit
import BluetoothKit
import Alamofire
import NotificationBannerSwift

class IncomingPaymentQRCodeViewController: UIViewController {

    var itemOnSale: ItemOnSale!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 90/255, green: 120/255, blue: 255/255, alpha: 1)
        self.title = "Money time!"
        
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        
        let serializedItemOnSale = try! JSONSerialization.data(withJSONObject: ["userID": AppDelegate.USER_ID, "amount": itemOnSale.price], options: [])
        
        filter.setValue(serializedItemOnSale, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        
        self.qrCodeImageView.image = UIImage(ciImage: filter.outputImage!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        BLECentral.instance.start(withMessageHandler: { messageReceived in
            let encodedRequest = try! JSONSerialization.jsonObject(with: messageReceived, options: []) as! [String: Any]
            
            let senderID = encodedRequest["from"] as! String
            let receiverID = encodedRequest["to"] as! String
            let amount = encodedRequest["amount"] as! Double
            
            Alamofire
                .request(AppDelegate.SERVER_ADDRESS + "transfer?from=\(senderID)&to=\(receiverID)&amount=\(amount)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, method: HTTPMethod.post, parameters: nil, encoding: URLEncoding.default, headers: nil)
                .response(queue: DispatchQueue.main, completionHandler: { response in
                    
                    guard let resp = response.response else { return }
                    switch (resp.statusCode) {
                    case 200:
                        BLECentral.instance.send(message: "OK-\(amount)".data(using: .utf8)!)
                        GrowingNotificationBanner(title: "Payment of \(amount) received!", subtitle: "", style: .success).show()
                    case 400:
                        BLECentral.instance.send(message: "INSUFFICIENT".data(using: .utf8)!)
                        GrowingNotificationBanner(title: "Payment unsuccesful", subtitle: "Not enough money!", style: .danger).show()
                    default:
                        BLECentral.instance.send(message: "NO".data(using: .utf8)!)
                        GrowingNotificationBanner(title: "Ops!", subtitle: "Something went wrong! Please try again...", style: .warning).show()
                    }
                })
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        BLECentral.instance.stop()
    }

}
