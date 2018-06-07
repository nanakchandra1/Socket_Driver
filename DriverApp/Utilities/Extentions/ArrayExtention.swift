//
//  ArrayExtention.swift
//  DriverApp
//
//  Created by saurabh on 07/09/16.
//  Copyright © 2016 AppInventiv. All rights reserved.
//

import Foundation
extension Array where Element : Equatable {
    mutating func removeObject(_ object : Iterator.Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}



extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
