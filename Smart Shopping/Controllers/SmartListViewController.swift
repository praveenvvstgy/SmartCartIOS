//
//  SmartListViewController.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 6/4/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import ChameleonFramework
import DZNEmptyDataSet
import FoldingTabBar
import SwiftGifOrigin

class SmartListViewController: UIViewController {
    
    @IBOutlet weak var smartListTable: UITableView!
    
    var localSmartListItems = [BaseItem]()
    
    override func viewDidLoad() {
        
        smartListTable.dataSource = self
        smartListTable.delegate = self
        smartListTable.rowHeight = UITableViewAutomaticDimension
        
        smartListTable.emptyDataSetSource = self
        
        loadShoppingListToLocalStore()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadShoppingListToLocalStore), name: "smartListRefreshed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadShoppingListToLocalStore), name: "cartRefreshed", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        loadShoppingListToLocalStore()
    }
    
    @objc private func loadShoppingListToLocalStore() {
        var itemsNotInProductsCache = Array(shoppingList.items.subtract(productsCache.getItemIdsInCache()))
        if itemsNotInProductsCache.count > 0 {
            if itemsNotInProductsCache.count > 20 {
                itemsNotInProductsCache = Array(itemsNotInProductsCache[0..<20])
            }
            walmartAPI.products(itemsNotInProductsCache).addObserver(owner: self) { (resource, event) in
                if case .NewData = event {
                    if let products: [BaseItem] = resource.typedContent() {
                        productsCache.addProductsToCache(products)
                        self.loadShoppingListToLocalStore()
                    }
                }
            }.loadIfNeeded()
        } else {
            localSmartListItems = productsCache.getCachedProductsForItemIds(Array(shoppingList.items))
            smartListTable.reloadData()
        }
    }
}

//MARK: UITableViewDataSource
extension SmartListViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localSmartListItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! ProductCell
        
        let product = localSmartListItems[indexPath.row]
        
        if let name = product.name {
            cell.foregroundTitleLabel.text = name
        }
        
        if let salePrice = product.salePrice {
            cell.foregroundPriceLabel.text = "$ " + String(salePrice)
        }
        
        if let thumbnail = product.thumbnailImage {
            cell.foregroundThumbnail.imageURL = thumbnail
        }
        
        if let inCartImage = cell.viewWithTag(10) {
            if let itemId = product.itemId {
                if smartCart.items.contains(itemId) {
                    inCartImage.hidden = false
                } else {
                    inCartImage.hidden = true
                }
            }
        }
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProduct" {
            if let destinationViewController = segue.destinationViewController as? ProductDetailViewController {
                if let cell = sender as? UITableViewCell, let indexPath = smartListTable.indexPathForCell(cell) {
                    destinationViewController.product = localSmartListItems[indexPath.row]
                }
            }
        }
    }
}

//MARK: UITableViewDelegate
extension SmartListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 100, 0)
        cell.layer.transform = rotationTransform
        
        UIView.animateWithDuration(1) { 
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
}

//MARK: DZNEmptyDataSetSource
extension SmartListViewController: DZNEmptyDataSetSource {
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSForegroundColorAttributeName: ContrastColorOf(FlatWatermelonDark(), returnFlat: true)]
        return NSAttributedString(string: "Add Products", attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSForegroundColorAttributeName: ContrastColorOf(FlatWatermelonDark(), returnFlat: true)]
        return NSAttributedString(string: "Your Smart List is Empty, Search and Add Products to plan your shopping", attributes: attributes)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return FlatWatermelonDark()
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "add-big")
    }
    
    func imageTintColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return ContrastColorOf(FlatWatermelonDark(), returnFlat: true)
    }
    
}
