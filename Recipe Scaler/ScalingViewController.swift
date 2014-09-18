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
    @IBOutlet var unitPicker: UIPickerView!
    @IBOutlet var ingredientTextField: UITextField!
}

class ScalingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var recipe = Recipe()
    var itemToScale: RecipeItem?
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navItem: UINavigationItem!
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navItem.title = recipe.name
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
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
        if section == 0 {
            return 1
        }
        else {
            return self.recipe.itemCount
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:EditableUITableViewCell = tableView.dequeueReusableCellWithIdentifier("editableItemCell") as EditableUITableViewCell
        if indexPath.section == 0 {
            if let item = self.itemToScale {
                cell.qtyTextField.text = "\(item.quantity)"
                cell.ingredientTextField.text = item.name
            }
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        } else {
            cell.qtyTextField.text = self.recipe.getIngredientQuantity(indexPath.row)
            cell.ingredientTextField.text = self.recipe.getIngredientName(indexPath.row)
            if let unit = self.recipe.getIngredientUnit(indexPath.row) {
                cell.unitPicker.selectRow(find(RecipeUnit.allValues, unit)!, inComponent: 0, animated: false)
            }
            else {
                cell.unitPicker.selectRow(find(RecipeUnit.allValues, RecipeUnit.Each)!, inComponent: 0, animated: false)
            }
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
            self.itemToScale = RecipeItem(name: cell.ingredientTextField.text, quantity: (cell.qtyTextField.text as NSString).doubleValue, unit: nil)
        }
        else {
            self.recipe.items[indexPath.row].quantity = (cell.qtyTextField.text as NSString).doubleValue
            self.recipe.items[indexPath.row].name = cell.ingredientTextField.text
        }
        self.tableView.reloadData()
    }

    @IBAction func viewTapped(sender : AnyObject) {
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
        let cell = getParentCell(pickerView)
        let indexPath = self.tableView.indexPathForCell(cell)!
        if indexPath.section == 0 {
            self.itemToScale = RecipeItem(name: cell.ingredientTextField.text, quantity: (cell.qtyTextField.text as NSString).doubleValue, unit: RecipeUnit.allValues[row])
        }
        else {
            self.recipe.items[indexPath.row].quantity = (cell.qtyTextField.text as NSString).doubleValue
            self.recipe.items[indexPath.row].name = cell.ingredientTextField.text
            self.recipe.items[indexPath.row].unit = RecipeUnit.allValues[row]
        }
        self.tableView.reloadData()
        
    }
}
