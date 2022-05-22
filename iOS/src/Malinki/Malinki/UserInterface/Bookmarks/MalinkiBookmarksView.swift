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
        
        VStack {
        NavigationView {
            List(self.bookmarksContainer.bookmarksRoot.bookmarks, id: \.id) {bookmark in
                Button(action: {
                    self.mapLayers.selectedMapThemeID = bookmark.theme_id
                }) {
                    HStack {
                        Image(systemName: "bookmark.fill")
                            .padding()
                        VStack(alignment: .leading) {
                            Text(bookmark.name)
                                .font(.headline)
                            Text(self.config.getExternalThemeName(id: bookmark.theme_id))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .swipeActions(content: {
                    Button(action: { print(bookmark.name) }, label: { Label("Test", systemImage: "star") }).tint(.mint)
                })
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
            self.bookmarksContainer.bookmarks.append(MalinkiBookmarksObject(
                id: UUID().uuidString,
                name: "Test",
                theme_id: self.mapLayers.selectedMapThemeID,
                layer_ids: self.mapLayers.rasterLayers.filter({$0.themeID == self.mapLayers.selectedMapThemeID}).map({$0.id}),
                show_annotations: self.mapLayers.areAnnotationsToggled())
            )
        }) {
            HStack {
                Spacer()
                Image(systemName: "plus")
                Text("Test")
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
}

@available(iOS 15.0.0, *)
struct MalinkiBookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiBookmarksView(sheetState: .constant(UISheetPresentationController.Detent.Identifier.medium), isSheetShowing: .constant(true), mapRegion: .constant(MKCoordinateRegion()))
            .environmentObject(MalinkiBookmarksProvider.sharedInstance)
            .environmentObject(MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray(), themes: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray().map({MalinkiTheme(themeID: $0.themeID)}), selectedMapThemeID: 0))
    }
}
