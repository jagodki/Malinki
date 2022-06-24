//
//  MalinkiUserAnnotationsProvider.swift
//  Malinki
//
//  Created by Christoph Jung on 23.06.22.
//

import Foundation
import MapKit

class MalinkiUserAnnotationsProvider: ObservableObject {
    
    static let sharedInstance = MalinkiUserAnnotationsProvider()  // The singleton of this class
    private let fileName: String = "user_annotations.geojson"
    
    @Published var userAnnotationsRoot: MalinkiUserAnnotationsRoot = MalinkiUserAnnotationsRoot(user_annotations: []) {
        didSet {
            self.saveUserAnnotationsToFile()
        }
    }
    
    var userAnnotations: [MalinkiUserAnnotation] {
        get { self.userAnnotationsRoot.user_annotations }
        set { self.userAnnotationsRoot.user_annotations = newValue }
    }
    
    init() {
        let fm = FileManager.default
        if let path = self.getUserAnnotationsPath(fileManager: fm) {
            
            //create a bookmarks file if not existing
            if !(fm.fileExists(atPath: path)) {
                fm.createFile(atPath: path, contents: self.encodeUserAnnotations())
            } else {
                //read the bookmarks file
                do {
                    let decoder = JSONDecoder()
                    self.userAnnotationsRoot = try decoder.decode(MalinkiUserAnnotationsRoot.self, from: Data(contentsOf: URL(string: "file://\(path)")!))
                } catch  {
                    print("ERROR decoding the user annotations!")
                    print(error)
                }
            }
        }
    }
    
    /// A function to encode the user annotations object.
    /// - Returns: a Data object containing the user annotations object of this instance
    private func encodeUserAnnotations() -> Data {
        var userAnnotationsData = Data()
        let encoder = JSONEncoder()
        if let _userAnnotationsData = try? encoder.encode(self.userAnnotationsRoot) {
            userAnnotationsData = _userAnnotationsData
        }
        return userAnnotationsData
    }
    
    /// A function to create the absolute path of geojson file with the user annotations within.
    /// - Parameter fileManager: a default FileManager object
    /// - Returns: the path as String
    private func getUserAnnotationsPath(fileManager: FileManager) -> String? {
        let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsUrl?.path.stringByAppendingPathComponent(path: self.fileName)
    }
    
    /// A function for saving the user annoitations object to a file.
    public func saveUserAnnotationsToFile() {
        let fm = FileManager.default
        let path = self.getUserAnnotationsPath(fileManager: fm)
        let data = self.encodeUserAnnotations()
        if let userAnnotationsPath = path, let url = URL(string: "file://\(userAnnotationsPath)") {
            try? data.write(to: url)
        }
    }
    
}
