//
//  MalinkiButtonGroup.swift
//  Malinki
//
//  Created by Christoph Jung on 08.07.21.
//

import SwiftUI

struct MalinkiBasemaps: View {
    
    @Binding private var basemapID: Int
    
    init(basemapID: Binding<Int>) {
        self._basemapID = basemapID
    }
    
    private var columns: [GridItem] =
        Array(repeating: .init(.flexible()), count: MalinkiConfigurationProvider.sharedInstance.getBasemaps().count)
    
    var body: some View {
        LazyVGrid(columns: self.columns, spacing: 2, pinnedViews: []) {
            
            ForEach(MalinkiConfigurationProvider.sharedInstance.getBasemaps(), id: \.id) { basemap in
                MalinkiBasemapButton(toggledBasemapID: self.$basemapID, imageName: basemap.imageName, basemapName: basemap.externalNames.de, id: basemap.id)
            }
            
        }
    }
}

struct MalinkiButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiBasemaps(basemapID: .constant(0))
    }
}
