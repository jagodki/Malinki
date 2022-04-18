//
//  MalinkiSearchView.swift
//  Malinki
//
//  Created by Christoph Jung on 12.07.21.
//

import SwiftUI
import SheeKit

@available(iOS 15.0, *)
struct MalinkiSearchView: View {
    
    @Binding private var searchText: String
    @Binding private var sheetDetent: UISheetPresentationController.Detent.Identifier?
    @Binding private var isSheetShowing: Bool
    @Binding private var isEditing: Bool
    
    init(searchText: Binding<String>, sheetDetent: Binding<UISheetPresentationController.Detent.Identifier?>, isSheetShowing: Binding<Bool>, isEditing: Binding<Bool>) {
        self._searchText = searchText
        self._sheetDetent = sheetDetent
        self._isSheetShowing = isSheetShowing
        self._isEditing = isEditing
    }
    
    var body: some View {
        NavigationView {
            VStack {
                MalinkiSearchBar(searchText: self.$searchText, isEditing: self.$isEditing, sheetDetent: self.$sheetDetent)
                    .padding()
                Spacer()
                
                //show an information to the user, if no search string is inserted
                if self.searchText == "" {
                    Text(LocalizedStringKey("No search results..."))
                        .foregroundColor(.secondary)
                        .italic()
                    Spacer()
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal, content: {
                    MalinkiSheetHeader(title: "Search", isSheetShowing: self.$isSheetShowing, sheetDetent: self.$sheetDetent)
                })
            })
        }
    }
}

@available(iOS 15.0, *)
struct MalinkiSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiSearchView(searchText: .constant(""), sheetDetent: .constant(UISheetPresentationController.Detent.Identifier.large), isSheetShowing: .constant(true), isEditing: .constant(true))
    }
}
