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
    @State private var basemapID: Int = MalinkiConfigurationProvider.sharedInstance.getIDOfBasemapOnStartUp()
    @State private var mapThemeID: Int = MalinkiConfigurationProvider.sharedInstance.getIDOfMapThemeOnStartUp()
//    @State private var mapLayers: [MalinkiMapLayer: Bool] = MalinkiConfigurationProvider.sharedInstance.getMapLayers(of: MalinkiConfigurationProvider.sharedInstance.getIDOfMapThemeOnStartUp()).reduce(into: [:], {result, next in result[next] = true})
    @State private var mapLayers: [MalinkiMapLayer] = MalinkiConfigurationProvider.sharedInstance.getMapLayers(of: MalinkiConfigurationProvider.sharedInstance.getIDOfMapThemeOnStartUp())
    
    var body: some View {
        GeometryReader { geo in
            //the map view
            MalinkiMapView(basemapID: self.$basemapID, mapThemeID: self.$mapThemeID)
                .edgesIgnoringSafeArea(.all)
                .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition,
                             //options: [],
                             options: [.appleScrollBehavior],
                             headerContent: {
                                MalinkiSearchBar(bottomSheetPosition: self.$bottomSheetPosition, searchText: self.$searchText, isEditing: self.$isEditing)
                             }){
                    VStack {
                        Text("Themes", comment: "Test Themes")
                        MalinkiMapThemes(mapThemeID: self.$mapThemeID)
                        Text("Layers", comment: "Test Layers")
                        MalinkiMapContent(mapLayers: self.$mapLayers)
                        Text("Basemaps", comment: "Test Basemaps")
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
