//
//  MalinkiMap.swift
//  Malinki
//
//  Created by Christoph Jung on 07.07.21.
//

import SwiftUI
import SheeKit

@available(iOS 15.0, *)
struct MalinkiMap: View {
    
    @State private var searchText: String = ""
    @State private var isEditing: Bool = false
    @State private var basemapID: Int = MalinkiConfigurationProvider.sharedInstance.getIDOfBasemapOnStartUp()
    @State private var mapThemeID: Int = MalinkiConfigurationProvider.sharedInstance.getIDOfMapThemeOnStartUp()
    @StateObject var mapLayers: MalinkiLayerContainer = MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray(), themes: MalinkiConfigurationProvider.sharedInstance.getAllMapThemes())
    @StateObject private var sheet: MalinkiSheet = MalinkiSheet()
    
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
                            .frame(width: 40, height: 30, alignment: .center)
                            .padding(.top, 10.0)
                        
                        Divider()
                            .frame(width: 50, height: 10, alignment: .center)
                        
                        MalinkiMapContentButton(sheetState: self.$sheet.state)
                            .frame(width: 40, height: 30, alignment: .center)
                            .padding(.bottom, 10.0)
                    }
                    .background(.regularMaterial)
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .padding()
                }
                
            }
        }
        .shee(isPresented: self.$sheet.isShowing, presentationStyle: .formSheet(properties: SheetProperties(prefersEdgeAttachedInCompactHeight: true, prefersGrabberVisible: true, detents: [.medium(), .large()], largestUndimmedDetentIdentifier: .medium, prefersScrollingExpandsWhenScrolledToEdge: false)), content: {self.sheetContent()})
    }
    
    @ViewBuilder
    private func sheetContent() -> some View {
        switch self.sheet.state {
        case .basemaps:
            MalinkiBasemaps(basemapID: self.$basemapID, isSheetShowing: self.$sheet.isShowing)
                .environmentObject(self.mapLayers)
        case .layers:
            MalinkiMapContent(mapThemeID: self.$mapThemeID, isSheetShowing: self.$sheet.isShowing)
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
