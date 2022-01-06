//
//  MalinkiMapThemes.swift
//  Malinki
//
//  Created by Christoph Jung on 11.08.21.
//

import SwiftUI

/// A struct to display a button for choosing the map themes.
struct MalinkiMapThemes: View {
    
    @Binding private var mapThemeID: Int
    @Binding private var sheetState: MalinkiSheetState?
    
    /// The initialiser of this struct.
    /// - Parameters:
    ///   - mapThemeID: a binding indicating the current map theme
    ///   - sheetState: a binding of the sheet state
    init(mapThemeID: Binding<Int>, sheetState: Binding<MalinkiSheetState?>) {
        self._mapThemeID = mapThemeID
        self._sheetState = sheetState
    }
    
    var body: some View {
        
        Menu {
            Picker(selection: self.$mapThemeID, label: Text("Map Themes")) {
                ForEach(MalinkiConfigurationProvider.sharedInstance.getMapThemes(), id: \.id) { mapTheme in
                    Button(action: {
                        self.mapThemeID = mapTheme.id
                    }) {
                        Text(mapTheme.externalNames.en)
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

struct MalinkiMapThemes_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapThemes(mapThemeID: .constant(0), sheetState: .constant(.basemaps))
    }
}
