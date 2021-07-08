//
//  MalinkiMap.swift
//  Malinki
//
//  Created by Christoph Jung on 07.07.21.
//

import SwiftUI

struct MalinkiMap: View {
    var body: some View {
        ZStack {
            //the map view
            MalinkiMapView()
                .edgesIgnoringSafeArea(.all)
            
            //controls will overlay the map view
            VStack {
                
                //some buttons at the top
                HStack {
                    Spacer()
                    MalinkiButtonGroup()
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
