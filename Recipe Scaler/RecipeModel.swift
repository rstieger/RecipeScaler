//
//  RecipeModel.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 7/28/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import Foundation
import UIKit

enum UnitType {
    case Volume, Weight
}

enum RecipeUnit {
    case Each
    case Gram, Kilogram, Pound, Ounce
    case Floz, Teaspoon, Tablespoon, Milliliter, Liter, Cup, Pint, Quart, Gallon
    
    static let allValues = [Each, Gram, Kilogram, Pound, Ounce, Floz, Teaspoon, Tablespoon, Milliliter, Liter, Cup, Pint, Quart, Gallon]
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
    static func optimizeUnit(quantity: Double, unit: RecipeUnit) -> (Double, RecipeUnit) {
        var standardQuantity = quantity * RecipeUnit.unitValue[unit]!
//        if unit.unitType ==
        return (quantity, unit)
    }
    /*
    class func fromString(unit: String) -> RecipeUnit {
    if unit.bridgeToObjectiveC().containsString("c")
    case
    }
    }
    */
}

class RecipeItem: NSObject, NSCoding, Equatable {
    var name: String
    var quantity: Double
    var unitAsString: String
    var unit: RecipeUnit? {
    didSet {
        if unit {
            unitAsString = RecipeUnit.standardString[unit!]!
        }
        else {
            unitAsString = ""
        }
    }
    }
    
    init(coder aDecoder: NSCoder!) {
        self.name = aDecoder.decodeObjectForKey("name") as String
        self.quantity = aDecoder.decodeObjectForKey("quantity") as Double
        self.unitAsString = ""
        self.unit = nil
    }

    init(name: String, quantity: Double, unit: RecipeUnit?) {
        self.name = name
        self.quantity = quantity
        self.unitAsString = ""
        self.unit = unit
    }
    
    init(name: String, quantityOfUnit: String) {
        self.name = name
        self.quantity = quantityOfUnit.bridgeToObjectiveC().doubleValue
        self.unitAsString = ""
        self.unit = nil
    }
    
    init(item: RecipeItem) {
        self.name = item.name
        self.quantity = item.quantity
        self.unitAsString = item.unitAsString
        self.unit = item.unit
    }
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(quantity, forKey: "quantity")
    }

    func scaleBy(amount: Double) {
        quantity = quantity * amount
    }
}

func == (lhs: RecipeItem, rhs: RecipeItem) -> Bool {
    return lhs.name == rhs.name && lhs.quantity == rhs.quantity && lhs.unit == rhs.unit
}

class Recipe : NSObject, NSCoding{
    var items: [RecipeItem] = []
    var name: String = ""
    
    var itemCount: Int {
    get {
        return items.count
    }
    }
    
    init() {
        items = []
        name = ""
    }
    init(coder aDecoder: NSCoder!) {
        self.name = aDecoder.decodeObjectForKey("name") as String
        if let items: AnyObject = aDecoder.decodeObjectForKey("items") {
            self.items = items as [RecipeItem]
        }
    }
    
    init(recipe:Recipe)
    {
        self.name = recipe.name
        for item in items {
            self.items.append(RecipeItem(item: item))
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(items, forKey: "items")
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
            if let unit = items[index].unit {
                retval += " \(RecipeUnit.standardString[unit]!)"
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
    
    func getScaledToUse(availableItem: RecipeItem?) -> Recipe {
        // first copy
        var scaledRecipe = Recipe(recipe: self)
        for item in items {
            scaledRecipe.addItem(RecipeItem(item: item))
        }
        // then scale
        if availableItem {
            scaledRecipe.scaleToUse(availableItem!)
        }
        return scaledRecipe
    }
}

class RecipeList : NSObject, NSCoding {
    var recipes: [Recipe] = []
    
    var count: Int {
    get {
        return recipes.count
    }
    }
    
    init() {
        recipes = []
    }
    init(coder aDecoder: NSCoder!) {
        recipes = aDecoder.decodeObjectForKey("recipes") as [Recipe]
    }
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(recipes, forKey: "recipes")
    }
    
    func append(recipe: Recipe) {
        recipes.append(recipe)
    }
    
    func removeAtIndex(index: Int) {
        recipes.removeAtIndex(index)
    }
    
    subscript(index : Int) -> Recipe {
        get {
            return recipes[index]
        }
    }
    
    func save(url: NSURL) {
        let path = url.URLByAppendingPathComponent("recipe_list.archive").path
        NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }
    
    class func load(url: NSURL) -> RecipeList {
        let path = url.URLByAppendingPathComponent("recipe_list.archive").path
        if let obj: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithFile(path) {
            return obj as RecipeList
        }
        else {
            return RecipeList() // Archive file doesn't exist so start with empty list
        }
    }
}

