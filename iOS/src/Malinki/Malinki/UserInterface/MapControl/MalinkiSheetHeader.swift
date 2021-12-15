//
//  MalinkiSheetHeader.swift
//  Malinki
//
//  Created by Christoph Jung on 15.12.21.
//

import SwiftUI

struct MalinkiSheetHeader: View {
    
    @Binding private var isSheetShowing: Bool
    private var title: String
    
    init(title: String, isSheetShowing: Binding<Bool>) {
        self.title = title
        self._isSheetShowing = isSheetShowing
    }
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey(self.title))
                .font(.headline)
                .padding(.leading)
            
            Spacer()
            
            Button(action: {
                self.isSheetShowing = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .padding(.trailing)
                    .foregroundColor(Color.secondary)
                    .font(.headline)
            }
        }
    }
}

struct MalinkiSheetHeader_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiSheetHeader(title: "Test", isSheetShowing: .constant(true))
    }
}
