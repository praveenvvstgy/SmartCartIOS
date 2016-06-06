//
//  ProductDetailViewController.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 6/6/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import Siesta
import ChameleonFramework

class ProductDetailViewController: UIViewController {
    @IBOutlet weak var productImage: RemoteImageView!
    @IBOutlet weak var productTable: UITableView!
    var product: BaseItem?
    
    var aisleInfo = [String]()
    
    override func viewDidLoad() {
        productTable.dataSource = self
        productTable.delegate = self
        productTable.rowHeight = UITableViewAutomaticDimension
        
        if let mediumImage = product?.mediumImage {
            productImage.imageURL = mediumImage
        } else if let thumbnailImage = product?.thumbnailImage {
            productImage.imageURL = thumbnailImage
        }
        
        let closeButton = view.viewWithTag(10) as! UIButton
        closeButton.addTarget(self, action: #selector(closeViewController), forControlEvents: .TouchUpInside)
        
        if let category = product?.categoryPath {
            aisleInfo = category.componentsSeparatedByString("/")
        }
        
    }
    
    func closeViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK: UITableViewDataSource
extension ProductDetailViewController: UITableViewDataSource {
   
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 4 {
            return 1
        } else if section == 4 {
            return aisleInfo.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Name"
        case 1:
            return "Sale Price"
        case 2:
            return "Details"
        case 3:
            return "Description"
        case 4:
            return "Aisle Map"
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 4 {
            return giveAisleCell(tableView, indexPath: indexPath)
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("titleCell") as! TitleCell!
        let section = indexPath.section
        switch section {
        case 0:
            if let name = product?.name {
                cell.title?.text = name
            }
        case 1:
            if let salePrice = product?.salePrice {
                cell.title?.text = "$ " + String(salePrice)
            }
        case 2:
            if let shortDescription = product?.shortDescription {
                cell.title.htmlText = shortDescription
                
            }
        case 3:
            if let longDescription = product?.longDescription {
                cell.title.htmlText = longDescription
            }
        case 4:
            break
        default:
            break
        }
        return cell
    }
    
    func giveAisleCell(tableView: UITableView, indexPath: NSIndexPath) -> AisleCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("aisleCell") as! AisleCell!
        cell.navigationImage.tintColor = RandomFlatColorWithShade(.Dark)
        if indexPath.row == 0 {
            cell.title.text = "Start from the StoreFront"
            cell.navigationImage.image = UIImage(named: "starter")
        } else if indexPath.row == 1 {
            cell.title.text = "Walk down to \(aisleInfo[indexPath.row - 1]) Aisle"
            cell.navigationImage.image = UIImage(named: "dots")
        } else if indexPath.row == aisleInfo.count {
            cell.title.text = "Find your product in the \(aisleInfo[indexPath.row - 1]) section"
            cell.navigationImage.image = UIImage(named: "marker")
        } else {
            cell.title.text = "Find the \(aisleInfo[indexPath.row - 1]) Section"
            cell.navigationImage.image = UIImage(named: "dots")
        }
        return cell
    }
    
}

extension ProductDetailViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let vw = view as! UITableViewHeaderFooterView
        vw.backgroundView?.backgroundColor = FlatWhite()
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}
