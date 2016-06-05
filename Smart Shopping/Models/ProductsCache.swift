//
//  ProductsCache.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 6/4/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import Foundation

class ProductsCache {
    var products = [Int: BaseItem]()
    
    func addProductToCache(product: BaseItem) {
        if let itemId = product.itemId {
            if products[itemId] == nil {
                products[itemId] = product
            }
        }
    }
    
    func addProductsToCache(products: [BaseItem]) {
        for product in products {
            if let itemId = product.itemId {
                if self.products[itemId] == nil {
                    self.products[itemId] = product
                }
            }
        }
    }
    
    func getCachedProductForItemId(itemId: Int) -> BaseItem? {
        if let product  = products[itemId] {
            return product
        }
        return nil
    }
    
    func getCachedProductsForItemIds(itemIds: [Int]) -> [BaseItem] {
        var tmpProducts = [BaseItem]()
        for (itemId, product) in products {
            if itemIds.contains(itemId) {
                tmpProducts.append(product)
            }
        }
        return tmpProducts
    }
    
    func getItemIdsInCache() -> [Int] {
        return Array(products.keys)
    }

}

let productsCache = ProductsCache()
        