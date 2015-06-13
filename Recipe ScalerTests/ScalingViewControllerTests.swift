//
//  ScalingViewControllerTests.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 6/11/15.
//  Copyright (c) 2015 Ron Stieger. All rights reserved.
//

import XCTest
import UIKit

class ScalingViewControllerTests: XCTestCase {
    var vc: ScalingViewController!
    var storyboard: UIStoryboard!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each testmethod in the class.
        self.storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        self.vc = storyboard.instantiateViewControllerWithIdentifier("RecipeToScale") as! ScalingViewController
        self.vc.recipe = Recipe()
        self.vc.recipe.name = "Test Recipe"
        self.vc.loadView()
        self.vc.viewDidLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func addOne() {
    }
    
    func addTwo() {
    }
    
    func addN(n: Int) {
        for i in 0..<n {
            addOne()
        }
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testTitleFromRecipe() {
        println(vc.title)
        XCTAssert(vc.title == "Test Recipe")
    }
    
    func testTwoSections() {
        XCTAssert(vc.tableView.numberOfSections() == 2)
    }

    func testTableViewNumberOfRowsScaleSectionOne() {
        XCTAssert(vc.tableView.numberOfRowsInSection(0) == 1)
    }
    
    func testTableViewNumberOfRowsRecipeSectionOne() {
        XCTAssert(vc.tableView.numberOfRowsInSection(1) == 1)
    }
    
    func testTableViewCellTypeAndBlank() {
        if let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EditableUITableViewCell {
            XCTAssert(cell.ingredientTextField.text == "")
            XCTAssert(cell.qtyTextField.text == "")
            XCTAssert(cell.unitTextLabel.description == "")
        }
        else {
            XCTFail()
        }
    }
}
