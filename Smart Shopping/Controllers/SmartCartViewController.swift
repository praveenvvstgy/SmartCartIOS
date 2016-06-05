//
//  ViewController.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 5/22/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FoldingTabBar

class SmartCartViewController: UIViewController {

    @IBOutlet weak var cartStatusIndicator: UILabel!
    @IBOutlet weak var cartTable: UITableView!

    let databaseRef = FIRDatabase.database().reference()
    var cartContents = [BaseItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cartTable.dataSource = self
        cartTable.delegate = self
        cartTable.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view, typically from a nib.
        loadCartContents()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadCartContents), name: "cartRefreshed", object: nil)
        databaseRef.child("carts").child("cart1").child("activeUser").observeEventType(.ChildAdded, withBlock: {
            (snapshot) in
            if snapshot.key == "user1" {
                self.cartStatusIndicator.text = "🎾 Connected to Cart#1"
            } else {
                self.cartStatusIndicator.text = "🔴 Not Connected to Cart"
            }
        })
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        loadCartContents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func loadCartContents() {
        var itemsNotInProductsCache = Array(smartCart.items.subtract(productsCache.getItemIdsInCache()))
        if itemsNotInProductsCache.count > 0 {
            if itemsNotInProductsCache.count > 20 {
                itemsNotInProductsCache = Array(itemsNotInProductsCache[0..<20])
            }
            walmartAPI.products(itemsNotInProductsCache).addObserver(owner: self) { (resource, event) in
                if case .NewData = event {
                    if let products: [BaseItem] = resource.typedContent() {
                        productsCache.addProductsToCache(products)
                        self.loadCartContents()
                    }
                }
                }.loadIfNeeded()
        } else {
            cartContents = productsCache.getCachedProductsForItemIds(Array(smartCart.items))
            cartTable.reloadData()
        }

    }

}

//MARK: UITableViewDataSource
extension SmartCartViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Smart Cart"
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var sum = 0.0
        for content in cartContents {
            if let salePrice = content.salePrice {
                sum += salePrice
            }
        }
        return "Total: ₹ \(sum)"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartContents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! ProductCell
        
        let product = cartContents[indexPath.row]
        
        if let name = product.name {
            cell.foregroundTitleLabel.text = name
        }
        
        if let salePrice = product.salePrice {
            cell.foregroundPriceLabel.text = "$ " + String(salePrice)
        }
        
        if let thumbnail = product.thumbnailImage {
            cell.foregroundThumbnail.imageURL = thumbnail
        }
        
        return cell
    }
}

//MARK: UITableViewDelegate
extension SmartCartViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}

//MARK: YALTabBarInteracting
extension SmartCartViewController: YALTabBarInteracting {
    func extraLeftItemDidPress() {
        
    }
    
    func extraRightItemDidPress() {
        print("User Checked Out")
        let checkoutCounter = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CheckoutViewController")
        checkoutCounter.modalPresentationStyle = .FullScreen
        presentViewController(checkoutCounter, animated: true, completion: nil)
    }
}
