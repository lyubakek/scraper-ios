//
//  ScanState.swift
//  Scraper
//
//  Created by Liubov Kovalchuk on 14.10.2021.
//

import Foundation

enum ScanState {
    case finishedScanning(Bool) //found or not found text on page
    case errorScan
    case notStartedScanning
    case inProgress
}
