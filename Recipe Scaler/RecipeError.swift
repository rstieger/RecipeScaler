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
        func printName(name: String) -> String {
            return (name != "") ? name : "ingredient".localize()
        }
        switch self {
        case .DivideByZero(let name):
            return String(format: "Recipe doesn't have any %@.".localize(), printName(name))
        case .MultipleUnitTypes(let name):
            return String(format: "%@ has incompatible units in recipe.".localize(), printName(name))
            
        }
    }
}

func == (lhs: RecipeError, rhs: RecipeError) -> Bool {
    return lhs.getString() == rhs.getString()
}
