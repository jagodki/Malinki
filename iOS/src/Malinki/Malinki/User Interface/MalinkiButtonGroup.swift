//
//  MalinkiButtonGroup.swift
//  Malinki
//
//  Created by Christoph Jung on 08.07.21.
//

import SwiftUI
import SwiftUIX

struct MalinkiButtonGroup: View {
    var body: some View {
        ZStack {
            //a blur effect for the background
            VisualEffectBlurView(blurStyle: .regular)
                .frame(width: 50, height: 135)
            
            VStack {
                //a button for showing the users position
                Button(action: {
                        print("Test Position")
                    
                }) {
                    Image(systemName: "location")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .padding()
                }
                
                Divider()
                    .frame(width: 50)
                
                //a button for sharing the map
                Button(action: {
                        print("Test Position")
                    
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .frame(width: 20, height: 25, alignment: .center)
                        .padding()
                }
            }
        }
        .cornerRadius(10)
        .shadow(radius: 2.5)
        .padding()
    }
}

struct MalinkiButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiButtonGroup()
    }
}
