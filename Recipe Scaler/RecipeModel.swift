//
//  RecipeModel.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 7/28/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import Foundation
import UIKit

class RecipeItem: NSObject, NSCoding, Equatable {
    var name: String
    var quantity: Double
    var unitAsString: String {
        get {
   //         if unit != nil {
                return unit.getString()
     /*       }
            else {
                return ""
            }
         */
        }
    }
    var unit: RecipeUnit

    
    required init(coder aDecoder: NSCoder) {
        let version = aDecoder.decodeIntForKey("version")
        switch version {
        default:    // version 1
            self.name = aDecoder.decodeObjectForKey("name") as String
            self.quantity = aDecoder.decodeObjectForKey("quantity") as Double
            if let string = RecipeUnit.fromString(aDecoder.decodeObjectForKey("unit") as String) {
                self.unit = string
            } else {
                self.unit = RecipeUnit.Each
            }
        }
    }

    init(name: String, quantity: Double, unit: RecipeUnit?) {
        self.name = name
        self.quantity = quantity
        if unit != nil {
            self.unit = unit!
        } else {
            self.unit = RecipeUnit.Each
        }
    }
    
    init(name: String, quantityOfUnit: String) {
        self.name = name
        self.quantity = (quantityOfUnit as NSString).doubleValue
        self.unit = RecipeUnit.Each
    }
    
    init(item: RecipeItem) {
        self.name = item.name
        self.quantity = item.quantity
        self.unit = item.unit
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt(1, forKey: "version")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.quantity, forKey: "quantity")
        aCoder.encodeObject(self.unitAsString, forKey: "unit")
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
    
    override init() {
        items = []
        name = ""
    }
    required init(coder aDecoder: NSCoder) {
        let version = aDecoder.decodeIntForKey("version")
        switch version {
        default:    // version 1
            self.name = aDecoder.decodeObjectForKey("name") as String
            if let items: AnyObject = aDecoder.decodeObjectForKey("items") {
                self.items = items as [RecipeItem]
            }
        }
    }
    
    init(recipe:Recipe)
    {
        self.name = recipe.name
        for item in items {
            self.items.append(RecipeItem(item: item))
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt(1, forKey: "version")
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
// TODO: smart printing of fractions
// TODO: optimize units (e.g. 4 cups => 1 gallon)
        var retval = ""
        if index < itemCount {
            retval = "\(Int(items[index].quantity))"
 
            let unit = items[index].unit
            retval += " \(RecipeUnit.standardString[unit]!)"

        }

        return retval
    }
    
    func getIngredientUnit(index: Int) -> RecipeUnit? {
        return items[index].unit
    }
    
    func scaleBy(amount: Double) {
        for index in 0..<items.count {
            items[index].scaleBy(amount)
        }
    }
    
    func scaleToUse(availableItem: RecipeItem) -> RecipeError? {
        var qtyInRecipe = 0.0
        var weightInRecipe = 0.0
        var volumeInRecipe = 0.0
        
        var lowercaseName = availableItem.name
        lowercaseName = lowercaseName.lowercaseString
//TODO: sanity check units for all volume or all weight
        for item in self.items {
            if item.name.lowercaseString == availableItem.name.lowercaseString {
                let unit = item.unit
                
                if unit.getWeight() != 0 {
                    weightInRecipe += item.quantity * unit.getWeight()
                } else if unit.getVolume() != 0 {
                    volumeInRecipe += item.quantity * unit.getVolume()
                } else {
                    qtyInRecipe += item.quantity
                }
            }
        }
        let unit = availableItem.unit
        if unit.getWeight() != 0 {
            if weightInRecipe != 0 {
                self.scaleBy(availableItem.quantity * unit.getWeight() / weightInRecipe)
            } else {
                return RecipeError.DivideByZero(name: availableItem.name)
            }
        } else if unit.getVolume() != 0 {
            if volumeInRecipe != 0 {
                self.scaleBy(availableItem.quantity * unit.getVolume() / volumeInRecipe)
            } else {
                return RecipeError.DivideByZero(name: availableItem.name)
            }
        } else {
            if qtyInRecipe != 0 {
                self.scaleBy(availableItem.quantity/qtyInRecipe)
            } else {
                return RecipeError.DivideByZero(name: availableItem.name)
            }
        }
        
        // if any two of (weight, volume, qty) are non-zero results are probably not what they want
        if (weightInRecipe * volumeInRecipe != 0) || (volumeInRecipe * qtyInRecipe != 0) || (weightInRecipe * qtyInRecipe != 0) {
            return RecipeError.MultipleUnitTypes(name: availableItem.name)
        }
        
        return nil
    }
    
    func getScaledToUse(availableItem: RecipeItem) -> (recipe: Recipe, error: RecipeError?) {
        // first copy
        var scaledRecipe = Recipe(recipe: self)
        for item in items {
            scaledRecipe.addItem(RecipeItem(item: item))
        }
        // then scale
        let error = scaledRecipe.scaleToUse(availableItem)
        return (scaledRecipe, error)
    }
}

class RecipeList : NSObject, NSCoding {
    var recipes: [Recipe] = []
    
    var count: Int {
    get {
        return recipes.count
    }
    }
    
    override init() {
        recipes = []
    }
    required init(coder aDecoder: NSCoder) {
        let version = aDecoder.decodeIntForKey("version")
        switch version {
        default:    // version 1
            recipes = aDecoder.decodeObjectForKey("recipes") as [Recipe]
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt(1, forKey: "version")
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
        NSKeyedArchiver.archiveRootObject(self, toFile: path!)
    }
    
    class func load(url: NSURL) -> RecipeList {
        let path = url.URLByAppendingPathComponent("recipe_list.archive").path
        if let obj: AnyObject = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) {
            return obj as RecipeList
        }
        else {
            return RecipeList() // Archive file doesn't exist so start with empty list
        }
    }
}

