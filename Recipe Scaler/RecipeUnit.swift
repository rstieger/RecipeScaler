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

enum UnitRegion {
    case UK, US, Metric
}

enum RecipeUnit {
    case Each
    case Gram, Kilogram, Pound, Ounce
    case Floz, Teaspoon, Tablespoon, Milliliter, Liter, Cup, Pint, Quart, Gallon
    case ImperialFloz, ImperialTsp, ImperialTbsp, ImperialPint, ImperialQuart, ImperialGallon
    
    static var allValues: [RecipeUnit] {
        get {
            if !UKunits {
                return [Kilogram, Pound, Ounce, Gram, Each, Milliliter, Teaspoon, Tablespoon, Floz, Cup, Pint, Quart, Liter, Gallon]
            } else {
                return [Kilogram, Pound, Ounce, Gram, Each, Milliliter, ImperialTsp, ImperialTbsp, ImperialFloz, ImperialPint, ImperialQuart, Liter, ImperialGallon]
            }
        }
    }
    
    var unitType: UnitType? {
        get {
            switch self {
            case Gram, Kilogram, Pound, Ounce: return .Weight
            case Floz, Teaspoon, Tablespoon, Milliliter, Liter, Cup, Pint, Quart, Gallon: return .Volume
            default: return nil
            }
        }
    }
    
    var unitRegion: UnitRegion? {
        get {
            switch self {
            case Gram, Kilogram, Milliliter, Liter: return .Metric
            case Pound, Ounce, Floz, Teaspoon, Tablespoon, Cup, Pint, Quart, Gallon: return .US
            case ImperialTsp, ImperialTbsp, ImperialFloz, ImperialPint, ImperialQuart, ImperialGallon: return .UK
            default: return nil
            }
            }
    }
    // TODO: option for US or Imperial fluid units
    static var UKunits = false
    static let unitValue: [RecipeUnit: (weight: Double, volume: Double)] = [
        .Each: (0, 0),
        .Gram: (1, 0),
        .Kilogram: (1000, 0),
        .Pound: (453.592, 0),
        .Ounce: (28.3495, 0),
        .Milliliter: (0, 1),
        .Liter: (0, 1000),
        .Teaspoon: (0, 4.92892),
        .ImperialTsp: (0, 5.91939),
        .Tablespoon: (0, 14.7868),
        .ImperialTbsp: (0, 17.7582),
        .ImperialFloz: (0, 28.4131),
        .Floz: (0, 29.5735),
        .Cup: (0, 236.588),
        .Pint: (0, 473.176),
        .ImperialPint: (0, 568.261),
        .Quart: (0, 946.353),
        .ImperialQuart: (0, 1136.52),
        .Gallon: (0, 3785.41),
        .ImperialGallon: (0, 4546.09)
    ]
    
    func getValue() -> (weight: Double, volume: Double) {
        return RecipeUnit.unitValue[self]!
    }
    
    func getWeight() -> Double {
        return RecipeUnit.unitValue[self]!.weight
    }
    
    func getVolume() -> Double {
        return RecipeUnit.unitValue[self]!.volume
    }
    
    static let standardString: [RecipeUnit: String] = [
        .Each: "",
        .Gram: "g".localize(),
        .Kilogram: "kg".localize(),
        .Pound: "lb".localize(),
        .Ounce: "oz".localize(),
        .Floz: "fl oz".localize(),
        .ImperialFloz: "imp fl oz".localize(),
        .Teaspoon: "tsp".localize(),
        .ImperialTsp: "imp tsp".localize(),
        .Tablespoon: "Tbsp".localize(),
        .ImperialTbsp: "imp Tbsp".localize(),
        .Milliliter: "ml".localize(),
        .Liter: "L".localize(),
        .Cup: "cup".localize(),
        .Pint: "pt".localize(),
        .ImperialPint: "imp pt".localize(),
        .Quart: "qt".localize(),
        .ImperialQuart: "imp qt".localize(),
        .Gallon: "gal".localize(),
        .ImperialGallon: "imp gal".localize()
    ]
    func getString() -> String {
        return RecipeUnit.standardString[self]!
    }
    func allowsFractions() -> Bool {
        switch self {
        case .Each, .Pound, .Ounce, .Floz, .Teaspoon, .Tablespoon, .Cup, .Pint, .Quart, .Gallon:
            return true
        case .ImperialFloz, .ImperialTsp, .ImperialTbsp, .ImperialPint, .ImperialQuart, .ImperialGallon:
            return true
        case .Gram, .Kilogram, .Milliliter, .Liter:
            return false
        }
    }
    
    static func optimizeUnit(quantity: Double, unit: RecipeUnit) -> (Double, RecipeUnit) {
  //      var standardQuantity = quantity * RecipeUnit.unitValue[unit]!
        //        if unit.unitType ==
        return (quantity, unit)
    }
    
    // TODO: need to handle variants (e.g. "c.", "pint", etc.)
    static func fromString(unitAsString: String) -> RecipeUnit? {
        for unit in allValues {
            if unit.getString() == unitAsString {
                return unit
            }
        }
        return nil
    }
}

