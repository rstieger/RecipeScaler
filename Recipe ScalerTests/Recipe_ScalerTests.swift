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
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(recipe.itemCount == 2)
        XCTAssert(recipe.items[0].name == "Eggs")
        XCTAssert(recipe.items[1].name == "Milk")
    }
    
    func testRecipeScaleUp() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleBy(2.0)
        XCTAssert(recipe.items[0].quantity == 8.0)
        XCTAssert(recipe.items[1].quantity == 6.0)
    }
    
    func testRecipeScaleDown() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.scaleBy(0.5)
        XCTAssert(recipe.items[0].quantity == 2.0)
        XCTAssert(recipe.items[1].quantity == 1.5)
    }

    func testRecipeScaleToUseUp() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
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
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
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
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
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
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
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
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
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
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        recipe.deleteItem(eggs)
        XCTAssert(recipe.itemCount == 1)
        XCTAssert(recipe.items[0].name == milk.name)
    }
    
    func testRecipeGetIngredientName() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(recipe.getIngredientName(0) == eggs.name)
        XCTAssert(recipe.getIngredientName(1) == milk.name)
    }
    
    func testRecipeGetIngredientQuantityIntegerNoUnits() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(recipe.getIngredientQuantity(0) == "4")
    }
    
    func testRecipeGetIngredientQuantityIntegerWithUnits() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        XCTAssert(recipe.getIngredientQuantity(1) == "3 cup")
    }
    
    func testRecipeItemQuantityString() {
        let item = RecipeItem(name: "Eggs", quantityOfUnit: "4")
        XCTAssert(item.name == "Eggs")
        XCTAssert(item.quantity == 4.0)
        XCTAssert(item.unit == nil)
    }
    
    func testRecipeCopyAndScale() {
        let eggs = RecipeItem(name: "Eggs", quantity: 4.0, unit: nil)
        let milk = RecipeItem(name: "Milk", quantity: 3.0, unit: RecipeUnit.cup)
        let eggsIHave = RecipeItem(name: "Eggs", quantity: 8.0, unit: nil)
        var recipe = Recipe()
        recipe.addItem(eggs)
        recipe.addItem(milk)
        let scaledRecipe = recipe.getScaledToUse(eggsIHave)
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
}
