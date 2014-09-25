//
//  RecipeUnit.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 9/24/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import Foundation

enum UnitType {
    case Volume, Weight
}

enum RecipeUnit {
    case Each
    case Gram, Kilogram, Pound, Ounce
    case Floz, Teaspoon, Tablespoon, Milliliter, Liter, Cup, Pint, Quart, Gallon
    
    static let allValues = [Kilogram, Pound, Ounce, Gram, Each, Milliliter, Teaspoon, Tablespoon, Floz, Cup, Pint, Quart, Liter, Gallon]
    var unitType: UnitType? {
        get {
            switch self {
            case Gram, Kilogram, Pound, Ounce: return .Weight
            case Floz, Teaspoon, Tablespoon, Milliliter, Liter, Cup, Pint, Quart, Gallon: return .Volume
            default: return nil
            }
        }
    }
    // TODO: option for US or Imperial fluid units
    static let unitValue: [RecipeUnit: Double] = [
        .Each: 1,
        .Gram: 1,
        .Kilogram: 1000,
        .Pound: 453.592,
        .Ounce: 28.3495,
        .Milliliter: 1,
        .Liter: 1000,
        .Floz: 29.5735,
        .Teaspoon: 4.92892,
        .Tablespoon: 14.7868,
        .Cup: 236.588,
        .Pint: 473.176,
        .Quart: 946.353,
        .Gallon: 3785.41
    ]
    func getValue() -> Double {
        return RecipeUnit.unitValue[self]!
    }
    static let standardString: [RecipeUnit: String] = [
        .Each: "",
        .Gram: "g",
        .Kilogram: "kg",
        .Pound: "lb",
        .Ounce: "oz",
        .Floz: "fl oz",
        .Teaspoon: "tsp",
        .Tablespoon: "Tbsp",
        .Milliliter: "ml",
        .Liter: "L",
        .Cup: "cup",
        .Pint: "pt",
        .Quart: "qt",
        .Gallon: "gal"
    ]
    func getString() -> String {
        return RecipeUnit.standardString[self]!
    }
    
    static func optimizeUnit(quantity: Double, unit: RecipeUnit) -> (Double, RecipeUnit) {
        var standardQuantity = quantity * RecipeUnit.unitValue[unit]!
        //        if unit.unitType ==
        return (quantity, unit)
    }
    
    static func fromString(unitAsString: String) -> RecipeUnit? {
        for unit in allValues {
            if unit.getString() == unitAsString {
                return unit
            }
        }
        return nil
    }
}

