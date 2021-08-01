//
//  MalinkiMapThemeButton.swift
//  Malinki
//
//  Created by Christoph Jung on 28.07.21.
//

import SwiftUI

struct MalinkiMapThemeButton: View {
    
    @Binding private var isToggled: Bool
    private var imageName: String
    private var firstColour: Color
    private var secondColour: Color
    private var themeName: String
    
    init(imageName: String, firstColour: Color, secondColour: Color, isThemeToggled: Binding<Bool>, themeName: String) {
        self.imageName = imageName
        self.firstColour = firstColour
        self.secondColour = secondColour
        self._isToggled = isThemeToggled
        self.themeName = themeName
    }
    
    var body: some View {
        VStack {
            Button(action: {
                print("Theme Button pressed")
            }) {
                VStack {
                    Image(systemName: self.imageName)
                        .font(.system(size: 35, weight: .regular))
                        .frame(width: 100, height: 75, alignment: .center)
                        .foregroundColor(self.isToggled ? self.secondColour : self.firstColour)
                        .background(self.isToggled ? self.firstColour : Color(UIColor.secondarySystemFill))
                        .cornerRadius(10)
                }
            }
            
            Text(self.themeName)
                .frame(width: 100, height: 20, alignment: .center)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}

struct MalinkiMapThemeButton_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapThemeButton(imageName: "map.fill", firstColour: .blue, secondColour: .white, isThemeToggled: .constant(false), themeName: "Test Theme")
    }
}
