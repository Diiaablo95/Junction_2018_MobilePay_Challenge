//
//  IncomingPaymentTableViewController.swift
//  Junction_2018_MobilePay
//
//  Created by Antonio Antonino on 11/24/18.
//  Copyright © 2018 Antonio Antonino. All rights reserved.
//

import UIKit

class IncomingPaymentTableViewController: UITableViewController {

    private let possibleArticles = [
        ItemOnSale(image: UIImage(named: "candies")!, name: "Candies", price: 0.3),
        ItemOnSale(image: UIImage(named: "cola")!, name: "Coca-Cola", price: 2.0),
        ItemOnSale(image: UIImage(named: "pizza")!, name: "Pizza", price: 10.0)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(red: 90/255, green: 120/255, blue: 255/255, alpha: 1)
        self.view.backgroundColor = UIColor(red: 90/255, green: 120/255, blue: 255/255, alpha: 1)
        self.tableView.backgroundView?.backgroundColor = UIColor(red: 90/255, green: 120/255, blue: 255/255, alpha: 1)
        self.tableView.rowHeight = 85
        self.tableView.estimatedRowHeight = 85
        self.tableView.separatorColor = UIColor.white
        
        self.tableView.tableFooterView = UIView(frame: .zero)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.possibleArticles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemOnSaleTableViewCell
        
        cell.configure(itemOnSale: self.possibleArticles[indexPath.row])
        cell.backgroundColor = UIColor.clear
        cell.backgroundView = UIView(frame: .zero)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemOnSale = self.possibleArticles[indexPath.item]
        
        self.performSegue(withIdentifier: "showItemQRCode", sender: itemOnSale)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showItemQRCode") {
            let passedParameter = sender as! ItemOnSale
            let destVC = segue.destination as! IncomingPaymentQRCodeViewController
            
            destVC.itemOnSale = passedParameter
        }
    }

}
