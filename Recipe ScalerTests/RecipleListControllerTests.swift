//
//  RecipleListControllerTests.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 6/6/15.
//  Copyright (c) 2015 Ron Stieger. All rights reserved.
//

import XCTest
import UIKit

class RecipeListControllerTests: XCTestCase {
    var vc: RecipeListViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each testmethod in the class.
        var storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        self.vc = storyboard.instantiateViewControllerWithIdentifier("RecipeList") as! RecipeListViewController
        self.vc.loadView()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func addOne() {
        let recipe = Recipe()
        recipe.name = "Test Recipe"
        vc.recipes.append(recipe)
        vc.tableView.reloadData()
    }
    
    func addTwo() {
        let recipe1 = Recipe()
        recipe1.name = "Recipe1"
        let recipe2 = Recipe()
        recipe2.name = "Recipe2"
        vc.recipes.append(recipe1)
        vc.recipes.append(recipe2)
        vc.tableView.reloadData()       
    }
    
    func addN(n: Int) {
        for i in 0..<n {
            addOne()
        }
    }
    
    func clickAddButton() {
        let button = vc.navigationItem.rightBarButtonItem!
        vc.addRecipe(button)
    }
    
    func getCellName(row: Int) -> String {
        let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as! RecipeNameCell
        return cell.recipeName.text
    }
    
    func swipeToDelete(row: Int) {
        vc.tableView(vc.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: row, inSection: 0))
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testTableViewNumberOfSectionsOne() {
        let sections = vc.tableView.numberOfSections()
        XCTAssert(sections == 1)
    }
    
    func testTableViewStylePlain() {
        let style = vc.tableView.style
        XCTAssert(style == .Plain)
    }

    func testTableViewNumberOfRowsZero() {
        let rows = vc.tableView.numberOfRowsInSection(0)
        XCTAssert(rows == 0)
    }

    func testTableViewNumberOfRowsOne() {
        addOne()
        let rows = vc.tableView.numberOfRowsInSection(0)
        XCTAssert(rows == 1)
    }
    
    func testTableViewCellTypeAndName() {
        addOne()
        if let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? RecipeNameCell {
            XCTAssert(cell.recipeName.text == "Test Recipe")
        }
        else {
            XCTFail()
        }
    }
    
    func testTableViewMultipleRows() {
        addTwo()
        XCTAssert(getCellName(0) == "Recipe1")
        XCTAssert(getCellName(1) == "Recipe2")
    }
    
    func testAddButtonExists() {
        let nav = vc.navigationItem
        if let button = nav.rightBarButtonItem {
            XCTAssert(button.target as! RecipeListViewController == vc)
            XCTAssert(button.action == Selector("addRecipe:"))
        }
        else {
            XCTFail()
        }
    }
    
    func testAddRecipeUpdatesTable() {
        clickAddButton()
        XCTAssert(vc.tableView.numberOfRowsInSection(0) == 1)
    }
    
    func testAddRecipeDefaultName() {
        clickAddButton()
        XCTAssert(getCellName(0) == "")
        let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RecipeNameCell
        XCTAssert(cell.recipeName.placeholder == "New Recipe")
    }
    
    func testAddRecipeAfterOne() {
        addOne()
        clickAddButton()
        XCTAssert(getCellName(0) == "Test Recipe")
        XCTAssert(getCellName(1) == "")
    }
    
    func testStartEditingIsCalled() {
        addOne()
        let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RecipeNameCell
        let actions = cell.recipeName.actionsForTarget(vc, forControlEvent: .EditingDidBegin)!
        XCTAssert(actions[0] as! String == "startEditing:")
    }

// TODO: test keyboard visible/hide during editing
    
    func testStopEditingIsCalled() {
        addOne()
        let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RecipeNameCell
        let actions = cell.recipeName.actionsForTarget(vc, forControlEvent: .EditingDidEnd)!
        XCTAssert(actions[0] as! String == "stopEditing:")
    }
    
    func testEditRenames() {
        addOne()
        let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RecipeNameCell
        vc.startEditing(cell.recipeName)
        cell.recipeName.text = "New Name"
        vc.stopEditing(cell.recipeName)
        XCTAssert(vc.recipes[0].name == "New Name")
    }
    
    func testCanSwipeToDelete() {
        addOne()
        let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RecipeNameCell
        XCTAssert(vc.tableView(vc.tableView, editingStyleForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) == .Delete)
    }
    
    func testDeleteRecipeFirst() {
        addTwo()
        swipeToDelete(0)
        XCTAssert(vc.recipes.count == 1)
        XCTAssert(vc.tableView.numberOfRowsInSection(0) == 1)
        XCTAssert(getCellName(0) == "Recipe2")
    }
    
    func testDeleteRecipeLast() {
        addTwo()
        swipeToDelete(1)
        XCTAssert(vc.recipes.count == 1)
        XCTAssert(vc.tableView.numberOfRowsInSection(0) == 1)
        XCTAssert(getCellName(0) == "Recipe1")
    }
    
    func testDeleteRecipeOnly() {
        addOne()
        swipeToDelete(0)
        XCTAssert(vc.recipes.count == 0)
        XCTAssert(vc.tableView.numberOfRowsInSection(0) == 0)
    }

    
// TODO: test delete only recipe with split controller - should make a new one
    
    func testIndicatorVisible() {
        addOne()
        let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RecipeNameCell
        XCTAssert(cell.accessoryType == .DisclosureIndicator)
    }
    
    func testIndicatorOnlyIfNamed() {
        addOne()
        vc.recipes[0].name = ""
        let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RecipeNameCell
        XCTAssert(cell.accessoryType == .None)
    }
    
    func testSegueAllowedOnlyIfNamed() {
        addTwo()
        vc.recipes[1].name = ""
        var cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RecipeNameCell
        XCTAssert(vc.shouldPerformSegueWithIdentifier("selectRecipe", sender: cell) == true)
        cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! RecipeNameCell
        XCTAssert(vc.shouldPerformSegueWithIdentifier("selectRecipe", sender: cell) == false)
    }
    
    func testPrepareForSegueSetsRecipeFirst() {
        addTwo()
        let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RecipeNameCell
        let newvc = ScalingViewController()
        vc.prepareForSegue(UIStoryboardSegue(identifier: "selectRecipe", source: vc, destination: newvc), sender: cell)
        XCTAssert(newvc.recipe == vc.recipes[0])
    }
    
    func testPrepareForSegueSetsRecipeLast() {
        addTwo()
        let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! RecipeNameCell
        let newvc = ScalingViewController()
        vc.prepareForSegue(UIStoryboardSegue(identifier: "selectRecipe", source: vc, destination: newvc), sender: cell)
        XCTAssert(newvc.recipe == vc.recipes[1])
    }

    func testDeleteFromChildFirst() {
        addTwo()
        let rvc = ScalingViewController()
        rvc.recipe = vc.recipes[0]
        vc.deleteFromChildPage(UIStoryboardSegue(identifier: "deleteRecipe", source: rvc, destination: vc))
        XCTAssert(vc.recipes.count == 1)
        XCTAssert(vc.recipes[0].name == "Recipe2")
        XCTAssert(getCellName(0) == "Recipe2")
    }

    func testDeleteFromChildLast() {
        addTwo()
        let rvc = ScalingViewController()
        rvc.recipe = vc.recipes[1]
        vc.deleteFromChildPage(UIStoryboardSegue(identifier: "deleteRecipe", source: rvc, destination: vc))
        XCTAssert(vc.recipes.count == 1)
        XCTAssert(vc.recipes[0].name == "Recipe1")
        XCTAssert(getCellName(0) == "Recipe1")
    }
    func testDeleteFromChildOnly() {
        addOne()
        let rvc = ScalingViewController()
        rvc.recipe = vc.recipes[0]
        vc.deleteFromChildPage(UIStoryboardSegue(identifier: "deleteRecipe", source: rvc, destination: vc))
        XCTAssert(vc.recipes.count == 0)
        XCTAssert(vc.tableView.numberOfRowsInSection(0) == 0)
    }

// TODO: test show and hide keyboard
    // TODO: test update child if split controller
    
}