//
//  MalinkiInAppPurchasesView.swift
//  Malinki
//
//  Created by Christoph Jung on 01.08.22.
//

import SwiftUI
import SheeKit
import StoreKit

@available(iOS 15.0, *)

/// This struct provides a view for the in-app purchases.
struct MalinkiInAppPurchasesView: View {
    
    @Binding private var sheetState: UISheetPresentationController.Detent.Identifier?
    @Binding private var isSheetShowing: Bool
    @StateObject var storeManager = MalinkiStoreManager()
    let productIDs: [String] = [MalinkiConfigurationProvider.sharedInstance.getInAppPurchasesConfig().mapToolsProductID]
    
    /// The initialiser of this struct.
    /// - Parameters:
    ///   - sheetState: the state of the sheet
    ///   - isSheetShowing: a boolean binding indicating, whether the sheet is open or closed
    init(sheetState: Binding<UISheetPresentationController.Detent.Identifier?>, isSheetShowing: Binding<Bool>) {
        self._sheetState = sheetState
        self._isSheetShowing = isSheetShowing
    }
    
    var body: some View {
        VStack {
            NavigationView {
                Form {
                    Section {
                        List(self.storeManager.myProducts, id: \.self) { product in
                            HStack {
                                Image(systemName: "wrench.and.screwdriver.fill")
                                VStack(alignment: .leading) {
                                    Text(product.localizedTitle)
                                        .font(.headline)
                                    Text(product.localizedDescription)
                                        .font(.caption2)
                                }
                                Spacer()
                                if UserDefaults.standard.bool(forKey:  MalinkiConfigurationProvider.sharedInstance.getInAppPurchasesConfig().mapToolsProductID) {
                                    Text(String(localized: "Purchased"))
                                        .foregroundColor(.green)
                                } else {
                                    Button(action: {
                                        //Purchase particular product
                                        self.storeManager.purchaseProduct(product: product)
                                    }) {
                                        Text("\(product.price) \(product.priceLocale.currencySymbol ?? "")")
                                    }
                                    .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                    if MalinkiConfigurationProvider.sharedInstance.hasSupportText() {
                        Section(header: HStack{
                            Image(systemName: "heart.fill")
                            Text(String(localized: "Support for the development"))
                                .font(.caption2)
                        }) {
                            Text(MalinkiConfigurationProvider.sharedInstance.getSupportText())
                                .font(.caption)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .principal, content: {
                        MalinkiSheetHeader(title: String(localized: "In-App Purchases"), isSheetShowing: self.$isSheetShowing, sheetDetent: self.$sheetState, subtitle: "")
                    })
                })
            }
            Spacer()
            Button(action: {
                self.storeManager.restoreProducts()
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "creditcard")
                    Text(String(localized: "Restore Purchases"))
                    Spacer()
                }
                .font(.headline)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor, lineWidth: 2)
            )
            .padding()
        }
        .background(Color(uiColor: .systemGray6))
        .onAppear(perform: {
            self.storeManager.getProducts(productIDs: self.productIDs)
            SKPaymentQueue.default().add(self.storeManager)
        })
    }
}

@available(iOS 15.0, *)
struct MalinkiInAppPurchasesView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiInAppPurchasesView(sheetState: .constant(UISheetPresentationController.Detent.Identifier.medium), isSheetShowing: .constant(true))
    }
}
