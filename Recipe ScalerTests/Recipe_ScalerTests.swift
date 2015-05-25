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
        var item = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        item.scaleBy(2.0)
        XCTAssert(item.quantity == 8.0)
    }
    
    func testRecipeScaleItemDown() {
        var item = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        item.scaleBy(0.5)
        XCTAssert(item.quantity == 2.0)
    }
    
    func testRecipeAddItem() {
        let item = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        var recipe = Recipe()
        recipe.addItem(item)
        XCTAssert(recipe.itemCount == 1)
        XCTAssert(recipe.items[0].name == "Eggs")
    }
    
    func testRecipeAddItems() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(recipe.itemCount == 2)
        XCTAssert(recipe.items[0].name == "Eggs")
        XCTAssert(recipe.items[1].name == "Milk")
    }
    
    func testRecipeScaleUp() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleBy(2.0)
        XCTAssert(recipe.items[0].quantity == 8.0)
        XCTAssert(recipe.items[1].quantity == 6.0)
    }
    
    func testRecipeScaleDown() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleBy(0.5)
        XCTAssert(recipe.items[0].quantity == 2.0)
        XCTAssert(recipe.items[1].quantity == 1.5)
    }

    func testRecipeScaleToUseUp() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 8.0, unit: nil)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 8.0)
        XCTAssert(recipe.items[1].quantity == 6.0)        
    }
    
    func testRecipeScaleToUseDown() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 2.0, unit: nil)
        var recipe = Recipe()
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
        var recipe = Recipe()
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
        var recipe = Recipe()
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
        var recipe = Recipe()
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
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.deleteItem(eggs)
        XCTAssert(recipe.itemCount == 1)
        XCTAssert(recipe.items[0].name == milk.name)
    }
    
    func testRecipeGetIngredientName() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(recipe.getIngredientName(0) == eggs.name)
        XCTAssert(recipe.getIngredientName(1) == milk.name)
    }
    
    func testRecipeGetIngredientQuantityIntegerNoUnits() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(recipe.getIngredientQuantity(0) == "4 ")
    }
    
    func testRecipeGetIngredientQuantityIntegerWithUnits() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        println(recipe.getIngredientQuantity(1))
        XCTAssert(recipe.getIngredientQuantity(1) == "3 cup")
    }
    
    func testRecipeItemQuantityString() {
        let item = RecipeItem(name: "Eggs", quantityOfUnit: "4")
        XCTAssert(item.name == "Eggs")
        XCTAssert(item.quantity == 4.0)
        XCTAssert(item.unit == RecipeUnit.Each)
    }
    
    func testRecipeCopyAndScale() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 8.0, unit: nil)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        let (scaledRecipe, error) = recipe.getScaledToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 4.0)
        XCTAssert(recipe.items[1].quantity == 3.0)
        XCTAssert(scaledRecipe.items[0].quantity == 8.0)
        XCTAssert(scaledRecipe.items[1].quantity == 6.0)
    }
/*
func testRecipeItemQuantityAndUnitString() {
        let item = RecipeItem(name: "Milk", quantityOfUnit: "3 cup")
        XCTAssert(item.name == "Milk")
        XCTAssert(item.quantity == 3.0)
        XCTAssert(item.unit == RecipeUnit.cup)
    }
*/
/*
    func testRecipeUnitOptimizeCupToPint() {
        var quantity: Double
        var unit: RecipeUnit
        (quantity, unit) = RecipeUnit.optimizeUnit(2.0, unit: .Cup)
        XCTAssert(quantity == 1.0 && unit == .Pint)
    }
*/
    func testRecipeScaleToUseWithDifferentUnits() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 2.0, unit: RecipeUnit.Cup)
        let milkIHave = RecipeItem(name: "Milk", quantity: 1.0, unit: RecipeUnit.Pint)
        var recipe = Recipe()
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
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        let error: RecipeError? = recipe.scaleToUse(eggsIHave)
        XCTAssert(error == RecipeError.DivideByZero(name: "Eggs"))
    }
    
    func testRecipeScaleToOneHalf() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 2.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 1.0, unit: nil)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.getIngredientQuantity(1) == "1/2 cup")
    }
    
    func testRecipeItemQuantityOneHalf() {
        let milk = RecipeItem(name: "Milk", quantityAsString: "1/2", unit: RecipeUnit.Cup)
        println("\(milk.quantity)")
        XCTAssert(milk.quantity == 0.5)
    }

    func testRecipeItemQuantityOneAndOneHalf() {
        let milk = RecipeItem(name: "Milk", quantityAsString: "1 1/2", unit: RecipeUnit.Cup)
        println("\(milk.quantity)")
        XCTAssert(milk.quantity == 1.5)
    }

    func testRecipeItemQuantityKilogramHalf() {
        let butter = RecipeItem(name: "Butter", quantity: 0.5, unit: RecipeUnit.Kilogram)
        XCTAssert(butter.quantityAsString == "0.5")
    }
    func testRecipeItemQuantityStringOne() {
        let milk = RecipeItem(name: "Milk", quantityAsString: "1", unit: RecipeUnit.Cup)
        println("\(milk.quantity)")
        XCTAssert(milk.quantity == 1.0)
    }

    func testRecipeItemQuantityDenominatorZero() {
        let milk = RecipeItem(name: "Milk", quantityAsString: "1/0", unit: RecipeUnit.Cup)
        println("\(milk.quantity)")
        XCTAssert(milk.quantity == 0)
    }

    func testRecipeItemQuantityDenominatorZeroWithWhole() {
        let milk = RecipeItem(name: "Milk", quantityAsString: "1 1/0", unit: RecipeUnit.Cup)
        println("\(milk.quantity)")
        XCTAssert(milk.quantity == 1)
    }
    
    func testRecipeScalePluralInScaler() {
        let eggs = RecipeItem(name: "Egg", quantity: 1.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 2.0, unit: nil)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleToUse(eggsIHave)
        XCTAssert(recipe.items[0].quantity == 2.0)
        XCTAssert(recipe.items[1].quantity == 6.0)
        
    }
    
    func testRecipeScalePluralInRecipe() {
        let eggs = RecipeItem(name: "Eggs", quantity: 2.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.Cup)
        let eggsIHave = RecipeItem(name: "Egg", quantity: 1.0, unit: nil)
        var recipe = Recipe()
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
        let lines: [String] = ["1 1/2 cup milk", "2 eggs", "3/4 cup powdered sugar"]
        let recipe = Recipe(textLines: lines)
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
        var recipe = Recipe()
        recipe.name = "Test"
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(String(recipe: recipe) == "Test\n\n2 Eggs\n3 cup Milk\n")
    }
    
    func testRecipeToStringNull() {
        var recipe = Recipe()
        XCTAssert(String(recipe: recipe) == "\n\n")
    }
}
 