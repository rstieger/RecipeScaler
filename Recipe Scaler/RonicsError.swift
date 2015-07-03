//
//  ErrorHandler.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 7/2/15.
//  Copyright (c) 2015 Ron Stieger. All rights reserved.
//

import Foundation

enum RonicsError {
    case InvalidController, InvalidIdentifier, InvalidPath, InvalidSender
    
    static let name: [RonicsError: String] = [
        .InvalidController: "invalid controller",
        .InvalidIdentifier: "invalid identifier",
        .InvalidPath: "invalid path",
        .InvalidSender: "invalid sender"
    ]
    
    func report(function: String) {
        println("Error: \(RonicsError.name[self]!) in \(function)")
    }
}