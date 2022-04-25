//
//  MalinkiSearchResultButton.swift
//  Malinki
//
//  Created by Christoph Jung on 25.04.22.
//

import SwiftUI

struct MalinkiSearchResultView: View {
    
    var title: String
    var footnote: String
    var imageName: String
    
    
    var body: some View {
        HStack {
            Image(systemName: self.imageName)
                .foregroundColor(.accentColor)
            
            VStack {
                HStack {
                    Text(self.title)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                if self.footnote != "" {
                    HStack {
                        Text(self.footnote)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
        }
    }
    
}

struct MalinkiSearchResultButton_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiSearchResultView(title: "Result", footnote: "additional Information", imageName: "magnifyingglass")
    }
}
