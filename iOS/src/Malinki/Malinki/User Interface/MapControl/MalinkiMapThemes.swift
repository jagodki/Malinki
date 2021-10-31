//
//  MalinkiMapThemes.swift
//  Malinki
//
//  Created by Christoph Jung on 11.08.21.
//

import SwiftUI

struct MalinkiMapThemes: View {
    
    @Binding private var mapThemeID: Int
    @Binding private var showBasemapsSheet: Bool
    
    init(mapThemeID: Binding<Int>, showBasemapsSheet: Binding<Bool>) {
        self._mapThemeID = mapThemeID
        self._showBasemapsSheet = showBasemapsSheet
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
                self.showBasemapsSheet = true
            }) {
                Text(LocalizedStringKey("Basemaps"))
                Image(systemName: "square.2.stack.3d.bottom.filled")
            }
        } label: {
            Image(systemName: "map.fill")
                .padding(.all, 10.0)
                .foregroundColor(Color.primary)
                .font(.title)
        }
    }
}

struct MalinkiMapThemes_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapThemes(mapThemeID: .constant(0), showBasemapsSheet: .constant(false))
    }
}
