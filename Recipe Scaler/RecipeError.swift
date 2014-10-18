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
    case MultipleUnitTypes(name: String)
    
    func getString() -> String{
        let noIngredient = "ingredient"
        switch self {
        case .DivideByZero(let name):
            let printName = (name != "") ? name : noIngredient
            return "Recipe doesn't have any \(printName)."
        case .MultipleUnitTypes(let name):
            let printName = (name != "") ? name : noIngredient
            return "\(printName) has incompatible units in recipe."
            
        }
    }
}

func == (lhs: RecipeError, rhs: RecipeError) -> Bool {
    return lhs.getString() == rhs.getString()
}
