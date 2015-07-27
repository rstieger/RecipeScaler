//
//  ScaledRecipeControllerTests.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 6/11/15.
//  Copyright (c) 2015 Ron Stieger. All rights reserved.
//

import XCTest
import UIKit

class ScaledRecipeControllerTests: XCTestCase {
    class MockNavigationController: UINavigationController {
        var vc: UIViewController?
        override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
            vc = viewControllerToPresent
        }
    }
    
    var vc: ScaledRecipeViewController!
    var nc: MockNavigationController!
    var storyboard: UIStoryboard!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each testmethod in the class.
        self.storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        self.vc = storyboard.instantiateViewControllerWithIdentifier("ScaledRecipe") as! ScaledRecipeViewController
        self.vc.loadView()
        self.vc.viewDidLoad()
        self.nc = MockNavigationController(rootViewController: self.vc)
//        self.nc.addChildViewController(vc)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func addWarning() {
        vc.warningMessage = "Test Warning"
        vc.tableView.reloadData()
    }

    func addOneItem() {
        let item = RecipeItem(name: "Test Ingredient", quantity: 1.5, unit: .Cup)
        vc.recipe.addItem(item)
        vc.tableView.reloadData()
    }

    func addTwoItems() {
        vc.recipe.addItem(RecipeItem(name: "Ingredient 1", quantity: 1.0, unit: .Cup))
        vc.recipe.addItem(RecipeItem(name: "Ingredient 2", quantity: 2.0, unit: .Each))
        vc.tableView.reloadData()
    }
    
    func makeSplit() {
        let svc = storyboard.instantiateViewControllerWithIdentifier("SplitController") as! UISplitViewController
        var nc = svc.viewControllers[1] as! UINavigationController
        nc.viewControllers[0] = vc
        self.vc.viewDidLoad()   // reload as split
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testNumberOfSectionsOne() {
        XCTAssert(vc.tableView.numberOfSections() == 1)
    }
    
    func testWarningAddsSection() {
        addWarning()
        XCTAssert(vc.tableView.numberOfSections() == 2)
        XCTAssert(vc.tableView.numberOfRowsInSection(0) == 1)
    }
    
    func testWarningDisplayed() {
        addWarning()
        let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssert(cell?.textLabel!.text == "Test Warning")
    }
    
    func testWarningColor() {
        addWarning()
        let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssert(cell?.backgroundColor == UIColor.salmonColor())
    }
    
    func testNumberOfRowsZero() {
        XCTAssert(vc.tableView.numberOfRowsInSection(0) == 0)
    }
    
    func testNumberOfRowsZeroWithWarning() {
        addWarning()
        XCTAssert(vc.tableView.numberOfRowsInSection(1) == 0)
    }
    
    func testNumberOfRowsOne() {
        addOneItem()
        XCTAssert(vc.tableView.numberOfRowsInSection(0) == 1)
    }

    func testNumberOfRowsTwo() {
        addTwoItems()
        XCTAssert(vc.tableView.numberOfRowsInSection(0) == 2)
    }
    
    func testNumberOfRowsTwoWithWarning() {
        addTwoItems()
        addWarning()
        XCTAssert(vc.tableView.numberOfRowsInSection(1) == 2)
    }
    
    func testRowContents() {
        addTwoItems()
        var cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssert(cell?.textLabel!.text == "1 cup")
        XCTAssert(cell?.detailTextLabel!.text == "Ingredient 1")
        cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        XCTAssert(cell?.textLabel!.text == "2 ")
        XCTAssert(cell?.detailTextLabel!.text == "Ingredient 2")
    }
    
    func testActionMenuExists() {
        if let toolbar = vc.toolbarItems as? [UIBarButtonItem] {
            XCTAssert(toolbar.count >= 1)
            XCTAssertNotNil(find(toolbar, vc.actionButton))
        }
        else {
            XCTFail()
        }
    }
    
    func testActionMenuShowsActions() {
        XCTAssert(vc.actionButton.target as! ScaledRecipeViewController == vc)
        XCTAssert(vc.actionButton.action == Selector("showActions:"))
    }
    
    func testShowActionsShowsPopoverActivityView() {
        vc.showActions(vc.actionButton)
        if let controller = nc.vc as? UIActivityViewController {
        }
        else {
            XCTFail()
        }
    }
    
    // TODO: fix this test - need split for popover, then should be anchored to nav bar
//    func testShowActionsPopoverAnchoredToButton() {
//        vc.showActions(vc.actionButton)
//        let controller = nc.vc as! UIActivityViewController
//        XCTAssert(controller.popoverPresentationController?.barButtonItem == vc.actionButton)
//    }

    // TODO: fix this test - may need to make sure view appears not just loads
//    func testActionMenuInNavBarIfSplit() {
//        makeSplit()
//        let nav = vc.navigationItem
//        println(nav.rightBarButtonItems?.count)
//        if let button = nav.rightBarButtonItem {
//            XCTAssert(button.target as! ScaledRecipeViewController == vc)
//            XCTAssert(button.action == Selector("showActions:"))
//        }
//        else {
//            XCTFail()
//        }
//    }
}

