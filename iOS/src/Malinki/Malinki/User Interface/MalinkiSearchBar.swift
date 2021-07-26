//
//  MalinkiSearchBar.swift
//  Malinki
//
//  Created by Christoph Jung on 26.07.21.
//

import SwiftUI
import BottomSheet

/// A structure to present a SearchBar written in pure SwiftUI for integration into a BottomSheet.
struct MalinkiSearchBar: View {
    
    @Binding private var bottomSheetPosition: BottomSheetPosition
    @Binding private var searchText: String
    @Binding private var isEditing: Bool
    
    /// The initialiser of the struct.
    /// - Parameters:
    ///   - bottomSheetPosition: a binding to the position of the BottomSheet where the SearchBar is located in
    ///   - searchText: a binding to the text presented in the SearchBar
    ///   - isEditing: a binding to a Bool, if the SearchBar is in editing mode
    init(bottomSheetPosition: Binding<BottomSheetPosition>, searchText: Binding<String>, isEditing: Binding<Bool>) {
        self._searchText = searchText
        self._bottomSheetPosition = bottomSheetPosition
        self._isEditing = isEditing
    }
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: self.$searchText).foregroundColor(.primary)

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
            //When you tap the SearchBar, the BottomSheet moves to the .top position to make room for the keyboard.
            .onTapGesture {
                self.bottomSheetPosition = .top
                self.isEditing = true
            }

            if self.isEditing {
                Button(action: {
                    self.isEditing = false
                    self.searchText = ""
                    self.bottomSheetPosition = .middle
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)

                }) {
                    Text("Cancel")
                }
                .padding(.horizontal, 5)
                .padding(.bottom)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}

struct MalinkiSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiSearchBar(bottomSheetPosition: .constant(BottomSheetPosition.middle), searchText: .constant(""), isEditing: .constant(true))
    }
}
