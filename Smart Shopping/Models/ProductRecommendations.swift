//
//  ProductRecommendations.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 6/7/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Whisper

class ProductRecommendations {
    var items = Set<Int>() {
        didSet {
            var itemsToBeFetched = Array(items.subtract(productsCache.getItemIdsInCache()))
            if itemsToBeFetched.count > 0 {
                if itemsToBeFetched.count > 20 {
                    itemsToBeFetched = Array(itemsToBeFetched[0..<20])
                }
                walmartAPI.products(itemsToBeFetched).addObserver(owner: self) { (resource, event) in
                    if case .NewData = event {
                        if let products: [BaseItem] = resource.typedContent() {
                            productsCache.addProductsToCache(products)
                            NSNotificationCenter.defaultCenter().postNotificationName("recommendationsRefreshed", object: nil)
                        }
                    }
                }.loadIfNeeded()
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName("recommendationsRefreshed", object: nil)
            }
        }
        
    }
    let databaseRef = FIRDatabase.database().reference()
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(fetchRecommendations), name: "fetchRecommendation", object: nil)
        fetchRecommendations()
    }
    
    @objc func fetchRecommendations() {
        if smartCart.items.count > 0 {
            if let itemId = smartCart.lastInsertedItem {
                walmartAPI.recommendations(itemId).addObserver(owner: self, closure: { (resource, event) in
                    if case .NewData = event {
                        if let products: [BaseItem] = resource.typedContent() {
                            productsCache.addProductsToCache(products)
                            let itemIds = products.map({ (item) -> Int in
                                return item.itemId!
                            })
                            self.items = Set(itemIds)
                            NSNotificationCenter.defaultCenter().postNotificationName("recommendationsRefreshed", object: nil)
                        }
                    }
                }).loadIfNeeded()
            }
        }
    }

}

let productRecommendations = ProductRecommendations()