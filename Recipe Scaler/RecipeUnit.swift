//
//  RecipeUnit.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 9/24/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import Foundation

enum UnitType {
    case Volume, Weight, Piece
}

enum UnitRegion {
    case UK, US, Metric, Any
}

enum RecipeUnit {
    case Each
    case Gram, Kilogram, Pound, Ounce
    case Floz, Teaspoon, Tablespoon, Milliliter, Liter, Cup, Pint, Quart, Gallon
    case ImperialFloz, ImperialTsp, ImperialTbsp, ImperialPint, ImperialQuart, ImperialGallon
    
    static let allValues = [Kilogram, Pound, Ounce, Gram, Each,
        Milliliter, Teaspoon, ImperialTsp, Tablespoon, ImperialTbsp, ImperialFloz, Floz,
        Cup, Pint, ImperialPint, Quart, Liter, ImperialQuart, Gallon, ImperialGallon]
    
    static func getAllValues(fromRegions: [UnitRegion]) -> [RecipeUnit] {
        var values: [RecipeUnit] = []
        for unit in allValues {
            if unit.unitRegion == UnitRegion.Any || contains(fromRegions, unit.unitRegion) {
                values.append(unit)
            }
        }
        return values
    }
    
    var unitType: UnitType {
        get {
            switch self {
            case .Each: return .Piece
            case .Gram, .Kilogram, .Pound, .Ounce: return .Weight
            case .Floz, .Teaspoon, .Tablespoon, .Milliliter, .Liter, .Cup, .Pint, .Quart, .Gallon: return .Volume
            case .ImperialTsp, .ImperialTbsp, .ImperialFloz, .ImperialPint, .ImperialQuart, .ImperialGallon: return .Volume
            }
        }
    }
    
    var unitRegion: UnitRegion {
        get {
            switch self {
            case .Each: return .Any
            case .Gram, .Kilogram, .Milliliter, .Liter: return .Metric
            case .Pound, .Ounce, .Floz, .Teaspoon, .Tablespoon, .Cup, .Pint, .Quart, .Gallon: return .US
            case .ImperialTsp, .ImperialTbsp, .ImperialFloz, .ImperialPint, .ImperialQuart, .ImperialGallon: return .UK
            }
        }
    }

    static var UKunits = true

    var weight: Double {
        get {
            switch self {
            case .Each: return 0
            case .Gram: return 1
            case .Kilogram: return 1000
            case .Pound: return 453.592
            case .Ounce: return 28.3495
            case .Milliliter, .Liter, .Teaspoon, .Tablespoon, .Floz, .Cup, .Pint, .Quart, .Gallon: return 0
            case .ImperialTsp, .ImperialTbsp, .ImperialFloz, .ImperialPint, .ImperialQuart, .ImperialGallon: return 0
            }
        }
    }
    
    var volume: Double {
        get {
            switch self {
            case .Each, .Gram, .Kilogram, .Pound, .Ounce: return 0
            case .Milliliter: return 1
            case .Liter: return 1000
            case .Teaspoon: return 4.92892
            case .ImperialTsp: return 5.91939
            case .Tablespoon: return 14.7868
            case .ImperialTbsp: return 17.7582
            case .ImperialFloz: return 28.4131
            case .Floz: return 29.5735
            case .Cup: return 236.588
            case .Pint: return 473.176
            case .ImperialPint: return 568.261
            case .Quart: return 946.353
            case .ImperialQuart: return 1136.52
            case .Gallon: return 3785.41
            case .ImperialGallon: return 4546.09
            }
        }
    }

    var string: String {
        get {
            var ret: String
            switch self {
            case .Each: ret = ""
            case .Gram: ret = "g"
            case .Kilogram: ret = "kg"
            case .Pound: ret = "lb"
            case .Ounce: ret = "oz"
            case .Floz: ret = "fl oz"
            case .ImperialFloz: ret = "imp fl oz"
            case .Teaspoon: ret = "tsp"
            case .ImperialTsp: ret = "imp tsp"
            case .Tablespoon: ret = "Tbsp"
            case .ImperialTbsp: ret = "imp Tbsp"
            case .Milliliter: ret = "ml"
            case .Liter: ret = "L"
            case .Cup: ret = "cup"
            case .Pint: ret = "pt"
            case .ImperialPint: ret = "imp pt"
            case .Quart: ret = "qt"
            case .ImperialQuart: ret = "imp qt"
            case .Gallon: ret = "gal"
            case .ImperialGallon: ret = "imp gal"
            }
            return ret.localize()
        }
    }

    var allowsFractions: Bool {
        get {
            switch self {
            case .Each, .Pound, .Ounce, .Floz, .Teaspoon, .Tablespoon, .Cup, .Pint, .Quart, .Gallon:
                return true
            case .ImperialFloz, .ImperialTsp, .ImperialTbsp, .ImperialPint, .ImperialQuart, .ImperialGallon:
                return true
            case .Gram, .Kilogram, .Milliliter, .Liter:
                return false
            }
        }
    }
    
    static func optimizeUnit(quantity: Double, unit: RecipeUnit) -> (Double, RecipeUnit) {
  //      var standardQuantity = quantity * RecipeUnit.unitValue[unit]!
        //        if unit.unitType ==
        return (quantity, unit)
    }
    
    // returns unit and index where unit string ends
    static func fromString(unitAsString: String) -> (RecipeUnit?, Int) {
        var matchString: String?
        for (unitString, unit) in recipeUnitDictionary {
            if unitAsString.lowercaseString == unitString || unitAsString.lowercaseString.hasPrefix("\(unitString) ") {
                if matchString != nil {
                    if count(matchString!) < count(unitString) {
                        matchString = unitString    // use the longer matching string
                    }
                }
                else {
                    matchString = unitString
                }
            }
        }
        if matchString != nil {
            return (recipeUnitDictionary[matchString!], count(matchString!))
        }
        else {
            return (nil, 0)
        }
    }
}

