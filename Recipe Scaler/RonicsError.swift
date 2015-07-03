//
//  ErrorHandler.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 7/2/15.
//  Copyright (c) 2015 Ron Stieger. All rights reserved.
//

import Foundation

class RonicsError {
    class func report(e: RonicsErrorType, inFile file: String = __FILE__,
        inFunction function: String = __FUNCTION__, withMessage message: String = "") {
        let filename = file.componentsSeparatedByString("/").last!
        println("Error: \(e.getString()) in \(filename):\(function) -- \(message)")
    }
}

enum RonicsErrorType {
    case InvalidController, InvalidIdentifier, InvalidPath, InvalidSender, InvalidCell, InvalidKey, InvalidNotification
    case MissingNavController
    
    func getString() -> String {
        switch self {
        case .InvalidController: return "invalid controller"
        case .InvalidIdentifier: return "invalid identifier"
        case .InvalidPath: return "invalid path"
        case .InvalidSender: return "invalid sender"
        case .InvalidCell: return "invalid cell"
        case .InvalidKey: return "invalid key"
        case .InvalidNotification: return "invalid notification"
        case .MissingNavController: return "missing navigation controller"
        }
    }
}