//
//  ShoppingList.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 6/4/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import Foundation
import Firebase

class ShoppingList {
    
    let databaseRef = FIRDatabase.database().reference()
    
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
                            NSNotificationCenter.defaultCenter().postNotificationName("smartListRefreshed", object: nil)
                        }
                    }
                }.loadIfNeeded()
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName("smartListRefreshed", object: nil)
            }
        }
    }
    
    init() {
        databaseRef.child("lists").child("user1").observeEventType(.Value, withBlock: { (snapshot) in
            if let snapshotItems = snapshot.value as? [String: Int] {
                self.items = Set(snapshotItems.values)
            }
        })
    }
    
    func addItemToShoppingList(item: BaseItem) {
        if let itemId = item.itemId {
            items.insert(itemId)
            let key = databaseRef.child("lists").child("user1").childByAutoId().key
            let childUpdates = ["/lists/user1/\(key)": itemId]
            databaseRef.updateChildValues(childUpdates)
        }
    }
    
    func count() -> Int {
        return items.count
    }
    
    func isProductInList(itemId: Int) -> Bool {
        return items.contains(itemId)
    }
}

let shoppingList = ShoppingList()