//
//  SearchViewController.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 6/3/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import ChameleonFramework
import Siesta
import DZNEmptyDataSet

class SearchViewController: UIViewController {

    @IBOutlet weak var searchResultsTableView: UITableView!
    let searchStatusOverlay = ResourceStatusOverlay()
    
    var searchResults = [BaseItem]() {
        didSet {
            searchResultsTableView.reloadData()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.emptyDataSetSource = self
        
        initializeSearchBar()
        
        searchResultsTableView.rowHeight = UITableViewAutomaticDimension
        
        searchStatusOverlay.embedIn(self)
        
        if let activityIndicator = searchStatusOverlay.loadingIndicator as? UIActivityIndicatorView {
            activityIndicator.color = contrastColorForBackground()
        }
    }
    
    override func viewDidLayoutSubviews() {
        searchStatusOverlay.positionToCover(searchResultsTableView)
    }
    
    func initializeSearchBar() {
        searchBar.barTintColor = UIColor.flatTealColor()
        searchBar.tintColor = UIColor.flatLimeColor()
        searchBar.placeholder = "Search Products"
        searchBar.delegate = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchBar.endEditing(true)
    }
    
    func contrastColorForBackground() -> UIColor {
        return ContrastColorOf(FlatWatermelonDark(), returnFlat: true)
    }
}

// MARK: UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell") as! SearchTableCell
        let product = searchResults[indexPath.row]
        if let name = product.name {
            cell.name.text = name
        }
        if let salePrice = product.salePrice {
            cell.salePrice.text = "  $"  + String(salePrice) + "  "
            cell.salePrice.textColor = RandomFlatColorWithShade(.Dark)
            cell.addToCartButton.addTarget(self, action: #selector(addToListTapped), forControlEvents: .TouchUpInside)
        }
        if let thumbnailImageURL = product.thumbnailImage {
            cell.thumbnail.imageURL = thumbnailImageURL
        }
        if let itemId = product.itemId {
            cell.addToCartButton.tag = itemId
            if shoppingList.isProductInList(itemId) {
                cell.addToCartButton.tintColor = FlatTeal()
            } else {
                cell.addToCartButton.tintColor = FlatWhiteDark()
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 118
    }
    
    func addToListTapped(sender: UIButton) {
        if shoppingList.isProductInList(sender.tag) {
            return
        }
        if let product = productsCache.products[sender.tag] {
            shoppingList.addItemToShoppingList(product)
        } else {
            return
        }
        sender.transform = CGAffineTransformMakeScale(0, 0)
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .CurveLinear, animations: { 
            sender.transform = CGAffineTransformIdentity
            sender.tintColor = FlatTeal()
            }, completion: nil)
    }
}

// MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}

// MARK: UISearchResultsUpdating
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            walmartAPI.search(searchText)
                .addObserver(self)
                .addObserver(searchStatusOverlay, owner: self)
                .loadIfNeeded()
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
}

//MARK: ResourceObserver
extension SearchViewController: ResourceObserver {
    func resourceChanged(resource: Resource, event: ResourceEvent) {
        searchResults = resource.typedContent() ?? [BaseItem]()
        if let products: [BaseItem] = resource.typedContent() {
            productsCache.addProductsToCache(products)
        }
    }
}

//MARK: DZNEmptyDataSetSource
extension SearchViewController: DZNEmptyDataSetSource {
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "search-big")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSForegroundColorAttributeName: contrastColorForBackground()]
        return NSAttributedString(string: "Search Products", attributes: attributes)
    }
    
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSForegroundColorAttributeName: contrastColorForBackground()]
        return NSAttributedString(string: "Search Products and to your Shopping List", attributes: attributes)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return FlatTeal()
    }
    
    func imageTintColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return contrastColorForBackground()
    }
    
}
