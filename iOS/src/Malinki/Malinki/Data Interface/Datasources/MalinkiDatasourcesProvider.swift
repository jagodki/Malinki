//
//  MalinkiDatasourcesProvider.swift
//  Malinki
//
//  Created by Christoph Jung on 21.07.22.
//

import Foundation

@available(iOS 15, *)
/// A class for reading the markdown file with the datsources into it.
class MalinkiDatasourcesProvider: ObservableObject {
    /// The singleton of this class
    static let sharedInstance = MalinkiDatasourcesProvider()
    @Published public var datasourcesMarkDown: AttributedString = ""
    private let datasourcesFileName: String = "Datasources"
    
    /// The initialiser of this class.
    init() {
        guard let fileURL = Bundle.main.url(forResource: self.datasourcesFileName, withExtension: "md") else {
            print("ERROR: not able to find the datasource file")
            return
        }
        
        do {
            let content = try AttributedString(contentsOf: fileURL, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
            DispatchQueue.main.async {
                self.datasourcesMarkDown = content
            }
        } catch  {
            print("ERROR loading the datasources file:")
            print(error)
        }
    }
}
