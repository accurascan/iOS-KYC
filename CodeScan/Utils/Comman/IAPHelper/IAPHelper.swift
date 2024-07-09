//
//  IAPHelper.swift
//  Ballegro Player
//
//  Created by pushp on 8/24/17.
//  Copyright © 2017 azilen. All rights reserved.
//

import Foundation
import StoreKit


class IAPHelper:NSObject {

    static let shared = IAPHelper()
    
    var options: [Subscription]?
    
    var dataCompletionHandler: ((Bool, Error? ,[Subscription]?) -> Void)?
    var purchaseCompletionHandler: ((Bool, String? ,[Subscription]?) -> Void)?
    
    //------------------------------------------------------
    
    //MARK: - Set Product Detail
    
    //------------------------------------------------------
    
    func setProducIds() -> Set<String>{
//        let grandMonthly = "com.BallegroPlayer.grandAllegroMonthly"
//        let petitMonthly = "com.BallegroPlayer.petitAllegroMonthly"
//        let grandYearly = "com.BallegroPlayer.grandAllegroYearly"
//        let petitYearly = "com.BallegroPlayer.petitAllegroYearly"
          let petitMonthly = "com.keyoflife.dev"
        return Set([petitMonthly])
    }
    
    //------------------------------------------------------
    
    //MARK: - Load Subscription
    
    //------------------------------------------------------
    
    func loadSubscriptionOptions(onCompletion completionHandler:((Bool, Error? ,[Subscription]?) -> Void)? = nil) {
        let productIDs = setProducIds()
        dataCompletionHandler = completionHandler
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    //------------------------------------------------------
    
    //MARK: - Load Reciept
    
    //------------------------------------------------------
    
     func loadReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
    
    //------------------------------------------------------
    
    //MARK: - Purchase and Restore
    
    //------------------------------------------------------
    
    func purchase(subscription: Subscription,completion: ((Bool, String? ,[Subscription]?) -> Void)? = nil) {
        let payment = SKPayment(product: subscription.product)
        purchaseCompletionHandler = completion
        SKPaymentQueue.default().add(payment)
        SKPaymentQueue.default().add(self)
    }
    
    func restorePurchases(completion: ((Bool, String? ,[Subscription]?) -> Void)? = nil) {
        purchaseCompletionHandler = completion
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension IAPHelper: SKProductsRequestDelegate {

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        var products = [SKProduct]()
        var product: SKProduct?
        print(response.products)
        var item = response.products
        
        if item.count != 0
        {
            for i in 0..<item.count
            {
                product = item[i] as SKProduct
                products.append(product!)
            }
        }
        
        print("There are \(products.count) items to buy.")
        options = response.products.map
        {
            Subscription(product: $0)
            
        }
        dataCompletionHandler?(true,nil,options)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        dataCompletionHandler?(false,error,options)
    }
}

// MARK: - SKPaymentTransactionObserver

extension IAPHelper: SKPaymentTransactionObserver
{
    
    func paymentQueue(_ queue: SKPaymentQueue,
                      updatedTransactions transactions: [SKPaymentTransaction]) {
        
        if transactions.count > 0 {
            let transaction =  transactions.last!
            //        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased:
                handlePurchasedState(for: transaction, in: queue)
            case .restored:
                handleRestoredState(for: transaction, in: queue)
            case .failed:
                handleFailedState(for: transaction, in: queue)
            case .deferred:
                handleDeferredState(for: transaction, in: queue)
            }
        } else {
            purchaseCompletionHandler?(false,"You haven't subscribed",nil)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("failed")
    }
    
    func handlePurchasingState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User is attempting to purchase product id: \(transaction.payment.productIdentifier)")
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User purchased product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
        SKPaymentQueue.default().remove(self)
        purchaseCompletionHandler?(true,"Purchase Successfully",nil)
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
        SKPaymentQueue.default().remove(self)
        purchaseCompletionHandler?(true,"Purchase restored Successfully",nil)
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        queue.finishTransaction(transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
        SKPaymentQueue.default().remove(self)
        purchaseCompletionHandler?(false,"Purchase failed",nil)
        print("Purchase failed for product id: \(transaction.payment.productIdentifier)")
    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
    }
}


private var formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.formatterBehavior = .behavior10_4
    return formatter
}()

struct Subscription
{
    let product: SKProduct
    let formattedPrice: String
    
    init(product: SKProduct) {
        self.product = product
        
        if formatter.locale != self.product.priceLocale {
            formatter.locale = self.product.priceLocale
        }
        
        formattedPrice = formatter.string(from: product.price) ?? "\(product.price)"
    }
}
