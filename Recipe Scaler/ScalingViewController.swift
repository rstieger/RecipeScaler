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

class ScalingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CommonViewController {
    var recipe = Recipe()
    var itemToScale: RecipeItem = RecipeItem(name: "", quantity: 0.0, unit: RecipeUnit.Each)    // TODO: save this if you go back and forth
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navItem: UINavigationItem!
    var pickerPath: NSIndexPath?
    @IBOutlet var actionButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var cloneButton: UIBarButtonItem!
    var topActionButton: UIBarButtonItem!
    var topDeleteButton: UIBarButtonItem!
    var topCloneButton: UIBarButtonItem!

    var allowedUnits: [RecipeUnit] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.startUserActivity()
        self.title = recipe.name
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        self.tableView.reloadData()
        self.allowedUnits = self.getAllowedUnits()
        self.navigationController?.navigationBar.tintColor = UIColor.salmonColor()
        self.topActionButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "showActions:")
        self.topDeleteButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "showDeleteConfirmation:")
        self.topCloneButton = UIBarButtonItem(image: UIImage(named: "Copy"), style: UIBarButtonItemStyle.Plain, target: self, action: "showCloneConfirmation:")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (self.isSplit()) {
            self.changeToSplitView()
        }
        else {
            self.changeToCollapsedView()
        }
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
            return "Scale To".localize()
        }
        else {
            return "Recipe".localize()
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
            let cell: UnitPickerCell = tableView.dequeueReusableCellWithIdentifier("unitPickerCell") as! UnitPickerCell
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
            if let index = self.allowedUnits.indexOf(unit) {
                cell.unitPicker.selectRow(index, inComponent: 0, animated: false)
            }
            else {
                let index = self.allowedUnits.indexOf(.Each)! // I know .Each is allowed
                cell.unitPicker.selectRow(index, inComponent: 0, animated: false)
            }
            return cell
        }
        else if indexPath.section == 0 {
            let cell: EditableUITableViewCell = tableView.dequeueReusableCellWithIdentifier("editableItemCell") as! EditableUITableViewCell
            cell.qtyTextField.text = self.itemToScale.quantityAsString
            cell.unitTextLabel.setTitle(self.itemToScale.unitAsString, forState: .Normal)
            if self.itemToScale.unit == .Each {
                cell.unitTextLabel.setTitle("unit".localize(), forState: .Normal)
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
            let cell: EditableUITableViewCell = tableView.dequeueReusableCellWithIdentifier("editableItemCell") as! EditableUITableViewCell
            var itemNumber = indexPath.row
            if let pickerPath = self.pickerPath {
                if pickerPath.section == 1 && pickerPath.row < itemNumber {
                    itemNumber -= 1
                }
            }
            if itemNumber == self.recipe.itemCount {
                cell.qtyTextField.text = nil
                cell.unitTextLabel.setTitle("unit".localize(), forState: .Normal)
                cell.unitTextLabel.setTitleColor(UIColor.lightTextColor(), forState: .Normal)
                cell.ingredientTextField.text = nil
            }
            else {
                cell.qtyTextField.text = self.recipe.items[itemNumber].quantityAsString
                if self.recipe.items[itemNumber].unit == .Each {
                    cell.unitTextLabel.setTitle("unit".localize(), forState: .Normal)
                    cell.unitTextLabel.setTitleColor(UIColor.lightTextColor(), forState: .Normal)
                } else {
                    cell.unitTextLabel.setTitle(self.recipe.items[itemNumber].unitAsString, forState: UIControlState.Normal)
                    cell.unitTextLabel.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
                }
                cell.ingredientTextField.text = self.recipe.items[itemNumber].name
            }
            cell.accessoryType = UITableViewCellAccessoryType.None
            return cell
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == self.pickerPath {
            return 88
        }
        else {
            return 44
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if indexPath.row < self.recipe.itemCount {
                self.recipe.deleteItem(self.recipe.items[indexPath.row])
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                self.updateUserActivityState(self.userActivity!)
            }
        }
    }
    
    @IBAction func stopEditing(field : UITextField) {
        let cell = getParentCell(field)
        if let indexPath = self.tableView.indexPathForCell(cell) {
            if indexPath.section == 0 {
                self.itemToScale.name = cell.ingredientTextField.text!
                self.itemToScale.quantity = cell.qtyTextField.text!.doubleValueFromFraction
                self.recipe.scaleToItem = self.itemToScale
                cell.qtyTextField.text = self.itemToScale.quantityAsString
            }
            else {
                if indexPath.row < self.recipe.itemCount {
                    self.recipe.items[indexPath.row].quantity = cell.qtyTextField.text!.doubleValueFromFraction
                    self.recipe.items[indexPath.row].name = cell.ingredientTextField.text!
                    cell.qtyTextField.text = self.recipe.items[indexPath.row].quantityAsString
                }
                // else wait until we tap outside of a text box before adding, or tableView.reloadData() will break things
            }
            self.updateUserActivityState(self.userActivity!)
        }
        else {
            RonicsError.report(.InvalidPath)
        }
    }

    func clearFirstResponders() {
        for cell in self.tableView.visibleCells {
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
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: self.recipe.itemCount, inSection: 1)) as? EditableUITableViewCell {
                if cell.ingredientTextField.text != "" || cell.qtyTextField.text != "" {
                    addRecipeItem(RecipeItem(name: cell.ingredientTextField.text!, quantity: cell.qtyTextField.text!.doubleValueFromFraction, unit: .Each))
                }
            }
        }
    }

    func addRecipeItem(item: RecipeItem) {
        self.recipe.addItem(item)
        self.tableView.reloadData()
        self.updateUserActivityState(self.userActivity!)
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if identifier == "scaleRecipe" {
            if let cell = sender as? EditableUITableViewCell {
                if let indexPath = self.tableView.indexPathForCell(cell) {
                    return indexPath.section == 0
                }
                else {
                    RonicsError.report(.InvalidPath)
                    return false
                }
            }
            else {
                RonicsError.report(.InvalidSender)
                return false
            }
        }
        else {
            RonicsError.report(.InvalidIdentifier)
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
        self.stopUserActivity()
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo as! [String:AnyObject]
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
        self.tableView.contentInset.bottom = kbSize.height
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset.bottom = 0
    }
    
    @IBAction func scrollToRow(field: UITextField) {
        let cell = getParentCell(field)
        if let indexPath = self.tableView.indexPathForCell(cell) {
            self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        }
        else {
            RonicsError.report(.InvalidPath)
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
                    let contentInsets = UIEdgeInsetsMake(self.navigationController!.navigationBar.frame.height + self.tableView.sectionHeaderHeight, 0.0, 88 + self.navigationController!.toolbar.frame.height, 0.0)
                    self.tableView.contentInset = contentInsets
                    self.tableView.selectRowAtIndexPath(cellPath, animated: true, scrollPosition: .Middle)
                }
            }
            else {
                RonicsError.report(.InvalidPath)
                /* this might be okay; if tableView.reloadData() is called before entering this function
                   then cell will no longer be part of the table and cellPath will be nil. This happens when 
                   you edit quantity or ingredient and then go straight to touch picker button. */
            }
        }
        else {
            RonicsError.report(.InvalidSender)
        }
        self.tableView.reloadData()
    }
    
    func hidePicker() {
        if let path = self.pickerPath {
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Fade)
            self.pickerPath = nil
            let contentInsets = UIEdgeInsetsMake(self.navigationController!.navigationBar.frame.height + self.tableView.sectionHeaderHeight, 0.0, self.navigationController!.toolbar.frame.height, 0.0)
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
            self.navigationController?.presentViewController(activityController, animated: true, completion: nil)
        }
        else {
            RonicsError.report(.InvalidSender)
        }
    }
    
    @IBAction func showDeleteConfirmation(sender: AnyObject) {
        if let button = sender as? UIBarButtonItem {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alertController.addAction(UIAlertAction(title: "Delete Recipe".localize(), style: .Destructive, handler: {(action: UIAlertAction) -> Void in self.deleteAndUnwind()}))
            alertController.addAction(UIAlertAction(title: "Cancel".localize(), style: .Cancel, handler: nil))
            if let popoverController = alertController.popoverPresentationController {
                popoverController.barButtonItem = button
            }
            self.navigationController?.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            RonicsError.report(.InvalidSender)
        }
    }
    
    func deleteAndUnwind() {
        if let splitViewController = self.splitViewController {
            if let masterNavigationController = splitViewController.viewControllers[0] as? UINavigationController {
                if let controller = masterNavigationController.viewControllers[0] as? RecipeListViewController {
                    controller.deleteRecipe(self.recipe)
                }
                else {
                    RonicsError.report(.InvalidController)
                }
            }
            else {
                RonicsError.report(.MissingNavController)
            }
        }
        self.performSegueWithIdentifier("unwindFromRecipe", sender: self)
    }

    @IBAction func showCloneConfirmation(sender: AnyObject) {
        if let button = sender as? UIBarButtonItem {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alertController.addAction(UIAlertAction(title: "Clone Recipe".localize(), style: .Default, handler: {(action: UIAlertAction) -> Void in self.cloneAndUnwind()}))
            alertController.addAction(UIAlertAction(title: "Cancel".localize(), style: .Cancel, handler: nil))
            if let popoverController = alertController.popoverPresentationController {
                popoverController.barButtonItem = button
            }
            self.navigationController?.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            RonicsError.report(.InvalidSender)
        }
    }
    
    func cloneAndUnwind() {
        if let splitViewController = self.splitViewController {
            if let masterNavigationController = splitViewController.viewControllers[0] as? UINavigationController {
                if let controller = masterNavigationController.viewControllers[0] as? RecipeListViewController {
                    controller.addRecipe(self.recipe)
                }
                else {
                    RonicsError.report(.InvalidController)
                }
            }
            else {
                RonicsError.report(.MissingNavController)
            }
        }
        self.performSegueWithIdentifier("unwindFromRecipe", sender: self)
    }

    func updateFromMaster() {
        self.title = self.recipe.name
        self.tableView.reloadData()
        self.updateUserActivityState(self.userActivity!)
    }
    
    private func isSplit() -> Bool {
        if let svc = self.splitViewController {
            return !svc.collapsed
        }
        else {
            return false
        }
    }
    
    func changeToSplitView() {
        self.navigationItem.rightBarButtonItems = [self.topCloneButton, self.topActionButton, self.topDeleteButton]
        self.navigationController?.toolbarHidden = true
    }
    
    func changeToCollapsedView() {
        self.navigationController?.toolbarHidden = false
        self.navigationItem.rightBarButtonItems = []
   }
    
    func getAllowedUnits() ->  [RecipeUnit] {
        var unitRegions: [UnitRegion] = []
        let settings = NSUserDefaults.standardUserDefaults()
        if settings.boolForKey("SettingsEnableUnitsUS") {
            unitRegions.append(.US)
        }
        if settings.boolForKey("SettingsEnableUnitsUK") {
            unitRegions.append(.UK)
        }
        if settings.boolForKey("SettingsEnableUnitsMetric") {
            unitRegions.append(.Metric)
        }
        return RecipeUnit.getAllValues(unitRegions)
    }
    
    func startUserActivity() {
        let activity = NSUserActivity(activityType: "com.ronstieger.recipescaler.edit")
        activity.title = "Viewing Recipe"
        activity.userInfo = ["Recipe": String(recipe: self.recipe)]
        self.userActivity = activity
        self.userActivity?.becomeCurrent()
    }
    
    override func updateUserActivityState(activity: NSUserActivity) {
        activity.addUserInfoEntriesFromDictionary(["Recipe": String(recipe: self.recipe)])
        super.updateUserActivityState(activity)
    }
    
    func stopUserActivity() {
        userActivity?.invalidate()
    }
}

extension ScalingViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.allowedUnits.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.allowedUnits[row].string
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let indexPath = self.pickerPath {
            if indexPath.section == 0 {
                self.itemToScale.unit = self.allowedUnits[row]
            }
            else if indexPath.row - 1 < self.recipe.itemCount {
                self.recipe.items[indexPath.row - 1].unit = self.allowedUnits[row]
            }
            else {
                addRecipeItem(RecipeItem(name: "", quantity: 0.0, unit: self.allowedUnits[row]))
            }
            self.pickerPath = nil
        }
        else {
            RonicsError.report(.InvalidPath)
        }
        self.tableView.reloadData()
    }
}
