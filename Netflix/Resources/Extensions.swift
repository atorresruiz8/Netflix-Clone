//
//  Extensions.swift
//  Netflix
//
//  Created by Antonio Torres-Ruiz on 5/5/22.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
