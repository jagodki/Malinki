//
//  MalinkiMap.swift
//  Malinki
//
//  Created by Christoph Jung on 07.07.21.
//

import SwiftUI

struct MalinkiMap: View {
    var body: some View {
        MalinkiMapView()
            .edgesIgnoringSafeArea(.all)
    }
}

struct MalinkiMap_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMap()
    }
}
