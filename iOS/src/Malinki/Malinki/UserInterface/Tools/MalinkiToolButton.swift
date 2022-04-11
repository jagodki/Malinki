//
//  MalinkiToolButton.swift
//  Malinki
//
//  Created by Christoph Jung on 07.04.22.
//

import SwiftUI

struct MalinkiToolButton: View {
    
    @Binding var sheetState: MalinkiSheetState?
    
    var body: some View {
        Menu {
            Button(action: {
                self.sheetState = .search
            }) {
                Text(LocalizedStringKey("Search"))
                Image(systemName: "magnifyingglass")
            }
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
