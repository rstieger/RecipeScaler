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
    class MockNavigationController: UINavigationController {
        var vc: UIViewController?
        override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
            vc = viewControllerToPresent
        }
    }
    
    class MockRecipeListController: RecipeListViewController {
        var recipeToDelete: Recipe?
        override func deleteRecipe(recipe: Recipe) {
            println("deleteFromChildPage")
            recipeToDelete = recipe
        }
    }
    
    var vc: ScalingViewController!
    var nc: MockNavigationController!
    var parent: MockRecipeListController!
    var storyboard: UIStoryboard!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each testmethod in the class.
        self.storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        self.vc = storyboard.instantiateViewControllerWithIdentifier("RecipeToScale") as! ScalingViewController
        self.vc.recipe = Recipe()
        self.vc.recipe.name = "Test Recipe"
        self.nc = MockNavigationController(rootViewController: vc)
        self.parent = MockRecipeListController()
        self.parent.recipes.append(self.vc.recipe)
        self.vc.loadView()
        self.vc.viewDidLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func addOne() {
        vc.recipe.addItem(RecipeItem(name: "Test Ingredient", quantity: 2.0, unit: .Cup))
        vc.tableView.reloadData()
    }
    
    func addTwo() {
        vc.recipe.addItem(RecipeItem(name: "Ingredient 1", quantity: 1.0, unit: .Cup))
        vc.recipe.addItem(RecipeItem(name: "Ingredient 2", quantity: 2.0, unit: .Each))
        vc.tableView.reloadData()
    }
    
    func addN(n: Int) {
        for i in 0..<n {
            addOne()
        }
    }
    
    func getIngredientCell(n: Int) -> EditableUITableViewCell {
        return vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: n, inSection: 1)) as! EditableUITableViewCell
    }
    
    func getScalingCell() -> EditableUITableViewCell {
        return vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! EditableUITableViewCell
    }
    
    func swipeToDelete(row: Int) {
        vc.tableView(vc.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: row, inSection: 1))
    }
    
    func makeSplit() {
        let svc = storyboard.instantiateViewControllerWithIdentifier("SplitController") as! UISplitViewController
        var nc = svc.viewControllers[0] as! UINavigationController
        nc.viewControllers[0] = parent
        nc = svc.viewControllers[1] as! UINavigationController
        nc.viewControllers[0] = vc
        println(nc.viewControllers.count)
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testTitleFromRecipe() {
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
    
    func testTableViewNumberOfRowsRecipeSectionOneNPlusOne() {
        addN(10)
        XCTAssert(vc.tableView.numberOfRowsInSection(1) == 11)
    }
    
    func testTableViewCellTypeAndBlank() {
        if let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EditableUITableViewCell {
            XCTAssert(cell.ingredientTextField.text == "")
            XCTAssert(cell.qtyTextField.text == "")
            XCTAssert(cell.unitTextLabel.titleLabel!.text == "unit")
        }
        else {
            XCTFail()
        }
    }
    
    func testTableViewOneIngredientTwoRows() {
        addOne()
        XCTAssert(vc.tableView.numberOfRowsInSection(1) == 2)
    }
    
    func testTableViewOneIngredientFirstRowContents() {
        addOne()
        if let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? EditableUITableViewCell {
            XCTAssert(cell.ingredientTextField.text == "Test Ingredient")
            XCTAssert(cell.qtyTextField.text == "2")
            XCTAssert(cell.unitTextLabel.titleLabel!.text == "cup")
        }
        else {
            XCTFail()
        }
    }
    
    func testTableViewOneIngredientSecondRowBlank() {
        addOne()
        if let cell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as? EditableUITableViewCell {
            XCTAssert(cell.ingredientTextField.text == "")
            XCTAssert(cell.qtyTextField.text == "")
            XCTAssert(cell.unitTextLabel.titleLabel!.text == "unit")
        }
        else {
            XCTFail()
        }
    }
    
    func testEditQuantityScrollsToRow() {
        let cell = getIngredientCell(0)
        if let actions = cell.qtyTextField.actionsForTarget(vc, forControlEvent: .EditingDidBegin) {
            XCTAssert(actions[0] as! String == "scrollToRow:")
        }
        else {
            XCTFail()
        }
    }
    
    func testEditNameScrollsToRow() {
        let cell = getIngredientCell(0)
        if let actions = cell.ingredientTextField.actionsForTarget(vc, forControlEvent: .EditingDidBegin) {
            XCTAssert(actions[0] as! String == "scrollToRow:")
        }
        else {
            XCTFail()
        }
    }
    
    func testScrollToRowSelectsRow() {
        addN(10)
        let cell = getIngredientCell(6)
        vc.scrollToRow(cell.qtyTextField)
        XCTAssert(vc.tableView.indexPathForSelectedRow() == vc.tableView.indexPathForCell(cell))
    }
    
    func testStopEditingIsCalled() {
        let cell = getIngredientCell(0)
        if let actions = cell.ingredientTextField.actionsForTarget(vc, forControlEvent: .EditingDidEnd) {
            XCTAssert(actions[0] as! String == "stopEditing:")
        }
        else {
            XCTFail()
        }
    }
    
    func testEditQuantityChangesQuantity() {
        let cell = getIngredientCell(0)
        cell.qtyTextField.text = "4.2"
        vc.stopEditing(cell.qtyTextField)
        XCTAssert(vc.recipe.items[0].quantity == 4.2)
    }
    
    func testEditIngredientChangesName() {
        let cell = getIngredientCell(0)
        cell.ingredientTextField.text = "New Ingredient"
        vc.stopEditing(cell.ingredientTextField)
        XCTAssert(vc.recipe.items[0].name == "New Ingredient")
    }
    
    func testEditQuantityWithFraction() {
        let cell = getIngredientCell(0)
        cell.qtyTextField.text = "1 1/2"
        vc.stopEditing(cell.qtyTextField)
        XCTAssert(vc.recipe.items[0].quantity == 1.5)
    }
    
    func testTapUnitShowsPicker() {
        let cell = getIngredientCell(0)
        if let actions = cell.unitTextLabel.actionsForTarget(vc, forControlEvent: .TouchUpInside) {
            XCTAssert(actions[0] as! String == "showPicker:")
        }
        else {
            XCTFail()
        }
    }
    
    func testShowPickerAddsPickerCellOnlyOne() {
        let cell = getIngredientCell(0)
        vc.showPicker(cell.unitTextLabel)
        if let pickercell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as? UnitPickerCell {
            
        }
        else {
            XCTFail()
        }
    }

    func testShowPickerAddsPickerCellFirst() {
        addOne()
        let cell = getIngredientCell(0)
        vc.showPicker(cell.unitTextLabel)
        if let pickercell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as? UnitPickerCell {
            
        }
        else {
            XCTFail()
        }
    }
    
    func testShowPickerAddsPickerCellLast() {
        addOne()
        let cell = getIngredientCell(1)
        vc.showPicker(cell.unitTextLabel)
        if let pickercell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 1)) as? UnitPickerCell {
            
        }
        else {
            XCTFail()
        }
    }
    
    func testShowPickerNewRowStartsWithEach() {
        let cell = getIngredientCell(0)
        vc.showPicker(cell.unitTextLabel)
        let pickercell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! UnitPickerCell
        XCTAssert(pickercell.unitPicker.selectedRowInComponent(0) == find(RecipeUnit.allValues, .Each))
    }

    func testShowPickerStartsWithUnit() {
        addOne()
        let cell = getIngredientCell(0)
        vc.showPicker(cell.unitTextLabel)
        let pickercell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! UnitPickerCell
        XCTAssert(pickercell.unitPicker.selectedRowInComponent(0) == find(RecipeUnit.allValues, .Cup))
    }
    
    func testPickerSelectChangesUnit() {
        let cell = getIngredientCell(0)
        vc.showPicker(cell.unitTextLabel)
        let pickercell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! UnitPickerCell
        vc.pickerView(pickercell.unitPicker, didSelectRow: find(RecipeUnit.allValues, .Tablespoon)!, inComponent: 0)
        XCTAssert(vc.recipe.items[0].unit == .Tablespoon)
    }
    
    func testPickerSelectCollapsesPickerAddsNewLine() {
        var cell = getIngredientCell(0)
        vc.showPicker(cell.unitTextLabel)
        let pickercell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as! UnitPickerCell
        vc.pickerView(pickercell.unitPicker, didSelectRow: find(RecipeUnit.allValues, .Tablespoon)!, inComponent: 0)
        XCTAssert(vc.tableView.numberOfRowsInSection(1) == 2)
        cell = getIngredientCell(0)
        XCTAssert(cell.unitTextLabel.titleLabel!.text == "Tbsp")
        cell = getIngredientCell(1)
        XCTAssert(cell.unitTextLabel.titleLabel!.text == "unit")
    }
  
//    func testTapGestureRecognizerExists() {
//        var cell = getIngredientCell(0)
//        var tapRecognizer: UITapGestureRecognizer?
//        vc.showPicker(cell.unitTextLabel)
//        if let recognizers = vc.view.gestureRecognizers as? [UIGestureRecognizer] {
//            for recognizer in recognizers {
//                if recognizer.isKindOfClass(UITapGestureRecognizer) {
//                    if let tapRecognizer = recognizer as? UITapGestureRecognizer {
//                        XCTAssert(tapRecognizer.)
//                    }
//                    break
//                }
//            }
//        }
//        if tapRecognizer != nil {
//            
//        }
//        
//    }
    func getTapGestureRecognizer() -> UITapGestureRecognizer? {
        var ret: UITapGestureRecognizer?
        if let recognizers = vc.view.gestureRecognizers as? [UIGestureRecognizer] {
            for recognizer in recognizers {
                if let tapRec = recognizer as? UITapGestureRecognizer {
                    ret = tapRec
                    break
                }
            }
        }
        return ret
    }
//    
//    func testTapCollapsesPickerWithoutSelection() {
//        var cell = getIngredientCell(0)
//        vc.showPicker(cell.unitTextLabel)
//        vc.view.hitTest(CGPoint(x: 50, y: 50), withEvent: nil)
//        if let tapRec = getTapGestureRecognizer() {
//            vc.handleTap(tapRec)
//            XCTAssert(vc.tableView.numberOfRowsInSection(1) == 1)
//            cell = getIngredientCell(0)
//            XCTAssert(cell.unitTextLabel.titleLabel!.text == "unit")
//        }
//    }
    
    func testCanSwipeToDelete() {
        addOne()
        XCTAssert(vc.tableView(vc.tableView, editingStyleForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1)) == UITableViewCellEditingStyle.Delete)
    }
    
    func testCantSwipeToDeleteScaleItem() {
        addOne()
        XCTAssert(vc.tableView(vc.tableView, editingStyleForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) == UITableViewCellEditingStyle.None)
    }
    
    func testDeleteItemFirst() {
        addTwo()
        swipeToDelete(0)
        XCTAssert(vc.recipe.itemCount == 1)
        XCTAssert(vc.tableView.numberOfRowsInSection(1) == 2)
        XCTAssert(getIngredientCell(0).ingredientTextField.text == "Ingredient 2")
        XCTAssert(vc.recipe.items[0].name == "Ingredient 2")
    }
    
    func testDeleteItemSecond() {
        addTwo()
        swipeToDelete(1)
        XCTAssert(vc.recipe.itemCount == 1)
        XCTAssert(vc.tableView.numberOfRowsInSection(1) == 2)
        XCTAssert(getIngredientCell(0).ingredientTextField.text == "Ingredient 1")
        XCTAssert(vc.recipe.items[0].name == "Ingredient 1")
    }
    
    func testDeleteExtraRowDoesNothing() {
        addTwo()
        swipeToDelete(2)
        XCTAssert(vc.recipe.itemCount == 2)
        XCTAssert(vc.tableView.numberOfRowsInSection(1) == 3)
    }
    
    func testScaleSegueAllowed() {
        let cell = getScalingCell()
        XCTAssertTrue(vc.shouldPerformSegueWithIdentifier("scaleRecipe", sender: cell))
    }
    
    func testPrepareForSegueScalesRecipe() {
        addTwo()
        vc.itemToScale.name = "Ingredient 1"
        vc.itemToScale.quantity = 2.0
        vc.itemToScale.unit = RecipeUnit.Cup
        let cell = getScalingCell()
        let newvc = ScaledRecipeViewController()
        vc.prepareForSegue(UIStoryboardSegue(identifier: "scaleRecipe", source: vc, destination: newvc), sender: cell)
        XCTAssert(newvc.recipe.itemCount == vc.recipe.itemCount)
        XCTAssert(newvc.recipe.items[0].name == "Ingredient 1")
        XCTAssert(newvc.recipe.items[0].quantity == 2.0)
        XCTAssert(newvc.recipe.items[1].name == "Ingredient 2")
        XCTAssert(newvc.recipe.items[1].quantity == 4.0)
        XCTAssertNil(newvc.warningMessage)
    }
    
    func testPrepareForSegueSetsWarningIfNoIngredient() {
        addTwo()
        vc.itemToScale.name = "Ingredient"
        vc.itemToScale.quantity = 2.0
        vc.itemToScale.unit = RecipeUnit.Cup
        let cell = getScalingCell()
        let newvc = ScaledRecipeViewController()
        vc.prepareForSegue(UIStoryboardSegue(identifier: "scaleRecipe", source: vc, destination: newvc), sender: cell)
        XCTAssert(newvc.recipe.itemCount == vc.recipe.itemCount)
        XCTAssert(newvc.recipe.items[0].name == "Ingredient 1")
        XCTAssert(newvc.recipe.items[0].quantity == 1.0)
        XCTAssert(newvc.recipe.items[1].name == "Ingredient 2")
        XCTAssert(newvc.recipe.items[1].quantity == 2.0)
        XCTAssertNotNil(newvc.warningMessage)
    }
    
    func testPrepareForSegueSetsWarningIfDivideByZero() {
        addTwo()
        vc.recipe.items[0].quantity = 0.0
        vc.itemToScale.name = "Ingredient 1"
        vc.itemToScale.quantity = 2.0
        vc.itemToScale.unit = RecipeUnit.Cup
        let cell = getScalingCell()
        let newvc = ScaledRecipeViewController()
        vc.prepareForSegue(UIStoryboardSegue(identifier: "scaleRecipe", source: vc, destination: newvc), sender: cell)
        XCTAssert(newvc.recipe.itemCount == vc.recipe.itemCount)
        XCTAssert(newvc.recipe.items[0].name == "Ingredient 1")
        XCTAssert(newvc.recipe.items[0].quantity == 0.0)
        XCTAssert(newvc.recipe.items[1].name == "Ingredient 2")
        XCTAssert(newvc.recipe.items[1].quantity == 2.0)
        XCTAssertNotNil(newvc.warningMessage)
    }
    
    func testDeleteButtonExists() {
        if let toolbar = vc.toolbarItems as? [UIBarButtonItem] {
            XCTAssert(toolbar.count >= 1)
            XCTAssertNotNil(find(toolbar, vc.deleteButton))
        }
        else {
            XCTFail()
        }
    }
    
    func testDeleteShowsConfirmation() {
        XCTAssert(vc.deleteButton.target as! ScalingViewController == vc)
        XCTAssert(vc.deleteButton.action == Selector("showDeleteConfirmation:"))
    }
    
    func testShowConfirmationShowsPopover() {
        vc.showDeleteConfirmation(vc.deleteButton)
        if let controller = nc.vc as? UIAlertController {
            if let actions = controller.actions as? [UIAlertAction] {
                XCTAssert(actions[0].style == UIAlertActionStyle.Destructive)
                XCTAssert(actions[1].style == UIAlertActionStyle.Cancel)
            }
            else {
                XCTFail()
            }
        }
        else {
            XCTFail()
        }
    }
    // TODO: Confirm action handler actually calls deleteAndUnwind()
    
    func testDeleteAndUnwindPerformsExitSegue() {
        makeSplit()
        vc.deleteAndUnwind()
        XCTAssert(parent.recipeToDelete == vc.recipe)
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
        XCTAssert(vc.actionButton.target as! ScalingViewController == vc)
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
    
    // TODO: fix this test, should be anchored to navbar if split
//    func testShowActionsPopoverAnchoredToButton() {
//        makeSplit()
//        vc.showActions(vc.actionButton)
//        let controller = nc.vc as! UIActivityViewController
//        XCTAssert(controller.popoverPresentationController?.barButtonItem == vc.actionButton)
//    }
    
    // TODO: want to move delete and actions to nav bar if split
//    func testActionMenuInNavBarIfSplit() {
//        makeSplit()
//        let nav = vc.navigationItem
//        if let button = nav.rightBarButtonItem {
//            XCTAssert(button.target as! RecipeViewController == vc)
//            XCTAssert(button.action == Selector("showActions:"))
//        }
//        else {
//            XCTFail()
//        }
//    }

    func testUpdateFromMasterUpdatesTitle() {
        vc.recipe.name = "New Name"
        vc.updateFromMaster()
        XCTAssert(vc.title == "New Name")
    }
    
    func testUpdateFromMasterUpdatesTable() {
        vc.recipe.addItem(RecipeItem(name: "New Item", quantity: 1.0, unit: .Each))
        vc.updateFromMaster()
        XCTAssert(vc.tableView.numberOfRowsInSection(1) == 2)
    }

    func testCloneButtonExists() {
        if let toolbar = vc.toolbarItems as? [UIBarButtonItem] {
            XCTAssert(toolbar.count >= 1)
            XCTAssertNotNil(find(toolbar, vc.cloneButton))
        }
        else {
            XCTFail()
        }
    }
    
    func testCloneShowsConfirmation() {
        XCTAssert(vc.cloneButton.target as! ScalingViewController == vc)
        XCTAssert(vc.cloneButton.action == Selector("showCloneConfirmation:"))
    }
    
    func testShowCloneConfirmationShowsPopover() {
        vc.showCloneConfirmation(vc.cloneButton)
        if let controller = nc.vc as? UIAlertController {
            if let actions = controller.actions as? [UIAlertAction] {
                XCTAssert(actions[0].style == UIAlertActionStyle.Default)
                XCTAssert(actions[1].style == UIAlertActionStyle.Cancel)
            }
            else {
                XCTFail()
            }
        }
        else {
            XCTFail()
        }
    }


    // TODO: test that picker is visible from bottom cell even with toolbar
}
