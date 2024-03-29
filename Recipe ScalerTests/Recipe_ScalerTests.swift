//
//  Recipe_ScalerTests.swift
//  Recipe ScalerTests
//
//  Created by Ron Stieger on 7/6/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import XCTest

class Recipe_ScalerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testRecipeScaleItemUp() {
        let item = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        item.scaleBy(2.0)
        XCTAssert(item.quantity == 8.0)
    }
    
    func testRecipeScaleItemDown() {
        let item = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        item.scaleBy(0.5)
        XCTAssert(item.quantity == 2.0)
    }
    
    func testRecipeAddItem() {
        let item = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(item)
        XCTAssert(recipe.itemCount == 1)
        XCTAssert(recipe.items[0].name == "Eggs")
    }
    
    func testRecipeAddItems() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(recipe.itemCount == 2)
        XCTAssert(recipe.items[0].name == "Eggs")
        XCTAssert(recipe.items[1].name == "Milk")
    }
    
    func testRecipeScaleUp() {
        let eggs = RecipeItem(name: "Eggs", quantity: 2.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 1.5, unit: RecipeUnit.Cup)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleBy(2.0)
        XCTAssert(recipe.items[0].quantity == 4.0)
        XCTAssert(recipe.items[1].quantity == 3.0)
    }
    
    func testRecipeScaleDown() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleBy(0.5)
        XCTAssert(recipe.items[0].quantity == 2.0)
        XCTAssert(recipe.items[1].quantity == 1.5)
    }

    func testRecipeScaleToUseUp() {
        let eggs = RecipeItem(name: "Eggs", quantity: 2.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 1.5, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 4.0)
        XCTAssert(recipe.items[1].quantity == 3.0)
    }
    
    func testRecipeScaleToUseDown() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 2.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 2.0)
        XCTAssert(recipe.items[1].quantity == 1.5)
    }

    func testRecipeScaleToUseWithZero() {
        let eggs = RecipeItem(name: "Eggs", quantity: 0.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 2.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 0.0)
        XCTAssert(recipe.items[1].quantity == 3.0)
    }
    
    func testRecipeScaleToUseWithMultipleLines() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let eggs2 = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.addItem(eggs2)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 2.0)
        XCTAssert(recipe.items[1].quantity == 1.5)
    }
    
    func testRecipeScaleToUseWithDifferentCase() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let eggs2 = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "eggs", quantity: 4.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.addItem(eggs2)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 2.0)
        XCTAssert(recipe.items[1].quantity == 1.5)
    }
    
    func testRecipeDeleteItem() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.deleteItem(eggs)
        XCTAssert(recipe.itemCount == 1)
        XCTAssert(recipe.items[0].name == milk.name)
    }
    
    func testRecipeGetIngredientName() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(recipe.getIngredientName(0) == eggs.name)
        XCTAssert(recipe.getIngredientName(1) == milk.name)
    }
    
    func testRecipeGetIngredientQuantityIntegerNoUnits() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(recipe.getIngredientQuantity(0) == "4 ")
    }
    
    func testRecipeGetIngredientQuantityIntegerWithUnits() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(recipe.getIngredientQuantity(1) == "3 cup")
    }
    
    func testRecipeItemQuantityString() {
        let item = RecipeItem(name: "Eggs", quantityOfUnit: "4")
        XCTAssert(item.name == "Eggs")
        XCTAssert(item.quantity == 4.0)
        XCTAssert(item.unit == RecipeUnit.Each)
    }
    
    func testRecipeCopyAndScale() {
        let eggs = RecipeItem(name: "Eggs", quantity: 2.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 1.5, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        let (scaledRecipe, _) = recipe.getScaledToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 2.0)
        XCTAssert(recipe.items[1].quantity == 1.5)
        XCTAssert(scaledRecipe.items[0].quantity == 4.0)
        XCTAssert(scaledRecipe.items[1].quantity == 3.0)
    }
/*
func testRecipeItemQuantityAndUnitString() {
        let item = RecipeItem(name: "Milk", quantityOfUnit: "3 cup")
        XCTAssert(item.name == "Milk")
        XCTAssert(item.quantity == 3.0)
        XCTAssert(item.unit == RecipeUnit.cup)
    }
*/
    func testRecipeScaleToUseWithDifferentUnits() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 2.0, unit: RecipeUnit.Cup)
        let milkIHave = RecipeItem(name: "Milk", quantity: 1.0, unit: RecipeUnit.Pint)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(milkIHave)
        XCTAssert(recipe.items[0].quantity == 4.0)
        XCTAssert(recipe.items[1].quantity == 2.0)
    }

    func testRecipeScaleToUseWithZeroReturnsError() {
        let eggs = RecipeItem(name: "Eggs", quantity: 0.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 2.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        let error: RecipeError? = recipe.scaleToUse(eggsIHave)
        XCTAssert(error == RecipeError.DivideByZero(name: "Eggs"))
    }
    
    func testRecipeScaleToUseWithIncompatibleUnitsReturnsError() {
        let eggs = RecipeItem(name: "Eggs", quantity: 0.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let milkIHave = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Pound)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        let error: RecipeError? = recipe.scaleToUse(milkIHave)
        XCTAssert(error == RecipeError.MultipleUnitTypes(name: "Milk"))
    }
    
    
    func testRecipeScaleToOneHalf() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 2.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 1.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.getIngredientQuantity(1) == "1/2 cup")
    }
    
    func testRecipeItemQuantityOneHalf() {
        let milk = RecipeItem(name: "Milk", quantityAsString: "1/2", unit: RecipeUnit.Cup)
        XCTAssert(milk.quantity == 0.5)
    }

    func testRecipeItemQuantityOneAndOneHalf() {
        let milk = RecipeItem(name: "Milk", quantityAsString: "1 1/2", unit: RecipeUnit.Cup)
        XCTAssert(milk.quantity == 1.5)
    }

    func testRecipeItemQuantityKilogramHalf() {
        let butter = RecipeItem(name: "Butter", quantity: 0.5, unit: RecipeUnit.Kilogram)
        XCTAssert(butter.quantityAsString == "0.5")
    }
    func testRecipeItemQuantityStringOne() {
        let milk = RecipeItem(name: "Milk", quantityAsString: "1", unit: RecipeUnit.Cup)
        XCTAssert(milk.quantity == 1.0)
    }

    func testRecipeItemQuantityDenominatorZero() {
        let milk = RecipeItem(name: "Milk", quantityAsString: "1/0", unit: RecipeUnit.Cup)
        XCTAssert(milk.quantity == 0)
    }

    func testRecipeItemQuantityDenominatorZeroWithWhole() {
        let milk = RecipeItem(name: "Milk", quantityAsString: "1 1/0", unit: RecipeUnit.Cup)
        XCTAssert(milk.quantity == 1)
    }
    
    func testRecipeScalePluralInScaler() {
        let eggs = RecipeItem(name: "Egg", quantity: 1.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 1.5, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 2.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 2.0)
        XCTAssert(recipe.items[1].quantity == 3.0)
    }
    
    func testRecipeScalePluralInRecipe() {
        let eggs = RecipeItem(name: "Eggs", quantity: 2.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Egg", quantity: 1.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 1.0)
        XCTAssert(recipe.items[1].quantity == 1.5)
    }
    
    func testRecipeItemFromStringWithUnit() {
        let milk = RecipeItem(textLine: "1 cup milk")
        XCTAssert(milk.name == "milk")
        XCTAssert(milk.quantity == 1.0)
        XCTAssert(milk.unit == RecipeUnit.Cup)
    }
    
    func testRecipeItemFromStringNoUnit() {
        let eggs = RecipeItem(textLine: "2 eggs")
        XCTAssert(eggs.name == "eggs")
        XCTAssert(eggs.quantity == 2.0)
        XCTAssert(eggs.unit == RecipeUnit.Each)
    }
    
    func testRecipeItemFromStringWithFractionalUnit() {
        let milk = RecipeItem(textLine: "1 1/2 cup milk")
        XCTAssert(milk.name == "milk")
        XCTAssert(milk.quantity == 1.5)
        XCTAssert(milk.unit == RecipeUnit.Cup)
    }
    
    func testRecipeItemFromStringMultipleWords() {
        let sugar = RecipeItem(textLine: "3/4 cup powdered sugar")
        XCTAssert(sugar.name == "powdered sugar")
        XCTAssert(sugar.quantity == 0.75)
        XCTAssert(sugar.unit == RecipeUnit.Cup)
    }
    
    func testRecipeFromStrings() {
        let lines: [String] = ["Test Recipe", "1 1/2 cup milk", "2 eggs", "3/4 cup powdered sugar"]
        let recipe = Recipe(textLines: lines)
        XCTAssert(recipe.name == "Test Recipe")
        XCTAssert(recipe.itemCount == 3)
        XCTAssert(recipe.getIngredientName(0) == "milk")
        XCTAssert(recipe.getIngredientName(1) == "eggs")
        XCTAssert(recipe.getIngredientName(2) == "powdered sugar")
        XCTAssert(recipe.getIngredientQuantity(0) == "1 1/2 cup")
        XCTAssert(recipe.getIngredientQuantity(1) == "2 ")
        XCTAssert(recipe.getIngredientQuantity(2) == "3/4 cup")
    }
    
    func testRecipeFromStringsSkipBlanks() {
        let lines: [String] = ["Test Recipe", "", "1 1/2 cup milk", "2 eggs", "3/4 cup powdered sugar", ""]
        let recipe = Recipe(textLines: lines)
        XCTAssert(recipe.name == "Test Recipe")
        XCTAssert(recipe.itemCount == 3)
        XCTAssert(recipe.getIngredientName(0) == "milk")
        XCTAssert(recipe.getIngredientName(1) == "eggs")
        XCTAssert(recipe.getIngredientName(2) == "powdered sugar")
        XCTAssert(recipe.getIngredientQuantity(0) == "1 1/2 cup")
        XCTAssert(recipe.getIngredientQuantity(1) == "2 ")
        XCTAssert(recipe.getIngredientQuantity(2) == "3/4 cup")
    }
    
    func testRecipeFromStringWithIngredients() {
        let lines = "Test Recipe\n\n1 1/2 cup milk\n2 eggs\n3/4 cup powdered sugar\n"
        let recipe = Recipe(fromString: lines)
        XCTAssert(recipe.name == "Test Recipe")
        XCTAssert(recipe.itemCount == 3)
        XCTAssert(recipe.getIngredientName(0) == "milk")
        XCTAssert(recipe.getIngredientName(1) == "eggs")
        XCTAssert(recipe.getIngredientName(2) == "powdered sugar")
        XCTAssert(recipe.getIngredientQuantity(0) == "1 1/2 cup")
        XCTAssert(recipe.getIngredientQuantity(1) == "2 ")
        XCTAssert(recipe.getIngredientQuantity(2) == "3/4 cup")        
    }

    func testRecipeToString() {
        let eggs = RecipeItem(name: "Eggs", quantity: 2.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let recipe = Recipe()
        recipe.name = "Test"
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(String(recipe: recipe) == "Test\n\n2 Eggs\n3 cup Milk\n")
    }
    
    func testRecipeToStringNull() {
        let recipe = Recipe()
        XCTAssert(String(recipe: recipe) == "\n\n")
    }
    
    func testRecipeRemoveNull() {
        let recipes = RecipeList()
        let recipe = Recipe()
        recipes.remove(recipe)
        XCTAssert(recipes.count == 0)
    }
    
    func testRecipeRemoveOne() {
        let recipes = RecipeList()
        let recipe = Recipe()
        recipes.append(recipe)
        recipes.remove(recipe)
        XCTAssert(recipes.count == 0)
    }
    
    func testRecipeRemoveFirst() {
        let recipes = RecipeList()
        let recipe = Recipe()
        recipes.append(recipe)
        recipes.append(Recipe())
        recipes.append(Recipe())
        recipes.remove(recipe)
        XCTAssert(recipes.count == 2)
    }
    
    func testRecipeRemoveLast() {
        let recipes = RecipeList()
        let recipe = Recipe()
        recipes.append(Recipe())
        recipes.append(Recipe())
        recipes.append(recipe)
        recipes.remove(recipe)
        XCTAssert(recipes.count == 2)
    }
    
    func testRecipeRemoveMiddle() {
        let recipes = RecipeList()
        let recipe = Recipe()
        recipes.append(Recipe())
        recipes.append(recipe)
        recipes.append(Recipe())
        recipes.remove(recipe)
        XCTAssert(recipes.count == 2)
    }
    
    func testGetRecipeIndex() {
        let recipes = RecipeList()
        let recipe = Recipe(fromString: "test")
        recipes.append(Recipe())
        recipes.append(recipe)
        recipes.append(Recipe())
        XCTAssert(recipes.getRecipeIndex(recipe) == 1)
    }
    
    func testGetRecipeIndexNil() {
        let recipes = RecipeList()
        let recipe = Recipe(fromString: "test")
        recipes.append(Recipe())
        recipes.append(Recipe())
        XCTAssert(recipes.getRecipeIndex(recipe) == nil)
    }
    
    func testGetUnitsUS() {
        let units = RecipeUnit.getAllValues([.US])
        XCTAssert(units.contains(.Each))
        XCTAssert(units.contains(.Cup))
        XCTAssertFalse(units.contains(.ImperialPint))
        XCTAssertFalse(units.contains(.Gram))
    }
    
    func testGetUnitsUK() {
        let units = RecipeUnit.getAllValues([.UK])
        XCTAssert(units.contains(.Each))
        XCTAssertFalse(units.contains(.Cup))
        XCTAssert(units.contains(.ImperialPint))
        XCTAssertFalse(units.contains(.Gram))
    }
    
    func testGetUnitsMetric() {
        let units = RecipeUnit.getAllValues([.Metric])
        XCTAssert(units.contains(.Each))
        XCTAssertFalse(units.contains(.Cup))
        XCTAssertFalse(units.contains(.ImperialPint))
        XCTAssert(units.contains(.Gram))
    }
    
    func testGetUnitsUSandUK() {
        let units = RecipeUnit.getAllValues([.US, .UK])
        XCTAssert(units.contains(.Each))
        XCTAssert(units.contains(.Cup))
        XCTAssert(units.contains(.ImperialPint))
        XCTAssertFalse(units.contains(.Gram))
    }
    
    func testGetUnitsAll() {
        let units = RecipeUnit.getAllValues([.US, .UK, .Metric])
        XCTAssert(units.contains(.Each))
        XCTAssert(units.contains(.Cup))
        XCTAssert(units.contains(.ImperialPint))
        XCTAssert(units.contains(.Gram))
    }
    
    func testParseUnitWithSpace() {
        let (unit, index) = RecipeUnit.fromString("fl oz")
        XCTAssert(unit == RecipeUnit.Floz)
        XCTAssert(index == 5)
    }
    
    func testParseRecipeItemWithUnitWithSpace() {
        let item = RecipeItem(textLine: "1 fl oz vanilla extract")
        XCTAssert(item.quantity == 1.0)
        XCTAssert(item.unit == RecipeUnit.Floz)
        XCTAssert(item.name == "vanilla extract")
    }
    
    func testUnitFromStringNonstandard() {
        let (unit, index) = RecipeUnit.fromString("fluid oz.")
        XCTAssert(unit == RecipeUnit.Floz)
        XCTAssert(index == 9)
    }
    
    func testParseRecipeItemWithNonstandardUnit() {
        let item = RecipeItem(textLine: "2 fluid ounces vanilla extract")
        XCTAssert(item.quantity == 2.0)
        XCTAssert(item.unit == RecipeUnit.Floz)
        XCTAssert(item.name == "vanilla extract")
   }
    
    func testParseUnitWithCapital() {
        let (unit, _) = RecipeUnit.fromString("Quart")
        XCTAssert(unit == RecipeUnit.Quart)
    }
    
    func testUnitEnumValuesDontChange() {
        // these are used as keys for saving/restoring, so critical that they don't change
        XCTAssert(RecipeUnit.Each.rawValue == "")
        XCTAssert(RecipeUnit.Gram.rawValue == "g")
        XCTAssert(RecipeUnit.Kilogram.rawValue == "kg")
        XCTAssert(RecipeUnit.Pound.rawValue == "lb")
        XCTAssert(RecipeUnit.Ounce.rawValue == "oz")
        XCTAssert(RecipeUnit.Floz.rawValue == "fl oz")
        XCTAssert(RecipeUnit.Teaspoon.rawValue == "tsp")
        XCTAssert(RecipeUnit.Tablespoon.rawValue == "Tbsp")
        XCTAssert(RecipeUnit.Milliliter.rawValue == "ml")
        XCTAssert(RecipeUnit.Liter.rawValue == "L")
        XCTAssert(RecipeUnit.Cup.rawValue == "cup")
        XCTAssert(RecipeUnit.Pint.rawValue == "pt")
        XCTAssert(RecipeUnit.Quart.rawValue == "qt")
        XCTAssert(RecipeUnit.Gallon.rawValue == "gal")
        XCTAssert(RecipeUnit.ImperialFloz.rawValue == "imp fl oz")
        XCTAssert(RecipeUnit.ImperialTsp.rawValue == "imp tsp")
        XCTAssert(RecipeUnit.ImperialTbsp.rawValue == "imp Tbsp")
        XCTAssert(RecipeUnit.ImperialPint.rawValue == "imp pt")
        XCTAssert(RecipeUnit.ImperialQuart.rawValue == "imp qt")
        XCTAssert(RecipeUnit.ImperialGallon.rawValue == "imp gal")
    }
    
    func testParseRecipeItemWithPeriod() {
        let item = RecipeItem(textLine: "1.5 fl oz vanilla extract")
        XCTAssert(item.quantity == 1.5)
        XCTAssert(item.unit == RecipeUnit.Floz)
        XCTAssert(item.name == "vanilla extract")
    }

    func testParseRecipeItemWithComma() {
        let item = RecipeItem(textLine: "1,5 fl oz vanilla extract")
        XCTAssert(item.quantity == 1.5)
        XCTAssert(item.unit == RecipeUnit.Floz)
        XCTAssert(item.name == "vanilla extract")
    }
    
    // TODO: this test fails
//    func testParseRecipeItemWithNonArabicNumber() {
//        let item = RecipeItem(textLine: "दो fl oz vanilla extract")
//        XCTAssert(item.quantity == 2.0)
//        XCTAssert(item.unit == RecipeUnit.Floz)
//        XCTAssert(item.name == "vanilla extract")
//        
//    }
    
    func testScaleIgnoresTrailingSpaceInScaleTo() {
        let eggs = RecipeItem(name: "Egg", quantity: 1.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 1.5, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Egg ", quantity: 2.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 2.0)
        XCTAssert(recipe.items[1].quantity == 3.0)
    }

    func testScaleIgnoresTrailingSpaceInRecipe() {
        let eggs = RecipeItem(name: "Egg ", quantity: 1.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 1.5, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Egg", quantity: 2.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 2.0)
        XCTAssert(recipe.items[1].quantity == 3.0)
    }

    func testOptimizeCupsToQuart() {
        let item = RecipeItem(name: "Test", quantity: 12.0, unit: RecipeUnit.Cup)
        item.optimize()
        XCTAssert(abs(item.quantity - 3.0) < 0.001)
        XCTAssert(item.unit == RecipeUnit.Quart)
    }
    
    func testOptimizeQuartsToCup() {
        let item = RecipeItem(name: "Test", quantity: 0.125, unit: RecipeUnit.Quart)
        item.optimize()
        XCTAssert(abs(item.quantity - 0.5) < 0.001)
        XCTAssert(item.unit == RecipeUnit.Cup)
    }

    func testScaleOptimizesCupsToQuart() {
        let eggs = RecipeItem(name: "Egg", quantity: 1.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[1].quantity - 3.0 < 0.001)
        XCTAssert(recipe.items[1].unit == RecipeUnit.Quart)
    }

    func testScaleOptimizesQuartsToCup() {
        let eggs = RecipeItem(name: "Egg", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 0.5, unit: RecipeUnit.Quart)
        let eggsIHave = RecipeItem(name: "Egg", quantity: 1.0, unit: nil)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[1].quantity - 0.5 < 0.001)
        XCTAssert(recipe.items[1].unit == RecipeUnit.Cup)
    }
    
    func testRecipeItemEquality() {
        let eggs = RecipeItem(name: "Egg", quantity: 4.0, unit: nil)
        let eggs2 = RecipeItem(name: "Egg", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 0.5, unit: RecipeUnit.Quart)
        XCTAssert(eggs == eggs2)
        XCTAssert(eggs != milk)
        XCTAssertFalse(eggs != eggs2)
        XCTAssertFalse(eggs == milk)
    }
    
    func testRecipeEquality() {
        let eggs = RecipeItem(name: "Egg", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 0.5, unit: RecipeUnit.Quart)
        let recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        let eggs2 = RecipeItem(name: "Egg", quantity: 4.0, unit: nil)
        let milk2 = RecipeItem(name: "Milk", quantity: 0.5, unit: RecipeUnit.Quart)
        let recipe2 = Recipe()
        recipe2.addItem(eggs2)
        recipe2.addItem(milk2)
        XCTAssert(recipe == recipe2)
        XCTAssertFalse(recipe != recipe2)
    }
}
 