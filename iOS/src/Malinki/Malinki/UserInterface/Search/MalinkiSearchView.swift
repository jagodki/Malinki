//
//  MalinkiSearchView.swift
//  Malinki
//
//  Created by Christoph Jung on 12.07.21.
//

import SwiftUI
import SheeKit

@available(iOS 15.0, *)
struct MalinkiSearchView: View {
    
    @Binding private var searchText: String
    @Binding private var sheetDetent: UISheetPresentationController.Detent.Identifier?
    @Binding private var isSheetShowing: Bool
    @Binding private var isEditing: Bool
    @EnvironmentObject private var mapLayers: MalinkiLayerContainer
    private var config: MalinkiConfigurationProvider = MalinkiConfigurationProvider.sharedInstance
    
    private var filteredThemes: [MalinkiConfigurationTheme] {
        return self.config.getMapThemes().filter({
            self.config.getExternalThemeName(id: $0.id).lowercased().contains(self.searchText.lowercased())
        })
    }
    
    private var filteredMapLayers: [MalinkiLayer] {
        return self.config.getAllMapLayersArray().filter({
            $0.name.lowercased().contains(self.searchText.lowercased())
        })
    }
    
    init(searchText: Binding<String>, sheetDetent: Binding<UISheetPresentationController.Detent.Identifier?>, isSheetShowing: Binding<Bool>, isEditing: Binding<Bool>) {
        self._searchText = searchText
        self._sheetDetent = sheetDetent
        self._isSheetShowing = isSheetShowing
        self._isEditing = isEditing
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                //show an information to the user, if no search string is inserted
                if self.searchText == "" || (self.filteredThemes.count == 0 && self.filteredMapLayers.count == 0) {
                    
                    HStack {
                        Spacer()
                        
                        Text(LocalizedStringKey("No search results..."))
                            .foregroundColor(.secondary)
                            .italic()
                        
                        Spacer()
                    }
                    
                    Spacer()
                } else {
                    Form {
                        
                        //show filtered map themes
                        if self.filteredThemes.count != 0 {
                            Section(header: Text(LocalizedStringKey("Map Themes")).sectionHeaderStyle()) {
                                
                                ForEach(self.filteredThemes, id: \.id) { mapTheme in
                                    Button(action: {
                                        //set the current map theme and close the sheet
                                        self.mapLayers.selectedMapThemeID = mapTheme.id
                                        self.isSheetShowing = false
                                    }) {
                                        MalinkiSearchResultView(title: self.config.getExternalThemeName(id: mapTheme.id), footnote: "", imageName: self.config.getMapTheme(for: mapTheme.id)?.iconName ?? "questionmark.circle")
                                    }
                                }
                                
                            }
                        }
                        
                        //show filtered map layers
                        if self.filteredMapLayers.count != 0 {
                            Section(header: Text(LocalizedStringKey("Map Content")).sectionHeaderStyle()) {
                                
                                ForEach(self.filteredMapLayers, id: \.self) { layer in
                                    Button(action: {
                                        //set the current map theme, only enable the current layer and close the sheet
                                        self.mapLayers.rasterLayers.filter({$0.id == layer.id}).first?.isToggled = true
                                        _ = self.mapLayers.rasterLayers.filter({$0.themeID == layer.themeID && $0.id != layer.id}).map({$0.isToggled = false})
                                        self.mapLayers.selectedMapThemeID = layer.themeID
                                        self.isSheetShowing = false
                                    }) {
                                        MalinkiSearchResultView(title: self.config.getExternalRasterLayerName(themeID: layer.themeID, layerID: layer.id), footnote: self.config.getExternalThemeName(id: layer.themeID), imageName: self.config.getMapTheme(for: layer.themeID)?.iconName ?? "questionmark.circle")
                                    }
                                }
                                
                            }
                        }
                        
                    }
                }
                
            }
            .background(Color(uiColor: .systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal, content: {
                    MalinkiSheetHeader(title: "Search", isSheetShowing: self.$isSheetShowing, sheetDetent: self.$sheetDetent)
                })
            })
        }
        .searchable(text: self.$searchText)
        .padding(.top)
        .background(Color(uiColor: .systemGray6))
    }
}

@available(iOS 15.0, *)
struct MalinkiSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiSearchView(searchText: .constant(""), sheetDetent: .constant(UISheetPresentationController.Detent.Identifier.large), isSheetShowing: .constant(true), isEditing: .constant(true))
            .environmentObject(MalinkiLayerContainer(layers: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray(), themes: MalinkiConfigurationProvider.sharedInstance.getAllMapLayersArray().map({MalinkiTheme(themeID: $0.themeID)}), selectedMapThemeID: 0))
    }
}
