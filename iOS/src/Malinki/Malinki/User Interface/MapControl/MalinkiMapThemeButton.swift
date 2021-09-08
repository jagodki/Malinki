//
//  MalinkiMapThemeButton.swift
//  Malinki
//
//  Created by Christoph Jung on 28.07.21.
//

import SwiftUI

/// A structure to create a Map Theme Button.
struct MalinkiMapThemeButton: View {
    
    @Binding private var toggledMapThemeID: Int
    private var id: Int
    private var imageName: String
    private var firstColour: Color
    private var secondColour: Color
    private var themeName: String
    
    /// The initialiser of this structure
    /// - Parameters:
    ///   - imageName: the system name of the image
    ///   - firstColour: the primary colour of the button, used for the background if toggled
    ///   - secondColour: the secondary colour, used for the image if toggled
    ///   - toggledMapThemeID: a binding indicating the toggled map theme
    ///   - themeName: the name of the theme, presented at the bottom of the button
    ///   - id: the id of the current map theme
    init(imageName: String, firstColour: Color, secondColour: Color, toggledMapThemeID: Binding<Int>, themeName: String, id: Int) {
        self.imageName = imageName
        self.firstColour = firstColour
        self.secondColour = secondColour
        self._toggledMapThemeID = toggledMapThemeID
        self.themeName = themeName
        self.id = id
    }
    
    var body: some View {
        VStack {
            Button(action: {
                self.toggledMapThemeID = self.id
            }) {
                Image(systemName: self.imageName)
                    .font(.system(size: 35, weight: .regular))
                    .frame(width: 100, height: 75, alignment: .center)
                    .foregroundColor(self.id == self.toggledMapThemeID ? self.firstColour : .secondary)
                    .background(self.id == self.toggledMapThemeID ? Color("themeBackgroundSelected") : Color("themeBackgroundUnselected"))
                    .cornerRadius(10)
                    .shadow(radius: self.id == self.toggledMapThemeID ? 5 : 0)
            }
            
            Text(self.themeName)
                .frame(width: 100, height: 20, alignment: .center)
                .font(.footnote).foregroundColor(self.id == self.toggledMapThemeID ? .primary : .secondary)
        }
    }
}

struct MalinkiMapThemeButton_Previews: PreviewProvider {
    static var previews: some View {
        MalinkiMapThemeButton(imageName: "map.fill", firstColour: .blue, secondColour: .white, toggledMapThemeID: .constant(1), themeName: "Test Theme", id: 0)
            .environment(\.colorScheme, .dark)
            .background(Color.gray)
    }
}
