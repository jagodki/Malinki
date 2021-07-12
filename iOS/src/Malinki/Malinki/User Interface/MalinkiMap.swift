//
//  MalinkiMap.swift
//  Malinki
//
//  Created by Christoph Jung on 07.07.21.
//

import SwiftUI

struct MalinkiMap: View {
    var body: some View {
        GeometryReader { geo in
            
            ZStack {
                //the map view
                MalinkiMapView(scaleXPosition: 75, compassXPosition: 15, scaleCompassYPosition: Int(geo.size.height * 0.075))
                    .edgesIgnoringSafeArea(.all)
                
                //controls will overlay the map view
                VStack {
                    
                    //some buttons at the top
                    HStack {
                        Spacer()
                        MalinkiButtonGroup()
                    }
                    
                    Spacer()
                    
                }
            }
            
        }
        
    }
}

struct MalinkiMap_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMap()
    }
}
