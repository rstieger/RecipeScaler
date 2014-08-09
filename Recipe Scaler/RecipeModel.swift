//
//  RecipeModel.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 7/28/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import Foundation

enum RecipeUnit {
    case each
    case gram, kilogram, pound, ounce
    case fluid_ounce, teaspoon, tablespoon, milliliter, liter, cup, pint, quart, gallon
    
    func toString() -> String {
        switch self {
        case .each: return ""
        case .gram: return "g"
        case .kilogram: return "kg"
        case .pound: return "lb"
        case .ounce: return "oz"
        case .fluid_ounce: return "fl oz"
        case .teaspoon: return "tsp"
        case .tablespoon: return "Tbsp"
        case .milliliter: return "ml"
        case .liter: return "L"
        case .cup: return "cup"
        case .pint: return "pint"
        case .quart: return "quart"
        case .gallon: return "gal"
        default: return ""
        }
    }
/*
    class func fromString(unit: String) -> RecipeUnit {
        if unit.bridgeToObjectiveC().containsString("c")
            case
        }
    }
*/
}

struct RecipeItem: Equatable {
    var name: String
    var quantity = 0.0
    var unit: RecipeUnit?
    
    init(name: String, quantity: Double, unit: RecipeUnit?) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
    
    init(name: String, quantityOfUnit: String) {
        self.name = name
        self.quantity = quantityOfUnit.bridgeToObjectiveC().doubleValue
        self.unit = nil
    }
    
    mutating func scaleBy(amount: Double) {
        quantity = quantity * amount
    }
}

func == (lhs: RecipeItem, rhs: RecipeItem) -> Bool {
    return lhs.name == rhs.name && lhs.quantity == rhs.quantity && lhs.unit == rhs.unit
}


class RecipeModel {
    var items: Array<RecipeItem> = []
    var name: String?
    
    var itemCount: Int {
    get {
        return items.count
    }
    }
    
    init() {
    }
    
    func addItem(item: RecipeItem) {
        items.append(item)
    }
    
    func deleteItem(item: RecipeItem) {
        for index in 0..<items.count {
            if items[index] == item {
                items.removeAtIndex(index)
                break;
            }
        }
    }
    
    func getIngredientName(index: Int) -> String {
        return items[index].name
    }
    
    func getIngredientQuantity(index: Int) -> String {
        var retval = ""
        if index < itemCount {
            retval = "\(Int(items[index].quantity))"
            if items[index].unit {
                retval = "\(Int(items[index].quantity)) \(items[index].unit!.toString())"
            }
        }
        return retval
    }
    
    
    func scaleBy(amount: Double) {
        for index in 0..<items.count {
            items[index].scaleBy(amount)
        }
    }
    
    func scaleToUse(availableItem: RecipeItem) {
        var qtyInRecipe = 0.0
        
        var lowercaseName = availableItem.name
        lowercaseName = lowercaseName.lowercaseString
        
        for item in self.items {
            if item.name.lowercaseString == availableItem.name.lowercaseString {
                qtyInRecipe += item.quantity
            }
        }
        if qtyInRecipe != 0 {
            self.scaleBy(availableItem.quantity/qtyInRecipe)
        }

    }
    
    func getScaledToUse(availableItem: RecipeItem?) -> RecipeModel {
        // first copy
        var scaledRecipe = RecipeModel()
        for item in items {
            scaledRecipe.addItem(item)
        }
        // then scale
        if availableItem {
            scaledRecipe.scaleToUse(availableItem!)
        }
        return scaledRecipe
    }
}