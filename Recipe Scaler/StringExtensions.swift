//
//  StringExtensions.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 7/3/15.
//  Copyright (c) 2015 Ron Stieger. All rights reserved.
//

import Foundation

extension String {
    func localize() -> String {
        return NSLocalizedString(self, comment: "")
    }
}