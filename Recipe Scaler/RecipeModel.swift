//
//  RecipeModel.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 7/28/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var doubleValueFromFraction: Double {
        get {
            if let fractionDivider = self.characters.indexOf("/") {
                let denominator = (self.substringFromIndex(fractionDivider.successor()) as NSString).doubleValue
                let restOfString = self.substringToIndex(fractionDivider)
                if let wholeDivider = restOfString.characters.indexOf(" ") {
                    let numerator = (restOfString.substringFromIndex(wholeDivider.successor()) as NSString).doubleValue
                    let whole = (restOfString.substringToIndex(wholeDivider) as NSString).doubleValue
                    if denominator != 0 {
                        return whole + (numerator / denominator)
                    } else {
                        return whole
                    }
                } else {
                    let numerator = (restOfString as NSString).doubleValue
                    if denominator != 0 {
                        return numerator / denominator
                    } else {
                        return 0
                    }
                }
            } else {
                var numberString: String
                if let space = self.characters.indexOf(" ") {
                    numberString = self.substringToIndex(space)
                }
                else {
                    numberString = self
                }
                numberString = String(map(numberString.generate()) {
                    $0 == "," ? "." : $0
                })
                return (numberString as NSString).doubleValue
            }
        }
    }
}

extension Double {
    func format() -> String {
        return NSString(format: "%.1f", locale: NSLocale.currentLocale(), self) as String
    }
}

extension String {
    func matches(item: String, withQuantity: Double, thisQuantity: Double) -> Bool {
        var ret = false
        if self.lowercaseString == item.lowercaseString {
            ret = true
        }
        if (withQuantity == 1.0) && (self.lowercaseString == item.lowercaseString.pluralize()) {
            ret = true
        }
        if (thisQuantity == 1.0) && (self.lowercaseString.pluralize() == item.lowercaseString) {
            ret = true
        }
        return ret
    }
}

extension String {
    init(recipe: Recipe) {
        self = "\(recipe.name)\n\n"
        for item in recipe.items {
            self += item.quantityAsString
            if item.unit != RecipeUnit.Each {
                self += " \(item.unit.string)"
            }
            self += " \(item.name)\n"
        }
    }
}

class RecipeItem: NSObject, NSCoding {
    var name: String
    var quantity: Double
    var unit: RecipeUnit
    var quantityAsString: String {
        get {
            var retval: String
            if self.unit.allowsFractions {
                let intQuantity = Int(self.quantity)
                let fractionalQuantity = self.quantity % 1
                if intQuantity == 0 {
                    switch fractionalQuantity {
                    case 0..<1/16:
                        retval = ""
                    case 1/16..<3/16:
                        retval = "1/8"
                    case 3/16..<7/24:
                        retval = "1/4"
                    case 7/24..<5/12:
                        retval = "1/3"
                    case 5/12..<7/12:
                        retval = "1/2"
                    case 7/12..<17/24:
                        retval = "2/3"
                    case 17/24..<7/8:
                        retval = "3/4"
                    case 7/8..<1:
                        retval = "1"
                    default:
                        retval = ""
                    }
                } else {
                    switch fractionalQuantity {
                    case 0..<1/16:
                        retval = "\(intQuantity)"
                    case 1/16..<3/16:
                        retval = "\(intQuantity) 1/8"
                    case 3/16..<7/24:
                        retval = "\(intQuantity) 1/4"
                    case 7/24..<5/12:
                        retval = "\(intQuantity) 1/3"
                    case 5/12..<7/12:
                        retval = "\(intQuantity) 1/2"
                    case 7/12..<17/24:
                        retval = "\(intQuantity) 2/3"
                    case 17/24..<7/8:
                        retval = "\(intQuantity) 3/4"
                    case 7/8..<1:
                        retval = "\(intQuantity + 1)"
                    default:
                        retval = ""
                    }
                }
            } else if self.quantity < 10 {
                retval = "\(self.quantity.format())"
            } else {
                retval = "\(Int(self.quantity))"
            }
            return retval
        }
    }
    var unitAsString: String {
        get {
            return unit.string
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        let version = aDecoder.decodeIntForKey("version")
        switch version {
        default:    // version 1
            self.name = aDecoder.decodeObjectForKey("name") as! String
            self.quantity = aDecoder.decodeObjectForKey("quantity")as! Double
            if let unit = RecipeUnit(rawValue: aDecoder.decodeObjectForKey("unit") as! String) {
                self.unit = unit
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
    
    init(name: String, quantityAsString: String, unit: RecipeUnit?) {
        self.name = name
        self.quantity = quantityAsString.doubleValueFromFraction
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
    
    init(textLine: String) {
        self.quantity = textLine.doubleValueFromFraction
        let trimSet = NSMutableCharacterSet.decimalDigitCharacterSet()
        trimSet.formUnionWithCharacterSet(NSCharacterSet.whitespaceCharacterSet())
        trimSet.formUnionWithCharacterSet(NSCharacterSet.punctuationCharacterSet())
        let notQuantity = textLine.stringByTrimmingCharactersInSet(trimSet)
        let (unit, index) = RecipeUnit.fromString(notQuantity)
        if unit != nil {
            self.unit = unit!
        }
        else {
            self.unit = RecipeUnit.Each
        }
        self.name = notQuantity.substringFromIndex(notQuantity.startIndex.advancedBy(index)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
}
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt(1, forKey: "version")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.quantity, forKey: "quantity")
        aCoder.encodeObject(self.unit.rawValue, forKey: "unit")
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
    var scaleToItem: RecipeItem?
    var name: String = ""
    
    var itemCount: Int {
    get {
        return items.count
    }
    }
    
    override init() {
        self.items = []
        self.name = ""
    }
    required init?(coder aDecoder: NSCoder) {
        let version = aDecoder.decodeIntForKey("version")
        switch version {
        default:    // version 1 or 2
            self.name = aDecoder.decodeObjectForKey("name") as! String
            if let items: AnyObject = aDecoder.decodeObjectForKey("items") {
                self.items = items as! [RecipeItem]
            }
            if let item: AnyObject = aDecoder.decodeObjectForKey("scaler") {
                self.scaleToItem = item as? RecipeItem
            }
        }
    }
    
    init(recipe:Recipe) {
        self.name = recipe.name
        for item in items {
            self.items.append(RecipeItem(item: item))
        }
    }
    
    init(textLines: [String]) {
        self.name = textLines[0]
        for line in textLines[1..<textLines.count] {
            if line != "" {
                self.items.append(RecipeItem(textLine: line))
            }
        }
    }
    
    convenience init(fromString: String) {
        self.init(textLines: fromString.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()))
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInt(2, forKey: "version")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.items, forKey: "items")
        if (self.scaleToItem != nil) {
            aCoder.encodeObject(self.scaleToItem!, forKey: "scaler")
        }
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
// TODO: optimize units (e.g. 4 cups => 1 gallon) - though this may be more appropriate as didset() function for quantity and unit in RecipeItem class
        var retval = ""
        if index < itemCount {
            retval = items[index].quantityAsString
            let unit = items[index].unit
            retval += " \(unit.string)"

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
        
//TODO: sanity check units for all volume or all weight
        for item in self.items {
            if item.name.matches(availableItem.name, withQuantity: availableItem.quantity,
                                thisQuantity: item.quantity) {
                let unit = item.unit
                
                if unit.weight != 0 {
                    weightInRecipe += item.quantity * unit.weight
                } else if unit.volume != 0 {
                    volumeInRecipe += item.quantity * unit.volume
                } else {
                    qtyInRecipe += item.quantity
                }
            }
        }
        
        // if any two of (weight, volume, qty) are non-zero results are probably not what they want
        if (weightInRecipe * volumeInRecipe != 0) || (volumeInRecipe * qtyInRecipe != 0) || (weightInRecipe * qtyInRecipe != 0) {
            return RecipeError.MultipleUnitTypes(name: availableItem.name)
        }
        
        let unit = availableItem.unit
        if unit.weight != 0 {
            if weightInRecipe != 0 {
                self.scaleBy(availableItem.quantity * unit.weight / weightInRecipe)
            }
            else if volumeInRecipe != 0 || qtyInRecipe != 0 {
                return RecipeError.MultipleUnitTypes(name: availableItem.name)
            }
            else {
                return RecipeError.DivideByZero(name: availableItem.name)
            }
        } else if unit.volume != 0 {
            if volumeInRecipe != 0 {
                self.scaleBy(availableItem.quantity * unit.volume / volumeInRecipe)
            }
            else if weightInRecipe != 0 || qtyInRecipe != 0 {
                return RecipeError.MultipleUnitTypes(name: availableItem.name)
            }
            else {
                return RecipeError.DivideByZero(name: availableItem.name)
            }
        } else {
            if qtyInRecipe != 0 {
                self.scaleBy(availableItem.quantity/qtyInRecipe)
            }
            else if weightInRecipe != 0 || volumeInRecipe != 0 {
                return RecipeError.MultipleUnitTypes(name: availableItem.name)
            }
            else {
                return RecipeError.DivideByZero(name: availableItem.name)
            }
        }
        
        return nil
    }
    
    func getScaledToUse(availableItem: RecipeItem) -> (recipe: Recipe, error: RecipeError?) {
        // first copy
        let scaledRecipe = Recipe(recipe: self)
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
    required init?(coder aDecoder: NSCoder) {
        let version = aDecoder.decodeIntForKey("version")
        switch version {
        default:    // version 1
            recipes = aDecoder.decodeObjectForKey("recipes") as! [Recipe]
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
    
    func remove(recipe: Recipe) {
        for index in 0..<self.count {
            if recipes[index] == recipe {
                recipes.removeAtIndex(index)
                break
            }
        }
    }
    
    func getRecipeIndex(recipe: Recipe) -> Int? {
        for index in 0..<self.count {
            if recipes[index] == recipe {
                return index
            }
        }
        return nil
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
            return obj as! RecipeList
        }
        else {
            return RecipeList() // Archive file doesn't exist so start with empty list
        }
    }
}

