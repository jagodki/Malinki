//
//  MalinkiMapContentButton.swift
//  Malinki
//
//  Created by Christoph Jung on 21.10.21.
//

import SwiftUI

struct MalinkiMapContentButton: View {
    
    @Binding private var sheetState: MalinkiSheetState?
    
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
                .font(.title)
        }
    }
    
}

struct MalinkiMapContentButton_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapContentButton(sheetState: .constant(.layers))
    }
}
