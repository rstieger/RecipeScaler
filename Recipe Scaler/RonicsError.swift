//
//  ErrorHandler.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 7/2/15.
//  Copyright (c) 2015 Ron Stieger. All rights reserved.
//

import Foundation

enum RonicsError {
    case InvalidController, InvalidIdentifier, InvalidPath, InvalidSender, InvalidCell, InvalidKey, InvalidNotification
    case MissingNavController
    
    static let name: [RonicsError: String] = [
        .InvalidController: "invalid controller",
        .InvalidIdentifier: "invalid identifier",
        .InvalidPath: "invalid path",
        .InvalidSender: "invalid sender",
        .InvalidCell: "invalid cell",
        .InvalidKey: "invalid key",
        .InvalidNotification: "invalid notification",
        .MissingNavController: "missing navigation controller"
    ]
    
    func report(file: String = __FILE__, function: String = __FUNCTION__) {
        println("Error: \(RonicsError.name[self]!) in \(file):\(function)")
    }
}