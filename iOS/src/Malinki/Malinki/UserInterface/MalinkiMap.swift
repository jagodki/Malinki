//
//  MalinkiMap.swift
//  Malinki
//
//  Created by Christoph Jung on 07.07.21.
//

import SwiftUI
import SheeKit
import MapKit

@available(iOS 15.0, *)
struct MalinkiMap: View {
    
    @State private var searchText: String = ""
    @State private var isEditing: Bool = false
    @State private var basemapID: Int = MalinkiConfigurationProvider.sharedInstance.getIDOfBasemapOnStartUp()
    @State private var selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier? = UISheetPresentationController.Detent.Identifier.medium
    @State private var selectedTool: String? = nil
    
    @StateObject private var sheet: MalinkiSheet = MalinkiSheet()
    @StateObject private var features: MalinkiFeatureDataContainer = MalinkiFeatureDataContainer()
    @StateObject var mapLayers: MalinkiLayerContainer = MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray(),
                                                                              themes: MalinkiConfigurationProvider.sharedInstance.getAllMapThemes(),
                                                                              selectedMapThemeID: MalinkiConfigurationProvider.sharedInstance.getIDOfMapThemeOnStartUp())
    @StateObject private var bookmarks: MalinkiBookmarksProvider = MalinkiBookmarksProvider.sharedInstance
    @StateObject private var mapRegion: MalinkiMapRegion = MalinkiMapRegion(
        mapRegion:MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: MalinkiConfigurationProvider.sharedInstance.getInitialMapPosition().latitude,
                longitude: MalinkiConfigurationProvider.sharedInstance.getInitialMapPosition().longitude),
            latitudinalMeters: MalinkiConfigurationProvider.sharedInstance.getInitialMapPosition().latitudinalMeters,
            longitudinalMeters: MalinkiConfigurationProvider.sharedInstance.getInitialMapPosition().longitudinalMeters))
    @StateObject private var userAnnotations: MalinkiUserAnnotationsProvider = MalinkiUserAnnotationsProvider()
    
    var body: some View {
        
        ZStack {
            MalinkiMapView(basemapID: self.$basemapID, sheetState: self.$sheet.state)
                .environmentObject(self.mapLayers)
                .environmentObject(self.features)
                .environmentObject(self.mapLayers.annotations)
                .environmentObject(self.mapRegion)
                .environmentObject(self.userAnnotations)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                HStack {
                    VStack {
                        Spacer()
                            .frame(width: 10, height: 51, alignment: .center)
                        
                        MalinkiToolButton(sheetState: self.$sheet.state)
                            .frame(width: 30, height: 35, alignment: .center)
                            .padding(.all, 10.0)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                            .shadow(radius: 1)
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack {
                        MalinkiMapThemes(sheetState: self.$sheet.state)
                            .environmentObject(self.mapLayers)
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
        .ignoresSafeArea(.keyboard)
        .shee(isPresented: self.$sheet.isShowing, presentationStyle: .formSheet(properties: SheetProperties(prefersEdgeAttachedInCompactHeight: true, prefersGrabberVisible: true, detents: [.medium(), .large()], selectedDetentIdentifier: self.$selectedDetentIdentifier, largestUndimmedDetentIdentifier: .medium, prefersScrollingExpandsWhenScrolledToEdge: false)), content: {
            self.sheetContent()
            .background(Color(uiColor: .systemGray6).ignoresSafeArea(.all))
        })
    }
    
    @ViewBuilder
    private func sheetContent() -> some View {
        switch self.sheet.state {
        case .basemaps:
            MalinkiBasemaps(basemapID: self.$basemapID, isSheetShowing: self.$sheet.isShowing, sheetDetent: self.$selectedDetentIdentifier)
                .environmentObject(self.mapLayers)
        case .layers:
            MalinkiMapContent(isSheetShowing: self.$sheet.isShowing, sheetDetent: self.$selectedDetentIdentifier)
                .environmentObject(self.mapLayers)
        case .details:
            MalinkiObjectDetailsView(isSheetShowing: self.$sheet.isShowing, sheetDetent: self.$selectedDetentIdentifier)
                .environmentObject(self.features)
                .onDisappear(perform: {
                    self.mapLayers.allowRedraw = false
                    self.features.clearAll()
                    self.mapLayers.annotations.deselectAnnotations = true
                })
        case .search:
            MalinkiSearchView(searchText: self.$searchText, sheetDetent: self.$selectedDetentIdentifier, isSheetShowing: self.$sheet.isShowing, isEditing: self.$isEditing)
                .environmentObject(self.mapLayers)
        case .bookmarks:
            MalinkiBookmarksView(sheetState: self.$selectedDetentIdentifier, isSheetShowing: self.$sheet.isShowing, basemapID: self.$basemapID)
                .environmentObject(self.bookmarks)
                .environmentObject(self.mapLayers)
                .environmentObject(self.mapRegion)
        case .annotations:
            MalinkiUserAnnotationsView(sheetState: self.$selectedDetentIdentifier, isSheetShowing: self.$sheet.isShowing)
                .environmentObject(self.userAnnotations)
                .environmentObject(self.mapLayers)
                .environmentObject(self.mapRegion)
        case .datasources:
            MalinkiDatasourcesView(isSheetShowing: self.$sheet.isShowing, sheetDetent: self.$selectedDetentIdentifier)
        case .inapppurchase:
            MalinkiInAppPurchasesView(sheetState: self.$selectedDetentIdentifier, isSheetShowing: self.$sheet.isShowing)
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
