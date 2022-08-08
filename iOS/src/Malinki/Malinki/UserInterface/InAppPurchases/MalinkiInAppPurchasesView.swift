//
//  MalinkiInAppPurchasesView.swift
//  Malinki
//
//  Created by Christoph Jung on 01.08.22.
//

import SwiftUI
import SheeKit

@available(iOS 15.0, *)
struct MalinkiInAppPurchasesView: View {
    
    @Binding private var sheetState: UISheetPresentationController.Detent.Identifier?
    @Binding private var isSheetShowing: Bool
    
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
                Text("Test")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: {
                        ToolbarItem(placement: .principal, content: {
                            MalinkiSheetHeader(title: String(localized: "In-App Purchases"), isSheetShowing: self.$isSheetShowing, sheetDetent: self.$sheetState, subtitle: "")
                        })
                    })
            }
            Spacer()
            Button(action: {
                print("test")
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
    }
}

@available(iOS 15.0, *)
struct MalinkiInAppPurchasesView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiInAppPurchasesView(sheetState: .constant(UISheetPresentationController.Detent.Identifier.medium), isSheetShowing: .constant(true))
    }
}
