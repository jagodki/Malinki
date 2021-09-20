//
//  MalinkiMapControl.swift
//  Malinki
//
//  Created by Christoph Jung on 30.06.21.
//

import SwiftUI

struct MalinkiMapControl: View {
    
    private var mapThemeID: Int
    
    init(mapThemeID: Int) {
        self.mapThemeID = mapThemeID
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                
            }
        }
    }
    
}

struct MalinkiMapControl_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapControl(mapThemeID: 0)
    }
}
