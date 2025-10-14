//
//  Extensions.swift
//  Netflix-Clone
//
//  Created by xrt on 2025/10/13.
//

import Foundation

extension String {
    func capitalizedFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}