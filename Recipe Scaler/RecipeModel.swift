//
//  RecipeModel.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 7/28/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import Foundation
import UIKit
import CoreData

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

class RecipeItem: NSObject, NSCoding, Equatable {
    var name: String
    var quantity: Double
    var unitAsString: String
    var unit: RecipeUnit? {
    didSet {
        if unit {
            unitAsString = unit!.toString()
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
        if let items = aDecoder.decodeObjectForKey("items") {
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
        return NSKeyedUnarchiver.unarchiveObjectWithFile(path) as RecipeList
    }
}

