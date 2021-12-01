//
//  ParseManager.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 14.10.2021.
//

import Foundation
import UIKit

class ParseManager {
    
    enum ParseError: Error {
        case corruptUrl(String)
        case emptyString
        case emptyData
        var localizedDescription: String {
            switch self {
            case .corruptUrl(let url):
                return "Error: \(url) doesn't seem to be a valid URL"
            case .emptyString:
                return "Your string is empty"
            case .emptyData:
                return "Data is empty"
            }
        }
    }
    
    func findTextOnPage(_ findingText: String, _ htmlString: String) -> Bool {
        if htmlString.contains(findingText) {
            return true
        }
        return false
    }
    
    func getDataFromUrl(_ urlString: String, completion:  @escaping (Result<String, Error>) -> Void) {
        guard let myURL = URL(string: urlString) else {
            completion(.failure(ParseError.corruptUrl(urlString)))
            print("Error: \(urlString) doesn't seem to be a valid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: myURL) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(ParseError.emptyData))
                return
            } 

            guard let some = String(data: data, encoding: .ascii) else {
                completion(.failure(ParseError.emptyString))
                return
            }
            completion(.success(some))
            //        return try? String(contentsOf: myURL, encoding: .ascii)
        }
        task.resume()
    }
    
    func findUrlsInString(_ inputString: String) -> [String] {
        var array: [String] = []
        var set: Set<String> = []
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: inputString, options: [],
                                       range: NSRange(location: 0, length: inputString.utf16.count))
        
        for match in matches {
            guard let range = Range(match.range, in: inputString) else { continue }
            let url = String(inputString[range])
            
            if set.contains(url) {
                continue
            } else {
                array.append(url)
                set.insert(url)
            }
        }
        return array
    }
}
