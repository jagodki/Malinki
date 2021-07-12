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
            
            VStack {
                //a button for showing the users position
                Button(action: {
                        print("Test Position")
                    
                }) {
                    Image(systemName: "location")
                        .font(.system(size: 20, weight: .regular))
                        .padding()
                }
                
                Divider()
                
                //a button for sharing the map
                Button(action: {
                        print("Test Position")
                    
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .regular))
                        .padding()
                }
            }
        }
        .frame(width: 50, height: 130)
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
