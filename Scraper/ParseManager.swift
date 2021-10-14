//
//  ParseManager.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 14.10.2021.
//

import Foundation
import UIKit

class ParseManager {
    
    func getDataFromUrl(_ urlString: String) -> String? {
       
        guard let myURL = URL(string: urlString) else {
            print("Error: \(urlString) doesn't seem to be a valid URL")
            return ""
        }

        return try? String(contentsOf: myURL, encoding: .ascii)

//        do {
//            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
//            print("HTML : \(myHTMLString)")
//            return myHTMLString
//        } catch let error {
//            print("Error: \(error)")
//        }
    }
    
    
    func findUrlsInString(_ inputString: String) -> [String] {
        var array: [String] = []

        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: inputString, options: [], range: NSRange(location: 0, length: inputString.utf16.count))

        for match in matches {
            guard let range = Range(match.range, in: inputString) else { continue }
            let url = inputString[range]
            array.append(String(url))
        
            print("url will be on next row")
            print(url)
        }
        print(array)
        return array
    }
}
