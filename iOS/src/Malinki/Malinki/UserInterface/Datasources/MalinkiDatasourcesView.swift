//
//  MalinkiDatasourcesView.swift
//  Malinki
//
//  Created by Christoph Jung on 24.07.22.
//

import SwiftUI

@available(iOS 15.0, *)
struct MalinkiDatasourcesView: View {
    
    @StateObject private var datasources: MalinkiDatasourcesProvider = MalinkiDatasourcesProvider.sharedInstance
    @Binding private var isSheetShowing: Bool
    @Binding private var sheetDetent: UISheetPresentationController.Detent.Identifier?
    
    init(isSheetShowing: Binding<Bool>, sheetDetent: Binding<UISheetPresentationController.Detent.Identifier?>) {
        self._isSheetShowing = isSheetShowing
        self._sheetDetent = sheetDetent
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Spacer()
                        .frame(maxWidth: 10)
                    Text(self.datasources.datasourcesMarkDown)
                        .font(.caption)
                    Spacer()
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal, content: {
                    MalinkiSheetHeader(title: String(localized: "Datasource(s)"), isSheetShowing: self.$isSheetShowing, sheetDetent: self.$sheetDetent, subtitle: "")
                })
            })
        }
    }
}

@available(iOS 15.0, *)
struct MalinkiDatasourcesView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiDatasourcesView(isSheetShowing: .constant(true), sheetDetent: .constant(UISheetPresentationController.Detent.Identifier.medium))
    }
}
