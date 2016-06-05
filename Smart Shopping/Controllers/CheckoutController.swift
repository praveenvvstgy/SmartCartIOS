//
//  CheckoutController.swift
//  Smart Shopping
//
//  Created by Gowda I V, Praveen on 6/5/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import Braintree
import Firebase

class CheckoutController: UIViewController {
    var brainTreeClient = BTAPIClient(authorization: "sandbox_835825p8_xtdbw4bg9p6czs9p")
    
    override func viewDidLoad() {
        
    }
    
    func userDidCancelPayment() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func payWithPaypalClicked() {
        let dropInViewController = BTDropInViewController(APIClient: brainTreeClient!)
        dropInViewController.delegate = self
        
        dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(userDidCancelPayment))
        
        navigationController?.presentViewController(dropInViewController, animated: true, completion: nil)
        
    }
    
    func completeCheckout() {
        smartCart.items.removeAll()
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("carts").child("cart1").child("contents").setValue([])
        databaseRef.child("carts").child("cart1").child("activeUser").setValue(["default": true])
        dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK: BTDropInViewController
extension CheckoutController: BTDropInViewControllerDelegate {
    func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        dismissViewControllerAnimated(true, completion: completeCheckout)
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
