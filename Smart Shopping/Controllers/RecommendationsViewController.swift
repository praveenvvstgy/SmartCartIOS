//
//  RecommendationsViewController.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 6/7/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import ChameleonFramework

class RecommendationsViewController: UIViewController {
    @IBOutlet weak var recommendationsTable: UITableView!
    var localRecommendations = [BaseItem]()
    
    override func viewDidLoad() {
        recommendationsTable.delegate = self
        recommendationsTable.dataSource = self
        
        recommendationsTable.emptyDataSetSource = self
        recommendationsTable.rowHeight = UITableViewAutomaticDimension
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loadRecommendationsToLocalStore), name: "recommendationsRefreshed", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        loadRecommendationsToLocalStore()
    }
    
    @objc private func loadRecommendationsToLocalStore() {
        var itemsNotInProductsCache = Array(productRecommendations.items.subtract(productsCache.getItemIdsInCache()))
        if itemsNotInProductsCache.count > 0 {
            if itemsNotInProductsCache.count > 20 {
                itemsNotInProductsCache = Array(itemsNotInProductsCache[0..<20])
            }
            walmartAPI.products(itemsNotInProductsCache).addObserver(owner: self) { (resource, event) in
                if case .NewData = event {
                    if let products: [BaseItem] = resource.typedContent() {
                        productsCache.addProductsToCache(products)
                        self.loadRecommendationsToLocalStore()
                    }
                }
                }.loadIfNeeded()
        } else {
            localRecommendations = productsCache.getCachedProductsForItemIds(Array(productRecommendations.items))
            recommendationsTable.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProduct" {
            if let destinationViewController = segue.destinationViewController as? ProductDetailViewController {
                if let cell = sender as? UITableViewCell, let indexPath = recommendationsTable.indexPathForCell(cell) {
                    destinationViewController.product = localRecommendations[indexPath.row]
                }
            }
        }
    }
}

extension RecommendationsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localRecommendations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! ProductCell
        
        let product = localRecommendations[indexPath.row]
        
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
            inCartImage.hidden = true
        }
        
        return cell
    }
}

extension RecommendationsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}

extension RecommendationsViewController: DZNEmptyDataSetSource {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSForegroundColorAttributeName: ContrastColorOf(FlatWatermelonDark(), returnFlat: true)]
        return NSAttributedString(string: "No Recommendations", attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSForegroundColorAttributeName: ContrastColorOf(FlatWatermelonDark(), returnFlat: true)]
        return NSAttributedString(string: "Your Smart Cart is Empty, Add Products to get Recommendations", attributes: attributes)
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
