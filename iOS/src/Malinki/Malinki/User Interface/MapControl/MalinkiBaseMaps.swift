//
//  MalinkiButtonGroup.swift
//  Malinki
//
//  Created by Christoph Jung on 08.07.21.
//

import SwiftUI

struct MalinkiBasemaps: View {
    
//    private var columns: [GridItem] = [GridItem(.flexible()),
//                                       GridItem(.flexible()),
//                                       GridItem(.flexible()),
//                                       GridItem(.flexible())]
//    private var columns: [GridItem] {
//        var gridItems: [GridItem] = []
//        let countOfBasemaps = MalinkiConfigurationProvider.sharedInstance.configData?.basemaps.count ?? 0
//
//        for _ in 0...countOfBasemaps {
//            gridItems.append(GridItem(.flexible()))
//        }
//
//        return gridItems
//    }
    
    var columns: [GridItem] =
        Array(repeating: .init(.flexible()), count: MalinkiConfigurationProvider.sharedInstance.configData?.basemaps.count ?? 0)
    
    var body: some View {
        LazyVGrid(columns: self.columns, spacing: 2, pinnedViews: []) {
            
            ForEach(MalinkiConfigurationProvider.sharedInstance.configData?.basemaps ?? [], id: \.id) { basemap in
                MalinkiBasemapButton(isToggled: .constant(false), imageName: basemap.imageName, basemapName: basemap.externalName.de)
            }
            
//            //a button for showing the users position
//            Button(action: {
//                print("Test Position")
//
//            }) {
//                ZStack {
//                    Rectangle()
//                        .foregroundColor(Color(UIColor.systemGray5))
//                    Image(systemName: "location")
//                        .font(.system(size: 20, weight: .regular))
//                        .padding()
//                }
//            }
//            .cornerRadius(10)
//
//            //a button for sharing the map
//            Button(action: {
//                print("Test Share")
//
//            }) {
//                ZStack {
//                    Rectangle()
//                        .foregroundColor(Color(UIColor.systemGray5))
//                    Image(systemName: "square.and.arrow.up")
//                        .font(.system(size: 20, weight: .regular))
//                        .padding()
//                }
//            }
//            .cornerRadius(10)
//
//            //a button for toggling the compass
//                Button(action: {
//                    print("Test Compass")
//
//                }) {
//                    ZStack {
//                        Rectangle()
//                            .foregroundColor(Color(UIColor.systemGray5))
//                        Image(systemName: "square.and.arrow.up")
//                            .font(.system(size: 20, weight: .regular))
//                            .padding()
//                    }
//                }
//                .cornerRadius(10)
//
//                //a button for toggling the scale
//                Button(action: {
//                    print("Test Scale")
//
//                }) {
//                    ZStack {
//                        Rectangle()
//                            .foregroundColor(Color(UIColor.systemGray5))
//                        Image(systemName: "square.and.arrow.up")
//                            .font(.system(size: 20, weight: .regular))
//                            .padding()
//                    }
//                }
//                .cornerRadius(10)
        }
        
    }
}

struct MalinkiButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiBasemaps()
    }
}
