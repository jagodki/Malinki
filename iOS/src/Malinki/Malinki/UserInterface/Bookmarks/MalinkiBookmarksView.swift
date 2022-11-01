//
//  MalinkiBookmarksView.swift
//  Malinki
//
//  Created by Christoph Jung on 11.05.22.
//

import SwiftUI
import SheeKit
import MapKit

@available(iOS 15.0.0, *)
/// A structur to show all bookmarks as buttons/list entries. Should be presented inside a sheet.
struct MalinkiBookmarksView: View {
    
    @EnvironmentObject var bookmarksContainer: MalinkiBookmarksProvider
    @EnvironmentObject var mapLayers: MalinkiLayerContainer
    @EnvironmentObject var mapRegion: MalinkiMapRegion
    
    @Binding private var sheetState: UISheetPresentationController.Detent.Identifier?
    @Binding private var isSheetShowing: Bool
    
    private var config = MalinkiConfigurationProvider.sharedInstance
    
    @State private var actionType: AlertActionType = .insertBookmark
    @State private var uuidString: String = ""
    @State private var showAlert: Bool = false
    
    /// The initialiser of this struct.
    /// - Parameters:
    ///   - sheetState: the state of the sheet
    ///   - isSheetShowing: a boolean binding indicating, whether the sheet is open or closed
    init(sheetState: Binding<UISheetPresentationController.Detent.Identifier?>, isSheetShowing: Binding<Bool>) {
        self._sheetState = sheetState
        self._isSheetShowing = isSheetShowing
    }
    
    var body: some View {
        
        ZStack {
            AlertControlView(showAlert: self.$showAlert, title: String(localized: "Bookmark Name"), message: String(localized: "Insert the bookmark name."), actionType: self.actionType, uuidString: self.uuidString)
            
            VStack {
                NavigationView {
                    VStack {
                        if self.bookmarksContainer.bookmarks.count == 0 {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text(LocalizedStringKey("no bookmarks saved..."))
                                        .foregroundColor(.secondary)
                                        .italic()
                                    Spacer()
                                }
                                Spacer()
                            }
                            .background(Color(uiColor: .systemGray6).ignoresSafeArea(.all))
                        } else {
                            
                            List(self.bookmarksContainer.bookmarks, id: \.id) {bookmark in
                                Button(action: {
                                    //adjust the map view
                                    self.mapLayers.selectedMapThemeID = bookmark.theme_id
                                    self.mapLayers.mapThemes.filter({$0.themeID == self.mapLayers.selectedMapThemeID}).first?.annotationsAreToggled = bookmark.show_annotations
                                    
                                    //toggle layers according to the bookmark
                                    _ = self.mapLayers.rasterLayers.filter({$0.themeID == bookmark.theme_id && bookmark.layer_ids.contains($0.id)}).map({$0.isToggled = true})
                                    
                                    //untoggle layers according to the bookmark
                                    _ = self.mapLayers.rasterLayers.filter({$0.themeID == bookmark.theme_id && !(bookmark.layer_ids.contains($0.id))}).map({$0.isToggled = false})
                                    
                                    //change the bbox of the map
                                    self.mapRegion.mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: bookmark.map.centre.latitude, longitude: bookmark.map.centre.longitude),
                                                                                  span: MKCoordinateSpan(latitudeDelta: bookmark.map.span.delta_latitude, longitudeDelta: bookmark.map.span.delta_longitude))
                                }) {
                                    HStack {
                                        Image(systemName: "bookmark.fill")
                                            .foregroundColor(.accentColor)
                                            .padding()
                                        VStack(alignment: .leading) {
                                            Text(bookmark.name)
                                                .foregroundColor(.accentColor)
                                                .font(.headline)
                                            Text(self.config.getExternalThemeName(id: bookmark.theme_id))
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .swipeActions(content: {
                                    Button(action: {
                                        //remove the bookmark
                                        if let index = self.bookmarksContainer.bookmarks.firstIndex(where: {$0.id == bookmark.id}) {
                                            _ = withAnimation() {
                                                self.bookmarksContainer.bookmarks.remove(at: index)
                                            }
                                        }
                                    }, label: {
                                        Label(String(localized: "Delete"), systemImage: "trash.fill")
                                    }).tint(.red)
                                })
                                .swipeActions(content: {
                                    Button(action: {
                                        //update map region and content
                                        if let index = self.bookmarksContainer.bookmarks.firstIndex(where: {$0.id == bookmark.id}) {
                                            
                                            self.bookmarksContainer.bookmarks[index] = MalinkiBookmarksObject(
                                                id: bookmark.id,
                                                name: bookmark.name,
                                                theme_id: self.mapLayers.selectedMapThemeID,
                                                layer_ids: self.mapLayers.rasterLayers.filter({$0.themeID == self.mapLayers.selectedMapThemeID && $0.isToggled}).map({$0.id}),
                                                show_annotations: self.mapLayers.areAnnotationsToggled(),
                                                map: MalinkiBookmarksMap(centre: MalinkiBookmarksMapCentre(
                                                    latitude: self.mapRegion.mapRegion.center.latitude,
                                                    longitude: self.mapRegion.mapRegion.center.longitude), span: MalinkiBookmarksMapSpan(
                                                        delta_latitude: self.mapRegion.mapRegion.span.latitudeDelta,
                                                        delta_longitude: self.mapRegion.mapRegion.span.longitudeDelta))
                                            )
                                        }
                                    }, label: {
                                        Label(String(localized: "Update"), systemImage: "arrow.triangle.2.circlepath")
                                    }).tint(.purple)
                                })
                                .swipeActions(content: {
                                    Button(action: {
                                        //rename the bookmark
                                        self.actionType = .updateBookmark
                                        self.uuidString = bookmark.id
                                        self.showAlert = true
                                    }, label: {
                                        Label(String(localized: "Rename"), systemImage: "pencil")
                                    }).tint(.blue)
                                })
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: {
                        ToolbarItem(placement: .principal, content: {
                            MalinkiSheetHeader(title: String(localized: "Bookmarks"), isSheetShowing: self.$isSheetShowing, sheetDetent: self.$sheetState)
                        })
                    })
                }
                Spacer()
                Button(action: {
                    self.actionType = .insertBookmark
                    self.showAlert = true
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus")
                        Text(String(localized: "Add Bookmark"))
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
        }
        .ignoresSafeArea(.keyboard)
    }
}

@available(iOS 15.0.0, *)
struct MalinkiBookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiBookmarksView(sheetState: .constant(UISheetPresentationController.Detent.Identifier.medium), isSheetShowing: .constant(true))
            .environmentObject(MalinkiBookmarksProvider.sharedInstance)
            .environmentObject(MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray(), themes: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray().map({MalinkiTheme(themeID: $0.themeID)}), selectedMapThemeID: 0))
            .environmentObject(MalinkiMapRegion(mapRegion: MKCoordinateRegion()))
    }
}
