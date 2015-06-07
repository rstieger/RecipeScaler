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
        var cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RecipeNameCell
        XCTAssert(cell.recipeName.text == "Recipe1")
        cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! RecipeNameCell
        XCTAssert(cell.recipeName.text == "Recipe2")
    }
    
    // TODO: test adding recipe
    // TODO: test deleting recipe
    // TODO: test renaming recipe
    // TODO: test segue
    // TODO: test no segue if unnamed
    // TODO: test show and hide keyboard
    // TODO: test update child if split controller
    // TODO: test delete from child page
    
}