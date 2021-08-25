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
    @State private var isEditing: Bool = false
    @State private var basemapID: Int = MalinkiConfigurationProvider.sharedInstance.configData?.basemaps.filter({$0.onStartUp == true}).first?.id ?? 0
    
    var body: some View {
        GeometryReader { geo in
            //the map view
            MalinkiMapView()
                .edgesIgnoringSafeArea(.all)
                .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition,
                             //options: [],
                             options: [.appleScrollBehavior],
                             headerContent: {
                                MalinkiSearchBar(bottomSheetPosition: self.$bottomSheetPosition, searchText: self.$searchText, isEditing: self.$isEditing)
                             }){
                    VStack {
                        Text("Content", comment: "Test Content")
                        MalinkiBasemaps(basemapID: self.$basemapID)
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
