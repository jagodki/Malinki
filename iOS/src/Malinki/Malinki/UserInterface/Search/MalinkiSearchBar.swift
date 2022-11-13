//
//  MalinkiSearchBar.swift
//  Malinki
//
//  Created by Christoph Jung on 26.07.21.
//

import SwiftUI

/// A structure to present a SearchBar written in pure SwiftUI for integration into a BottomSheet.
@available(iOS 15.0, *)
struct MalinkiSearchBar: View {
    
    @Binding private var searchText: String
    @Binding private var isEditing: Bool
    @Binding private var sheetDetent: UISheetPresentationController.Detent.Identifier?
    
    /// The initialiser of the struct.
    /// - Parameters:
    ///   - bottomSheetPosition: a binding to the position of the BottomSheet where the SearchBar is located in
    ///   - searchText: a binding to the text presented in the SearchBar
    ///   - isEditing: a binding to a Bool, if the SearchBar is in editing mode
    init(searchText: Binding<String>, isEditing: Binding<Bool>, sheetDetent: Binding<UISheetPresentationController.Detent.Identifier?>) {
        self._searchText = searchText
        self._isEditing = isEditing
        self._sheetDetent = sheetDetent
    }
    
    var showCancelButton: Bool {
        var result = false
        
        if self.isEditing && self.sheetDetent == .large {
            result = true
        } else if self.sheetDetent == .medium {
            DispatchQueue.main.async { self.isEditing = false }
        }
        
        return result
    }
    
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField(String(localized: "Search for Map Themes and Content"), text: self.$searchText).foregroundColor(.primary)

                if self.searchText != "" {
                    Button(action: {
                        self.searchText = ""
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
            .foregroundColor(Color(UIColor.secondaryLabel))
            .padding(.vertical, 8)
            .padding(.horizontal, 5)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.secondarySystemFill)))
            .padding(.bottom)
            //When you tap the SearchBar, the BottomSheet moves to the .top position to make space for the keyboard.
            .onTapGesture {
                self.isEditing = true
                self.sheetDetent = .large
            }

            if self.showCancelButton {
                Button(action: {
                    withAnimation {
                        self.searchText = ""
                        self.isEditing = false
                        self.sheetDetent = .medium
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }

                }) {
                    Text(LocalizedStringKey("Cancel"))
                }
                .foregroundColor(.accentColor)
                .padding(.horizontal, 5)
                .padding(.bottom)
                .transition(.move(edge: .trailing))
                .animation(.default, value: self.showCancelButton)
            }
        }
    }
}

@available(iOS 15.0, *)
struct MalinkiSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiSearchBar(searchText: .constant(""), isEditing: .constant(true), sheetDetent: .constant(UISheetPresentationController.Detent.Identifier.large))
    }
}
