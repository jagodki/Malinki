//
//  MalinkiStoreManager.swift
//  Malinki
//
//  Created by Christoph Jung on 08.08.22.
//

import Foundation
import StoreKit

/// This class manages the in-app purchases using StoreKit.
class MalinkiStoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @Published var myProducts = [SKProduct]()
    @Published var transactionState: SKPaymentTransactionState?
    
    var request: SKProductsRequest!
    
    //MARK: - mandatory functions
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        //check if the response contains products
        if !response.products.isEmpty {
            
            //add any of these products to our array
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.myProducts.append(fetchedProduct)
                }
            }
        }
        
        //check for invalid prodcuts, i.e. with unknown IDs
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("ERROR - Invalid identifiers found in products: \(invalidIdentifier)")
        }
    }
    
    func getProducts(productIDs: [String]) {
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("ERROR - Request for products did fail: \(error)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                self.setUserStateBool(key: MalinkiConfigurationProvider.sharedInstance.getInAppPurchasesConfig().mapToolsProductID, value: true)
                queue.finishTransaction(transaction)
                transactionState = .purchased
            case .restored:
                self.setUserStateBool(key: MalinkiConfigurationProvider.sharedInstance.getInAppPurchasesConfig().mapToolsProductID, value: true)
                queue.finishTransaction(transaction)
                transactionState = .restored
            case .failed, .deferred:
                print("ERROR - Payment Queue: \(String(describing: transaction.error))")
                queue.finishTransaction(transaction)
                transactionState = .failed
            @unknown default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("ERROR - User cannot make payment.")
        }
    }
    
    func restoreProducts() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    //MARK: - additional functions
    
    /// This function sets the user state for a boolean value.
    /// - Parameters:
    ///   - key: the key of the user state
    ///   - value: the value of the user state as bool
    private func setUserStateBool(key: String, value: Bool) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
}
