//
//  SearchTableCell.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 6/3/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import Siesta

class SearchTableCell: UITableViewCell {
    @IBOutlet weak var thumbnail: RemoteImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var salePrice: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
}
