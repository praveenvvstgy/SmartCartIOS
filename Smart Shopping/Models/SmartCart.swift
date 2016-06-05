//
//  SmartCart.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 6/5/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import Foundation
import FirebaseDatabase

class SmartCart {
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
                            NSNotificationCenter.defaultCenter().postNotificationName("cartRefreshed", object: nil)
                        }
                    }
                }.loadIfNeeded()
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName("cartRefreshed", object: nil)
            }
        }

    }
    let databaseRef = FIRDatabase.database().reference()
    
    init() {
        databaseRef.child("carts").child("cart1").child("contents").observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if let products = snapshot.value as? [String: Int] {
                self.items = Set(products.values)
            }
        })
    }
}

let smartCart = SmartCart()