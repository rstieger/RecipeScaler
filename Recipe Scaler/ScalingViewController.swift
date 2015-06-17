//
//  ViewController.swift
//  table test
//
//  Created by Ron Stieger on 8/1/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import UIKit
import CoreData

class EditableUITableViewCell: UITableViewCell {
    @IBOutlet var qtyTextField: UITextField!
    @IBOutlet var unitTextLabel: UIButton!
    @IBOutlet var ingredientTextField: UITextField!
}

class UnitPickerCell: UITableViewCell {
    @IBOutlet var unitPicker: UIPickerView!    
}

class ScalingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var recipe = Recipe()
    var itemToScale: RecipeItem = RecipeItem(name: "", quantity: 0.0, unit: RecipeUnit.Each)    // TODO: save this if you go back and forth
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navItem: UINavigationItem!
    var pickerPath: NSIndexPath?
    @IBOutlet var actionButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = recipe.name
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Scale To"
        }
        else {
            return "Recipe"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int
        if section == 0 {
            rows = 1
        }
        else {
            rows = self.recipe.itemCount + 1
        }
        if let path = self.pickerPath {
            if path.section == section {
                rows += 1
            }
        }
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath == self.pickerPath {
            var cell: UnitPickerCell = tableView.dequeueReusableCellWithIdentifier("unitPickerCell") as! UnitPickerCell
            var unit: RecipeUnit
            if indexPath.section == 0 {
                unit = self.itemToScale.unit
            }
            else if indexPath.row - 1 < self.recipe.itemCount {
                unit = self.recipe.items[indexPath.row - 1].unit
            }
            else {
                unit = .Each
            }
            let index = find(RecipeUnit.allValues, unit)!
            cell.unitPicker.selectRow(index, inComponent: 0, animated: false)
            return cell
        }
        else if indexPath.section == 0 {
            var cell: EditableUITableViewCell = tableView.dequeueReusableCellWithIdentifier("editableItemCell") as! EditableUITableViewCell
            cell.qtyTextField.text = self.itemToScale.quantityAsString
            cell.unitTextLabel.setTitle(self.itemToScale.unitAsString, forState: .Normal)
            if self.itemToScale.unit == .Each {
                cell.unitTextLabel.setTitle("unit", forState: .Normal)
                cell.unitTextLabel.setTitleColor(UIColor.lightTextColor(), forState: .Normal)
            }
            else {
                cell.unitTextLabel.setTitle(self.itemToScale.unitAsString, forState: .Normal)
                cell.unitTextLabel.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
            }

            cell.ingredientTextField.text = self.itemToScale.name
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            return cell
        }
        else {
            var cell: EditableUITableViewCell = tableView.dequeueReusableCellWithIdentifier("editableItemCell") as! EditableUITableViewCell
            var itemNumber = indexPath.row
            if let pickerPath = self.pickerPath {
                if pickerPath.section == 1 && pickerPath.row < itemNumber {
                    itemNumber -= 1
                }
            }
            if itemNumber == self.recipe.itemCount {
                cell.qtyTextField.text = nil
                cell.unitTextLabel.setTitle("unit", forState: .Normal)
                cell.unitTextLabel.setTitleColor(UIColor.lightTextColor(), forState: .Normal)
                cell.ingredientTextField.text = nil
            }
            else {
                cell.qtyTextField.text = self.recipe.items[itemNumber].quantityAsString
                if self.recipe.items[itemNumber].unit == .Each {
                    cell.unitTextLabel.setTitle("unit", forState: .Normal)
                    cell.unitTextLabel.setTitleColor(UIColor.lightTextColor(), forState: .Normal)
                } else {
                    cell.unitTextLabel.setTitle(self.recipe.items[itemNumber].unitAsString, forState: UIControlState.Normal)
                    cell.unitTextLabel.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
                }
                cell.ingredientTextField.text = self.recipe.items[itemNumber].name
            }
            return cell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 || indexPath.row >= self.recipe.itemCount {
            return .None
        }
        else {
            return .Delete
        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Remove"
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Insert {
            self.recipe.addItem(RecipeItem(name: "New \(indexPath.row)", quantity: 0.0, unit: nil))
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        else if editingStyle == .Delete {
            if indexPath.row < self.recipe.itemCount {
                self.recipe.deleteItem(self.recipe.items[indexPath.row])
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }
    
    @IBAction func stopEditing(field : UITextField) {
        let cell = getParentCell(field)
        if let indexPath = self.tableView.indexPathForCell(cell) {
            if indexPath.section == 0 {
                self.itemToScale.name = cell.ingredientTextField.text
                self.itemToScale.quantity = cell.qtyTextField.text.doubleValueFromFraction
                self.recipe.scaleToItem = self.itemToScale
                cell.qtyTextField.text = self.itemToScale.quantityAsString
            }
            else {
                if indexPath.row < self.recipe.itemCount {
                    self.recipe.items[indexPath.row].quantity = cell.qtyTextField.text.doubleValueFromFraction
                    self.recipe.items[indexPath.row].name = cell.ingredientTextField.text
                    cell.qtyTextField.text = self.recipe.items[indexPath.row].quantityAsString
                }
                else {
                    if cell.ingredientTextField.text != "" || cell.qtyTextField.text != "" {
                        addRecipeItem(RecipeItem(name: cell.ingredientTextField.text, quantity: cell.qtyTextField.text.doubleValueFromFraction, unit: .Each))
                    }
                }
            }
        }
        else {
            println("invalid path for stopEditing()")
        }
    }

    func clearFirstResponders() {
        for cell in self.tableView.visibleCells() {
            if let cell = cell as? EditableUITableViewCell {
                if cell.qtyTextField.editing {
                    cell.qtyTextField.resignFirstResponder()
                    break
                }
                else if cell.ingredientTextField.editing {
                    cell.ingredientTextField.resignFirstResponder()
                    break
                }
            }
        }
    }
    
    @IBAction func handleTap(sender : UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            clearFirstResponders()
            hidePicker()
        }
    }

    func addRecipeItem(item: RecipeItem) {
        self.recipe.addItem(item)
        self.tableView.reloadData()
    }

    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject!) -> Bool {
        if identifier == "scaleRecipe" {
            let cell = sender as! EditableUITableViewCell
            if let indexPath = self.tableView.indexPathForCell(cell) {
                return indexPath.section == 0
            }
            else {
                println("***invalid path for shouldPerformSegueWithIdentifier()")
                return false
            }
        }
        else {
            println("invalid segue")
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scaleRecipe" {
            let controller = segue.destinationViewController as! ScaledRecipeViewController
            var error: RecipeError?
            (controller.recipe, error) = self.recipe.getScaledToUse(self.itemToScale)
            controller.warningMessage = error?.getString()
        }
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo as! [String:AnyObject]
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        let contentInsets = UIEdgeInsetsMake(self.navigationController!.navigationBar.frame.height + self.tableView.sectionHeaderHeight, 0.0, kbSize.height + 44, 0.0)
        self.tableView.contentInset = contentInsets
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsMake(self.navigationController!.navigationBar.frame.height + self.tableView.sectionHeaderHeight, 0.0, 0.0, 0.0)
        self.tableView.contentInset = contentInsets
    }
    
    @IBAction func scrollToRow(field: UITextField) {
        let cell = getParentCell(field)
        if let indexPath = self.tableView.indexPathForCell(cell) {
            self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        }
        else {
            println("***invalid path for scrollToRow()")
        }
    }
    
    func getParentCell(view: UIView) -> EditableUITableViewCell {
        var v: UIView? = view
        while v != nil && !v!.isKindOfClass(EditableUITableViewCell) {
            v = v!.superview
        }
        return v as! EditableUITableViewCell
    }
    
    @IBAction func showPicker(sender: AnyObject) {
        if let button = sender as? UIButton {
            let cell = getParentCell(button)
            if let cellPath = self.tableView.indexPathForCell(cell) {
                if cellPath.row < self.recipe.itemCount + 1 {   // add one because always a "new ingredient" row
                    self.pickerPath = NSIndexPath(forRow: cellPath.row + 1, inSection: cellPath.section)
                    // add space at bottom to give room to adjust picker on last line
                    let contentInsets = UIEdgeInsetsMake(self.navigationController!.navigationBar.frame.height + self.tableView.sectionHeaderHeight, 0.0, 44 + self.navigationController!.toolbar.frame.height, 0.0)
                    self.tableView.contentInset = contentInsets
                    self.tableView.selectRowAtIndexPath(cellPath, animated: true, scrollPosition: .Middle)
                }
            }
            else {
                println("***invalid path for showPicker()")
                
            }
        }
        else {
            println("not from button")
        }
        self.tableView.reloadData()
    }
    
    func hidePicker() {
        if let path = self.pickerPath {
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Fade)
            self.pickerPath = nil
            let contentInsets = UIEdgeInsetsMake(self.navigationController!.navigationBar.frame.height + self.tableView.sectionHeaderHeight, 0.0, 0.0, 0.0)
            self.tableView.contentInset = contentInsets
            self.tableView.endUpdates()
        }
    }
    
    @IBAction func showActions(sender: AnyObject) {
        if let button = sender as? UIBarButtonItem {
            let activityController = UIActivityViewController(activityItems: [String(recipe: recipe)], applicationActivities: nil)
            if let popoverController = activityController.popoverPresentationController {
                popoverController.barButtonItem = button
            }
            self.navigationController!.presentViewController(activityController, animated: true, completion: nil)
        }
        else {
            println("not from button")
        }
    }
    
    @IBAction func showDeleteConfirmation(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Delete Recipe", style: .Destructive, handler: {(action: UIAlertAction!) -> Void in self.deleteAndUnwind()}))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = self.deleteButton
        }
        self.navigationController!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func deleteAndUnwind() {
        if let splitViewController = self.splitViewController {
            println("split")
            let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
            if let controller = masterNavigationController.viewControllers[0] as? RecipeListViewController {
                controller.deleteRecipe(self.recipe)
            }
        }
        self.performSegueWithIdentifier("deleteRecipe", sender: self)

    }
    
    func updateFromMaster() {
        self.title = self.recipe.name
        self.tableView.reloadData()
    }
    
    private func isSplit() -> Bool {
        if let svc = self.splitViewController {
            return !svc.collapsed
        }
        else {
            return false
        }
    }
}

extension ScalingViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RecipeUnit.allValues.count
    }
    
/*    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: RecipeUnit.standardString[RecipeUnit.allValues[row]]!, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: UIColor.blueColor()])
    }*/
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return RecipeUnit.standardString[RecipeUnit.allValues[row]]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let indexPath = self.pickerPath {
            if indexPath.section == 0 {
                self.itemToScale.unit = RecipeUnit.allValues[row]
            }
            else if indexPath.row - 1 < self.recipe.itemCount {
                self.recipe.items[indexPath.row - 1].unit = RecipeUnit.allValues[row]
            }
            else {
                addRecipeItem(RecipeItem(name: "", quantity: 0.0, unit: RecipeUnit.allValues[row]))
            }
            self.pickerPath = nil
        }
        else {
            println("***invalid path for pickerView()")
        }
        self.tableView.reloadData()
    }
}
