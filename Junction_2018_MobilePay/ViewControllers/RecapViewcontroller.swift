//
//  RecapViewcontroller.swift
//  Junction_2018_MobilePay
//
//  Created by Antonio Antonino on 11/24/18.
//  Copyright © 2018 Antonio Antonino. All rights reserved.
//

import UIKit
import Alamofire

class RecapViewcontroller: UIViewController {

    @IBOutlet weak var balanceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: 90/255, green: 120/255, blue: 255/255, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.balanceLabel.text = String(format: "%.2f €", AppDelegate.balance)
    }
}
