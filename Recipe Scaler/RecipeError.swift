//
//  RecipeError.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 9/27/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import Foundation

enum RecipeError: Equatable {
    case DivideByZero(name: String)
    
    func getString() -> String{
        switch self {
        case .DivideByZero(let name):
            return "Recipe doesn't have any \(name)"
            
        }
    }
}

func == (lhs: RecipeError, rhs: RecipeError) -> Bool {
    return lhs.getString() == rhs.getString()
}
