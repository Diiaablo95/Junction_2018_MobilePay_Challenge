//
//  AppDelegate.swift
//  Junction_2018_MobilePay
//
//  Created by Antonio Antonino on 11/24/18.
//  Copyright © 2018 Antonio Antonino. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static let USER_ID = UIDevice.current.identifierForVendor?.uuidString == "3DAF23F1-3592-4077-A124-10AD8B584771" ? "alice" : "bob"
    static let SERVER_ADDRESS = "http://10.100.17.32:3000/"
    
    static var balance: Double {
        set {
            UserDefaults.standard.set(newValue, forKey: "balance")
            UserDefaults.standard.synchronize()
        }
        
        get {
            return UserDefaults.standard.double(forKey: "balance")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Alamofire
            .request(AppDelegate.SERVER_ADDRESS + "user", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .response(queue: DispatchQueue.main, completionHandler: { response in
                guard let result = try? JSONSerialization.jsonObject(with: response.data!, options: []) as! [[String: Any]] else { return }
                AppDelegate.balance = result.filter({ $0["name"] != nil && ($0["name"] as! String) == AppDelegate.USER_ID }).map({ $0["balance"] as! Double }).first!
            })
        return true
    }

}

