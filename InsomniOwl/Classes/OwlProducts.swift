//
//  OwlProducts.swift
//  InsomniOwl
//
//  Created by Brian on 2/16/19.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

public struct OwlProducts {
  
  static let productIDsNonConsumables: Set<ProductIdentifier> = [
    "com.vd.tutorial.iap.InsomniOwl.CarefreeOwl",
    "com.vd.tutorial.iap.InsomniOwl.GoodJobOwl",
    "com.vd.tutorial.iap.InsomniOwl.CouchOwn",
    "com.vd.tutorial.iap.InsomniOwl.NightOwl"
  ]
  static let randomProductID = "com.vd.tutorial.iap.InsomniOwl.RandomOwls"
  static let productIDsConsumables: Set<ProductIdentifier> = [randomProductID]
  
  static let productIDsNonRenewing: Set<ProductIdentifier> = [
    "com.vd.tutorial.iap.InsomniOwl.3MonthsOfBasic",
    "com.vd.tutorial.iap.InsomniOwl.6MonthsOfBasic"
  ]
  
  static let productIDsAutoRenewing: Set<ProductIdentifier> = [
    "com.vd.tutorial.iap.InsomniOwl.AutoRenew3Months",
    "com.vd.tutorial.iap.InsomniOwl.AutoRenew1Month"
  ]
  
  static let randomImages = [
    UIImage(named: "CarefreeOwl"),
    UIImage(named: "GoodJobOwl"),
    UIImage(named: "CouchOwl"),
    UIImage(named: "NightOwl")
  ]
  
  public static func resourceName(for productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
  }
  
  public static func setRandomProduct(with paidUp: Bool) {
    if paidUp {
      KeychainWrapper.standard.set(true, forKey: OwlProducts.randomProductID)
      store.purchasedProducts.insert(OwlProducts.randomProductID)
    } else {
      KeychainWrapper.standard.set(false, forKey: OwlProducts.randomProductID)
      store.purchasedProducts.remove(OwlProducts.randomProductID)
    }
  }
  
  public static func daysRemaininOnSubscription() -> Int {
    if let expiryDate = UserSettings.shared.expirationDate {
      return Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day!
    }
    return 0
  }
  
  public static func getExpiryDateString() -> String {
    let remaining = daysRemaininOnSubscription()
    if remaining > 0, let expiryDate = UserSettings.shared.expirationDate {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd/MM/yyyy"
      return "Subscribed! \nExpires: \(dateFormatter.string(from:expiryDate)) (\(remaining) Days"
    }
    return "Not Subscribed"
  }
  
  public static func paidUp() -> Bool {
    var paidUp = false
    if OwlProducts.daysRemaininOnSubscription() > 0 {
      paidUp = true
    } else if UserSettings.shared.randomRemaining > 0 {
      paidUp = true
    }
    setRandomProduct(with: paidUp)
    return paidUp
  }
  
  private static func handleMonthlySubscription(months: Int) {
    UserSettings.shared.increaseRandomExpirationDate(by: months)
    setRandomProduct(with: true)
  }
  
  static let store = IAPHelper(productIDs: OwlProducts.productIDsConsumables.union(OwlProducts.productIDsNonConsumables).union(OwlProducts.productIDsNonRenewing).union(OwlProducts.productIDsAutoRenewing))
  
  static func handlePurchase(purchaseIdentifier: String) {
    if productIDsConsumables.contains(purchaseIdentifier) {
      UserSettings.shared.increaseRandomRemaining(by: 5)
      setRandomProduct(with: true)
    } else if productIDsNonRenewing.contains(purchaseIdentifier), purchaseIdentifier.contains("3Months") {
      handleMonthlySubscription(months: 3)
    } else if productIDsNonRenewing.contains(purchaseIdentifier), purchaseIdentifier.contains("6Months") {
      handleMonthlySubscription(months: 6)
    } else if productIDsNonConsumables.contains(purchaseIdentifier) {
      store.purchasedProducts.insert(purchaseIdentifier)
      KeychainWrapper.standard.set(true, forKey:purchaseIdentifier)
    }
  }
  
}
