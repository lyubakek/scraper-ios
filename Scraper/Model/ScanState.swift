//
//  ScanState.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 14.10.2021.
//

import Foundation

enum ScanState {
    case finishedScanning(Bool) // found or not found text on page
    case errorScan(Error)
    case notStartedScanning
    case inProgress
}

extension ScanState: CustomStringConvertible {
    var description: String {
        switch self {
        case .finishedScanning(let value):
            if value {
                return "found"
            } else {
                return "not found" }
        case .errorScan(let error):
            return error.localizedDescription
        case .notStartedScanning:
            return "not started"
        case .inProgress:
            return "in progress"
        }
    }
}
