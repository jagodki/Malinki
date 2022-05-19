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
struct MalinkiBookmarksView: View {
    
    @EnvironmentObject var bookmarksContainer: MalinkiBookmarksProvider
    @EnvironmentObject var mapLayers: MalinkiLayerContainer
    @Binding private var sheetState: UISheetPresentationController.Detent.Identifier?
    @Binding private var isSheetShowing: Bool
    private var config = MalinkiConfigurationProvider.sharedInstance
    @Binding private var mapRegion: MKCoordinateRegion
    
    init(sheetState: Binding<UISheetPresentationController.Detent.Identifier?>, isSheetShowing: Binding<Bool>, mapRegion: Binding<MKCoordinateRegion>) {
        self._mapRegion = mapRegion
        self._sheetState = sheetState
        self._isSheetShowing = isSheetShowing
    }
    
    var body: some View {
        
        NavigationView {
            List(self.bookmarksContainer.bookmarksRoot.bookmarks, id: \.id) {bookmark in
                Button(action: {
                    self.mapLayers.selectedMapThemeID = bookmark.theme_id
                }) {
                    VStack {
                        Image(systemName: "bookmark.fill")
                            .padding()
                        HStack {
                            Text(bookmark.name)
                            Text(self.config.getExternalThemeName(id: bookmark.theme_id))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal, content: {
                    MalinkiSheetHeader(title: String(localized: "New bookmark"), isSheetShowing: self.$isSheetShowing, sheetDetent: self.$sheetState)
                })
            })
        }
        Spacer()
        Button(action: {
            print("center \(self.mapRegion.center.longitude) - \(self.mapRegion.center.latitude)")
        }) {
            HStack {
                Spacer()
                Image(systemName: "plus")
                Text("Test")
                Spacer()
            }
        }
        .padding()
        .foregroundColor(Color(uiColor: .systemGray6))
        .background(Color.accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
        
    }
}

@available(iOS 15.0.0, *)
struct MalinkiBookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiBookmarksView(sheetState: .constant(UISheetPresentationController.Detent.Identifier.medium), isSheetShowing: .constant(true), mapRegion: .constant(MKCoordinateRegion()))
            .environmentObject(MalinkiBookmarksProvider.sharedInstance)
            .environmentObject(MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray(), themes: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray().map({MalinkiTheme(themeID: $0.themeID)}), selectedMapThemeID: 0))
    }
}
