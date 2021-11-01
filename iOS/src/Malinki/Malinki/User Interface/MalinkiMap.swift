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
    
    @State private var searchText: String = ""
    @State private var isEditing: Bool = false
    @State private var basemapID: Int = MalinkiConfigurationProvider.sharedInstance.getIDOfBasemapOnStartUp()
    @State private var mapThemeID: Int = MalinkiConfigurationProvider.sharedInstance.getIDOfMapThemeOnStartUp()
    @StateObject var mapLayers: MalinkiLayerContainer = MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray())
    @ObservedObject var sheet: MalinkiSheet = MalinkiSheet()
    
    @available(iOS 15.0, *)
    var body: some View {
        
        ZStack {
            MalinkiMapView(basemapID: self.$basemapID, mapThemeID: self.$mapThemeID)
                .environmentObject(self.mapLayers)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack {
                        MalinkiMapThemes(mapThemeID: self.$mapThemeID, sheetState: self.$sheet.state)
                            .frame(width: 50, height: 40, alignment: .center)
                            .padding(.top, 10.0)
                        
                        Divider()
                            .frame(width: 50, height: 10, alignment: .center)
                        
                        MalinkiMapContentButton(sheetState: self.$sheet.state)
                            .frame(width: 50, height: 40, alignment: .center)
                            .padding(.bottom, 10.0)
                    }
                    .background(.regularMaterial)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .padding()
                }
                
            }
        }
        .sheet(isPresented: self.$sheet.isShowing, onDismiss: {self.sheet.state = nil}, content: {self.sheetContent()})
//        .adaptiveSheet(isPresented: self.$sheet.isShowing, detents: [.medium(), .large()], smallestUndimmedDetentIdentifier: .medium, prefersScrollingExpandsWhenScrolledToEdge: false) {
//            self.sheetContent()
//        }
//        .background(EmptyView().adaptiveSheet(isPresented: self.$sheet.isShowing, detents: [.medium(), .large()], smallestUndimmedDetentIdentifier: .medium, prefersScrollingExpandsWhenScrolledToEdge: false) {
//            self.sheetContent()
//        })
    }
    
    @ViewBuilder
    private func sheetContent() -> some View {
        switch self.sheet.state {
        case .basemaps:
            MalinkiBasemaps(basemapID: self.$basemapID, sheetState: self.$sheet.state)
                .environmentObject(self.mapLayers)
        case .layers:
            MalinkiMapContent(sheetState: self.$sheet.state, mapThemeID: self.$mapThemeID)
                .environmentObject(self.mapLayers)
        case .details:
            EmptyView()
        default:
            EmptyView()
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
