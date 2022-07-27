//
//  MalinkiMapThemes.swift
//  Malinki
//
//  Created by Christoph Jung on 11.08.21.
//

import SwiftUI

/// A struct to display a button for choosing the map themes.
@available(iOS 15.0.0, *)
struct MalinkiMapThemes: View {
    
    @Binding private var sheetState: MalinkiSheetState?
    @EnvironmentObject var mapLayers: MalinkiLayerContainer
    
    /// The initialiser of this struct.
    /// - Parameters:
    ///   - sheetState: a binding of the sheet state
    init(sheetState: Binding<MalinkiSheetState?>) {
        self._sheetState = sheetState
    }
    
    var body: some View {
        
        Menu {
            Picker(selection: self.$mapLayers.selectedMapThemeID, label: Text(LocalizedStringKey("Map Themes"))) {
                ForEach(MalinkiConfigurationProvider.sharedInstance.getMapThemes(), id: \.id) { mapTheme in
                    HStack {
                        Text(MalinkiConfigurationProvider.sharedInstance.getExternalThemeName(id: mapTheme.id))
                        Image(systemName: mapTheme.iconName)
                    }.tag(mapTheme.id)
                }
            }
            
            Button(action: {
                self.sheetState = .basemaps
            }) {
                Text(LocalizedStringKey("Basemaps"))
                Image(systemName: "square.2.stack.3d.bottom.filled")
            }
        } label: {
            Image(systemName: "map.fill")
                .font(.title2)
                .foregroundColor(Color.primary)
                .padding()
        }
    }
}

@available(iOS 15.0.0, *)
struct MalinkiMapThemes_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapThemes(sheetState: .constant(.basemaps))
            .environmentObject(MalinkiLayerContainer(layers: [], themes: [MalinkiTheme(themeID: 0), MalinkiTheme(themeID: 1)], selectedMapThemeID: 0))
    }
}
