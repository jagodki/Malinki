//
//  MalinkiMapContentButton.swift
//  Malinki
//
//  Created by Christoph Jung on 21.10.21.
//

import SwiftUI

/// A structure with a button to show all layers/the map content.
struct MalinkiMapContentButton: View {
    
    @Binding private var sheetState: MalinkiSheetState?
    
    /// The initialiser of the struct.
    /// - Parameter sheetState: a binding of the sheet state
    init(sheetState: Binding<MalinkiSheetState?>) {
        self._sheetState = sheetState
    }
    
    var body: some View {
        
        Button(action: {
            self.sheetState = .layers
        }) {
            Image(systemName: "list.bullet")
                .font(.title2)
                .foregroundColor(Color.primary)
                .padding()
        }
    }
    
}

struct MalinkiMapContentButton_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapContentButton(sheetState: .constant(.layers))
    }
}
