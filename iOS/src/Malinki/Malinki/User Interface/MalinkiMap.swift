//
//  MalinkiMap.swift
//  Malinki
//
//  Created by Christoph Jung on 07.07.21.
//

import SwiftUI
//import BottomSheet

@available(iOS 15.0, *)
struct MalinkiMap: View {
    
    //    @State private var bottomSheetPosition: BottomSheetPosition = .bottom
    @State private var searchText: String = ""
    @State private var isEditing: Bool = false
    @State private var showBasemapsSheet: Bool = false
    @State private var basemapID: Int = MalinkiConfigurationProvider.sharedInstance.getIDOfBasemapOnStartUp()
    @State private var mapThemeID: Int = MalinkiConfigurationProvider.sharedInstance.getIDOfMapThemeOnStartUp()
    @State private var mapLayers: [MalinkiMapLayer] = MalinkiConfigurationProvider.sharedInstance.getMapLayers(of: MalinkiConfigurationProvider.sharedInstance.getIDOfMapThemeOnStartUp())
    
    @available(iOS 15.0, *)
    var body: some View {
        
        ZStack {
            MalinkiMapView(basemapID: self.$basemapID, mapThemeID: self.$mapThemeID, mapLayers: self.$mapLayers)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    MalinkiMapThemes(mapThemeID: self.$mapThemeID, mapLayers: self.$mapLayers, showBasemapsSheet: self.$showBasemapsSheet)
                        .padding()
                        .shadow(radius: 1)
                }
                
            }
        }.adaptiveSheet(isPresented: self.$showBasemapsSheet, detents: [.medium(), .large()], smallestUndimmedDetentIdentifier: .medium, prefersScrollingExpandsWhenScrolledToEdge: false) {
            MalinkiBasemaps(basemapID: self.$basemapID)
                .padding()
        }
    }
}

@available(iOS 15.0, *)
struct MalinkiMap_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MalinkiMap()
        }
    }
}
