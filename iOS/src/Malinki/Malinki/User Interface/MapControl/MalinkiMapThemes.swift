//
//  MalinkiMapThemes.swift
//  Malinki
//
//  Created by Christoph Jung on 11.08.21.
//

import SwiftUI

struct MalinkiMapThemes: View {
    
    @Binding private var mapThemeID: Int
    @Binding private var mapLayers: [MalinkiMapLayer]
    
    init(mapThemeID: Binding<Int>, mapLayers: Binding<[MalinkiMapLayer]>) {
        self._mapThemeID = mapThemeID
        self._mapLayers = mapLayers
    }
    
    var columns: [GridItem] =
        Array(repeating: .init(.flexible()), count: MalinkiConfigurationProvider.sharedInstance.getMapThemes().count)
    
    var body: some View {
        
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach(MalinkiConfigurationProvider.sharedInstance.getMapThemes(), id: \.id) { mapTheme in
                    MalinkiMapThemeButton(imageName: mapTheme.iconName, colour: Color.primary, toggledMapThemeID: self.$mapThemeID, themeName: mapTheme.externalNames.en, id: mapTheme.id, mapLayers: self.$mapLayers)
                }
            }
        }
        .padding()
    }
}

struct MalinkiMapThemes_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapThemes(mapThemeID: .constant(0), mapLayers: .constant([]))
    }
}
