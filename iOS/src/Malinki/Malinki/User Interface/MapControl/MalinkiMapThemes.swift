//
//  MalinkiMapThemes.swift
//  Malinki
//
//  Created by Christoph Jung on 11.08.21.
//

import SwiftUI

struct MalinkiMapThemes: View {
    
    @Binding private var mapThemeID: Int
    
    init(mapThemeID: Binding<Int>) {
        self._mapThemeID = mapThemeID
    }
    
    var columns: [GridItem] =
        Array(repeating: .init(.flexible()), count: MalinkiConfigurationProvider.sharedInstance.getMapThemes().count)
    
    var body: some View {
        
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach(MalinkiConfigurationProvider.sharedInstance.getMapThemes(), id: \.id) { mapTheme in
                    MalinkiMapThemeButton(imageName: mapTheme.iconName, firstColour: Color.primary, secondColour: Color.primary, toggledMapThemeID: self.$mapThemeID, themeName: mapTheme.externalNames.en, id: mapTheme.id)
                }
            }
        }
        .padding()
    }
}

struct MalinkiMapThemes_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapThemes(mapThemeID: .constant(0))
    }
}
