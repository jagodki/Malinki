//
//  MalinkiMapContentButton.swift
//  Malinki
//
//  Created by Christoph Jung on 21.10.21.
//

import SwiftUI

struct MalinkiMapContentButton: View {
    
    @Binding private var showMapContentSheet: Bool
    
    init(showMapContentSheet: Binding<Bool>) {
        self._showMapContentSheet = showMapContentSheet
    }
    
    var body: some View {
        
        Button(action: {self.showMapContentSheet = true}) {
            Image(systemName: "list.bullet")
                .padding(.all, 10.0)
                .foregroundColor(Color.primary)
            //            .background(Color(UIColor.systemGray3).opacity(0.75))
                .font(.title)
            //            .cornerRadius(10)
        }
    }
    
}

struct MalinkiMapContentButton_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapContentButton(showMapContentSheet: .constant(false))
    }
}
