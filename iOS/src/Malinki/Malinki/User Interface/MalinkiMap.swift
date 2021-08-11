//
//  MalinkiMap.swift
//  Malinki
//
//  Created by Christoph Jung on 07.07.21.
//

import SwiftUI
import BottomSheet

struct MalinkiMap: View {
    
    @State private var bottomSheetPosition: BottomSheetPosition = .bottom
    @State private var searchText: String = ""
    @State private var isEditing = false
    
    var body: some View {
        GeometryReader { geo in
            //the map view
            MalinkiMapView(scaleXPosition: 75, compassXPosition: 15, scaleCompassYPosition: Int(geo.size.height * 0.075))
                .edgesIgnoringSafeArea(.all)
                .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition,
                             //options: [],
                             options: [.appleScrollBehavior],
                             headerContent: {
                                MalinkiSearchBar(bottomSheetPosition: self.$bottomSheetPosition, searchText: self.$searchText, isEditing: self.$isEditing)
                             }){
                    VStack {
                        Text("Content", comment: "Test Content")
                        MalinkiBaseMaps()
                            .padding()
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
