//
//  MalinkiUserAnnotationsView.swift
//  Malinki
//
//  Created by Christoph Jung on 23.06.22.
//

import SwiftUI
import MapKit
import SheeKit

@available(iOS 15.0.0, *)
struct MalinkiUserAnnotationsView: View {
    
    @EnvironmentObject var userAnnotationsContainer: MalinkiUserAnnotationsProvider
    @EnvironmentObject var mapLayers: MalinkiLayerContainer
    @EnvironmentObject var mapRegion: MalinkiMapRegion
    
    @Binding private var sheetState: UISheetPresentationController.Detent.Identifier?
    @Binding private var isSheetShowing: Bool
    
    private var config = MalinkiConfigurationProvider.sharedInstance
    
    @State private var actionType: AlertActionType = .insertMapPin
    @State private var uuidString: String = ""
    @State private var showAlert: Bool = false
    
    init(sheetState: Binding<UISheetPresentationController.Detent.Identifier?>, isSheetShowing: Binding<Bool>) {
        self._sheetState = sheetState
        self._isSheetShowing = isSheetShowing
    }
    
    var body: some View {
        ZStack {
            AlertControlView(showAlert: self.$showAlert, title: String(localized: "Map Pin Name"), message: String(localized: "Insert the name of the map pin."), actionType: self.actionType, uuidString: self.uuidString)
            
            VStack {
                NavigationView {
                    List(self.userAnnotationsContainer.userAnnotations, id: \.id) {annotation in
                        Button(action: {
                            if annotation.theme_ids.first ?? -99 == self.mapLayers.selectedMapThemeID {
                                self.userAnnotationsContainer.selectedAnnotationID = annotation.id
                            }
                        }) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .padding()
                                    .foregroundColor(self.mapLayers.selectedMapThemeID == annotation.theme_ids.first ?? -99 ? Color.accentColor : Color.secondary)
                                VStack(alignment: .leading) {
                                    Text(annotation.name)
                                        .font(.headline)
                                        .foregroundColor(self.mapLayers.selectedMapThemeID == annotation.theme_ids.first ?? -99 ? Color.accentColor : Color.secondary)
                                    
                                    Text("\(self.config.getExternalThemeName(id: annotation.theme_ids.first ?? -99)) | Lat: \(String(format: "%.3f", annotation.position.latitude)), Lon: \(String(format: "%.3f", annotation.position.longitude))")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                }
                            }
                        }
                        .swipeActions(content: {
                            Button(action: {
                                //remove the annotation
                                if let index = self.userAnnotationsContainer.userAnnotations.firstIndex(where: {$0.id == annotation.id}) {
                                    _ = withAnimation() {
                                        self.userAnnotationsContainer.userAnnotations.remove(at: index)
                                    }
                                }
                            }, label: {
                                Label(String(localized: "Delete"), systemImage: "trash.fill")
                            }).tint(.red)
                        })
                        .swipeActions(content: {
                            Button(action: {
                                //update the annotation location
                                if let index = self.userAnnotationsContainer.userAnnotations.firstIndex(where: {$0.id == annotation.id}) {
                                    
                                    self.userAnnotationsContainer.userAnnotations[index] = MalinkiUserAnnotation (id: annotation.id, name: annotation.name, theme_ids: [self.mapLayers.selectedMapThemeID], position: MalinkiUserAnnotationsPosition(longitude: self.mapRegion.mapRegion.center.longitude,latitude: MalinkiCoordinatesConverter.sharedInstance.latitudeOverSheet(for: self.mapRegion.mapRegion.center.latitude, with: self.mapRegion.mapRegion.span.latitudeDelta)))
                                }
                            }, label: {
                                Label(String(localized: "Update"), systemImage: "arrow.triangle.2.circlepath")
                            }).tint(.purple)
                        })
                        .swipeActions(content: {
                            Button(action: {
                                //rename the annotation
                                self.actionType = .updateMapPin
                                self.uuidString = annotation.id
                                self.showAlert = true
                            }, label: {
                                Label(String(localized: "Rename"), systemImage: "pencil")
                            }).tint(.blue)
                        })
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: {
                        ToolbarItem(placement: .principal, content: {
                            MalinkiSheetHeader(title: String(localized: "Map Pins"), isSheetShowing: self.$isSheetShowing, sheetDetent: self.$sheetState)
                        })
                    })
                }
                Spacer()
                Button(action: {
                    self.actionType = .insertMapPin
                    self.showAlert = true
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus")
                        Text(String(localized: "Add Map Pin"))
                        Spacer()
                    }
                    .font(.headline)
                }
                .padding()
                .foregroundColor(Color(uiColor: .systemGray6))
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            }
            .background(Color(uiColor: .systemGray6))
            .ignoresSafeArea(.keyboard)
        }
    }
}

@available(iOS 15.0.0, *)
struct MalinkiUserAnnotationsView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiUserAnnotationsView(sheetState: .constant(.medium), isSheetShowing: .constant(false))
            .environmentObject(MalinkiUserAnnotationsProvider.sharedInstance)
            .environmentObject(MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray(), themes: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray().map({MalinkiTheme(themeID: $0.themeID)}), selectedMapThemeID: 0))
            .environmentObject(MalinkiMapRegion(mapRegion: MKCoordinateRegion()))
    }
}
