//
//  MalinkiSimpleDataConverter.swift
//  Malinki
//
//  Created by Christoph Jung on 17.11.22.
//

import Foundation

/// This class provides functions for converting simple data like strings or integers.
class MalinkiSimpleDataConverter {
    
    static let sharedInstance = MalinkiSimpleDataConverter()
    
    /// This function replaces placeholders for time with the current timestamp.
    /// - Parameter text: the text containing placeholders
    /// - Returns: a text without placeholders
    func replaceTimePlaceholders(for text: String) -> String {
        //get the current timestamp and its components
        let timestamp = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(identifier: "UTC")!, from: .now)
        let year = String(timestamp.year ?? 2000)
        let month = String(timestamp.month ?? 1)
        let day = String(timestamp.day ?? 1)
        let hours = String(timestamp.hour ?? 0)
        let minutes = String(timestamp.minute ?? 0)
        let seconds = String(timestamp.second ?? 0)
        
        //replace placeholders
        let textWithYear = text.replacingOccurrences(of: "{YYYY}", with: year)
        let textWithMonth = textWithYear.replacingOccurrences(of: "{MM}", with: month.count == 1 ? "0\(month)" : month)
        let textWithDay = textWithMonth.replacingOccurrences(of: "{DD}", with: day.count == 1 ? "0\(day)" : day)
        let textWithHours = textWithDay.replacingOccurrences(of: "{hh}", with: hours.count == 1 ? "0\(hours)" : hours)
        let textWithMinutes = textWithHours.replacingOccurrences(of: "{mm}", with: minutes.count == 1 ? "0\(minutes)" : minutes)
        let textWithSeconds = textWithMinutes.replacingOccurrences(of: "{ss}", with: seconds.count == 1 ? "0\(seconds)" : seconds)
        
        return textWithSeconds
    }
    
}
