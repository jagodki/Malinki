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
    @State private var showMapContentSheet: Bool = false
    @State private var basemapID: Int = MalinkiConfigurationProvider.sharedInstance.getIDOfBasemapOnStartUp()
    @State private var mapThemeID: Int = MalinkiConfigurationProvider.sharedInstance.getIDOfMapThemeOnStartUp()
    @State private var mapLayers: [MalinkiMapLayer] = MalinkiConfigurationProvider.sharedInstance.getMapLayers(of: MalinkiConfigurationProvider.sharedInstance.getIDOfMapThemeOnStartUp())
    
    private var isSheetOpen: Bool {
        return self.showMapContentSheet == true || self.showBasemapsSheet == true
    }
    
    @available(iOS 15.0, *)
    var body: some View {
        
        ZStack {
            MalinkiMapView(basemapID: self.$basemapID, mapThemeID: self.$mapThemeID, mapLayers: self.$mapLayers)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack {
                        MalinkiMapThemes(mapThemeID: self.$mapThemeID, mapLayers: self.$mapLayers, showBasemapsSheet: self.$showBasemapsSheet)
                            .frame(width: 50, height: 40, alignment: .center)
                            .padding(.top, 10.0)
                        
                        Divider()
                            .frame(width: 50, height: 10, alignment: .center)
                        
                        MalinkiMapContentButton(showMapContentSheet: self.$showMapContentSheet)
                            .frame(width: 50, height: 40, alignment: .center)
                            .padding(.bottom, 10.0)
                    }
                    .background(Color(UIColor.systemGray4).opacity(0.75))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .padding()
                }
                
            }
        }.background(EmptyView().adaptiveSheet(isPresented: self.$showBasemapsSheet, detents: [.medium(), .large()], smallestUndimmedDetentIdentifier: .medium, prefersScrollingExpandsWhenScrolledToEdge: false) {
            MalinkiBasemaps(basemapID: self.$basemapID, showBasemapsSheet: self.$showBasemapsSheet)
                .padding()
        }.background(EmptyView().adaptiveSheet(isPresented: self.$showMapContentSheet, detents: [.medium(), .large()], smallestUndimmedDetentIdentifier: .medium, prefersScrollingExpandsWhenScrolledToEdge: false) {
            MalinkiMapContent(mapLayers: self.$mapLayers, showMapContentSheet: self.$showMapContentSheet)
        }))
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
