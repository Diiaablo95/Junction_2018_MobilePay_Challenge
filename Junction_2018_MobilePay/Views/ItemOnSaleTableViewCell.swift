//
//  ItemOnSaleTableViewCell.swift
//  Junction_2018_MobilePay
//
//  Created by Antonio Antonino on 11/24/18.
//  Copyright © 2018 Antonio Antonino. All rights reserved.
//

import UIKit

struct ItemOnSale {
    let image: UIImage
    let name: String
    let price: Double
}

class ItemOnSaleTableViewCell: UITableViewCell { 
    
    @IBOutlet weak var itemImageView: UIImageView! {
        didSet {
            self.itemImageView.layer.cornerRadius = 10
            self.itemImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    func configure(itemOnSale: ItemOnSale) {
        self.itemImageView.image = itemOnSale.image
        self.itemNameLabel.text = itemOnSale.name
        self.itemPriceLabel.text = String(format: "%.2f €", itemOnSale.price)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        self.itemImageView.image = nil
        self.itemNameLabel.text = nil
        self.itemPriceLabel.text = nil
    }
    
}
