//
//  MalinkiBookmarksProvider.swift
//  Malinki
//
//  Created by Christoph Jung on 03.05.22.
//

import Foundation

class MalinkiBookmarksProvider: ObservableObject {
    
    static let sharedInstance = MalinkiBookmarksProvider()  // The singleton of this class
    private let fileName: String = "bookmarks.json"
    @Published var bookmarksRoot: MalinkiBookmarksRoot = MalinkiBookmarksRoot(bookmarks: []) {
        didSet {
            print(self.bookmarksRoot)
        }
    }
    
    /// The initialiser of this class.
    private init() {
        let fm = FileManager.default
        if let path = self.getBookMarksPath(fileManager: fm) {
            
            //create a bookmarks file if not existing
            if !(fm.fileExists(atPath: path)) {
                fm.createFile(atPath: path, contents: self.encodeBookmarks())
            } else {
                //read the bookmarks file
                do {
                    let decoder = JSONDecoder()
                    self.bookmarksRoot = try decoder.decode(MalinkiBookmarksRoot.self, from: Data(contentsOf: URL(string: path)!))
                } catch  {
                    print("ERROR decoding the bookmarks!")
                    print(error)
                }
            }
        }
    }
    
    /// A function to encode the bookmarks object.
    /// - Returns: a Data object containing the bookmarks object of this instance
    private func encodeBookmarks() -> Data {
        var bookmarksData = Data()
        let encoder = JSONEncoder()
        if let _bookmarksData = try? encoder.encode(self.bookmarksRoot) {
            bookmarksData = _bookmarksData
        }
        return bookmarksData
    }
    
    private func getBookMarksPath(fileManager: FileManager) -> String? {
        let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsUrl?.path.stringByAppendingPathComponent(path: self.fileName)
    }
    
    public func saveBookmarksToFile() {
        let fm = FileManager.default
        let path = self.getBookMarksPath(fileManager: fm)
        let data = self.encodeBookmarks()
        if let bookmarksPath = path, let url = URL(string: bookmarksPath) {
            try? data.write(to: url)
        }
    }
}
