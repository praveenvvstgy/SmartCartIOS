//
//  BaseItem.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 6/3/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import SwiftyJSON

struct BaseItem {
    let itemId: Int?
    let name: String?
    let msrp: Double?
    let salePrice: Double?
    let upc: String?
    let categoryPath: String?
    let longDescription: String?
    let thumbnailImage: String?
    
    init(json: JSON) {
        print(json)
        itemId = json["itemId"].int
        name = json["name"].string
        msrp = json["msrp"].double
        salePrice = json["salePrice"].double
        upc = json["upc"].string
        categoryPath = json["categoryPath"].string
        longDescription = json["longDescription"].string
        thumbnailImage = json["thumbnailImage"].string
    }
}