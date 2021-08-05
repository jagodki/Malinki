//
//  MalinkiMapThemeButton.swift
//  Malinki
//
//  Created by Christoph Jung on 28.07.21.
//

import SwiftUI

/// A structure to create a Map Theme Button.
struct MalinkiMapThemeButton: View {
    
    @Binding private var isToggled: Bool
    private var imageName: String
    private var firstColour: Color
    private var secondColour: Color
    private var themeName: String
    
    /// The initialiser of this structure
    /// - Parameters:
    ///   - imageName: the system name of the image
    ///   - firstColour: the primary colour of the button, used for the background if toggled
    ///   - secondColour: the secondary colour, used for the image if toggled
    ///   - isThemeToggled: a binding indicating, if the button is toggled or not
    ///   - themeName: the name of the theme, presented at the bottom of the button
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
                .foregroundColor(.primary)
        }
    }
}

struct MalinkiMapThemeButton_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapThemeButton(imageName: "map.fill", firstColour: .blue, secondColour: .white, isThemeToggled: .constant(false), themeName: "Test Theme")
    }
}
