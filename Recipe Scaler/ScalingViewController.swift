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
    var itemToScale: RecipeItem = RecipeItem(name: "ingredient", quantity: 1.0, unit: RecipeUnit.Each)
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navItem: UINavigationItem!
    var pickerPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navItem.title = recipe.name
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
//        self.pickerPath = NSIndexPath(forRow: 0, inSection: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String! {
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
            rows = self.recipe.itemCount
        }
        if let path = self.pickerPath {
            if path.section == section {
                rows += 1
            }
        }
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:EditableUITableViewCell = tableView.dequeueReusableCellWithIdentifier("editableItemCell") as EditableUITableViewCell
        if indexPath == self.pickerPath {
            return tableView.dequeueReusableCellWithIdentifier("unitPickerCell") as UITableViewCell
        }
        else if indexPath.section == 0 {
            cell.qtyTextField.text = "\(self.itemToScale.quantity)"
            cell.unitTextLabel.setTitle(self.itemToScale.unitAsString, forState: UIControlState.Normal)
            cell.ingredientTextField.text = self.itemToScale.name
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        else {
            var itemNumber = indexPath.row
            if let pickerPath = self.pickerPath {
                if pickerPath.section == 1 && pickerPath.row < itemNumber {
                    itemNumber -= 1
                }
            }
            cell.qtyTextField.text = "\(self.recipe.items[itemNumber].quantity)"
            cell.unitTextLabel.setTitle(self.recipe.items[itemNumber].unitAsString, forState: UIControlState.Normal)
            cell.ingredientTextField.text = self.recipe.items[itemNumber].name
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .None
        }
        else {
            return .Delete
        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Remove"
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Insert {
            self.recipe.addItem(RecipeItem(name: "New \(indexPath.row)", quantity: 0.0, unit: nil))
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        else if editingStyle == .Delete {
            self.recipe.deleteItem(self.recipe.items[indexPath.row])
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    @IBAction func stopEditing(field : UITextField) {
        let cell = getParentCell(field)
        let indexPath = self.tableView.indexPathForCell(cell)!
        if indexPath.section == 0 {
            self.itemToScale.name = cell.ingredientTextField.text
            self.itemToScale.quantity = (cell.qtyTextField.text as NSString).doubleValue
        }
        else {
            self.recipe.items[indexPath.row].quantity = (cell.qtyTextField.text as NSString).doubleValue
            self.recipe.items[indexPath.row].name = cell.ingredientTextField.text
        }
        self.tableView.reloadData()
    }

    func clearFirstResponders() {
        for cell in self.tableView!.visibleCells() {
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
    
    @IBAction func viewTapped(sender : AnyObject) {
        clearFirstResponders()
        hidePicker()
    }

    @IBAction func addRecipeItem(sender : AnyObject) {
        self.recipe.addItem(RecipeItem(name: "ingredient", quantity: 0.0, unit: nil))
        self.tableView.reloadData()
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        let cell = sender as EditableUITableViewCell
        let indexPath = self.tableView.indexPathForCell(cell)!
        return indexPath.section == 0
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller:RecipeViewController = segue.destinationViewController as RecipeViewController
        controller.recipe = self.recipe.getScaledToUse(self.itemToScale)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo as [String:AnyObject]
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
        let indexPath = self.tableView.indexPathForCell(cell)!
        self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }
    
    func getParentCell(view: UIView) -> EditableUITableViewCell {
        var v: UIView? = view
        while v != nil && !v!.isKindOfClass(EditableUITableViewCell) {
            v = v!.superview
        }
        return v as EditableUITableViewCell
    }
    
    @IBAction func showPicker(sender: AnyObject) {
        if sender.isKindOfClass(UIButton) {
            let button = sender as UIButton
            let cell = getParentCell(button)
            let cellPath = self.tableView.indexPathForCell(cell)!
            self.pickerPath = NSIndexPath(forRow: cellPath.row + 1, inSection: cellPath.section)
        }
        self.tableView.reloadData()
    }
    
    func hidePicker() {
        if let path = self.pickerPath {
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Fade)
            self.pickerPath = nil
            self.tableView.endUpdates()
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
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return RecipeUnit.standardString[RecipeUnit.allValues[row]]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let indexPath = self.pickerPath!
        if indexPath.section == 0 {
            self.itemToScale.unit = RecipeUnit.allValues[row]
        }
        else {
            self.recipe.items[indexPath.row-1].unit = RecipeUnit.allValues[row]
        }
        self.pickerPath = nil
        self.tableView.reloadData()
    }
}