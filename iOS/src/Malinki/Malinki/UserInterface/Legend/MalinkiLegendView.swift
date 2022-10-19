//
//  MalinkiLegendView.swift
//  Malinki
//
//  Created by Christoph Jung on 18.10.22.
//

import SwiftUI

struct MalinkiLegendView: View {
    
    var title: String
    
    
    var body: some View {
        NavigationView() {
            Form {
                Image(systemName: "cloud.moon.bolt.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .navigationTitle("test")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MalinkiLegendView_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiLegendView(title: "Legend Graphic")
    }
}
