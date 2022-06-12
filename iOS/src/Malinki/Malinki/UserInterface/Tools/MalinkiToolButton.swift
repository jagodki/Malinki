//
//  MalinkiToolButton.swift
//  Malinki
//
//  Created by Christoph Jung on 07.04.22.
//

import SwiftUI

/// A structur to show a menu button with several tools available.
struct MalinkiToolButton: View {
    
    @Binding var sheetState: MalinkiSheetState?
    
    var body: some View {
        Menu {
            //the search entry
            Button(action: {
                self.sheetState = .search
            }) {
                Text(LocalizedStringKey("Search"))
                Image(systemName: "magnifyingglass")
            }
            
            //the bookmarks entry
            Button(action: {
                self.sheetState = .bookmarks
            }) {
                Text(LocalizedStringKey("Bookmarks"))
                Image(systemName: "bookmark.fill")
            }
            
            //the clean cache entry
        } label: {
            Image(systemName: "ellipsis")
                .font(.title2)
                .foregroundColor(Color.primary)
                .padding()
        }
    }
}

struct MalinkiToolButton_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiToolButton(sheetState: .constant(.search))
    }
}
