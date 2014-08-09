//
//  ViewController.swift
//  table test
//
//  Created by Ron Stieger on 8/1/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import UIKit


class EditableUITableViewCell: UITableViewCell {
    @IBOutlet var qtyTextField: UITextField!
    @IBOutlet var ingredientTextField: UITextField!
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var recipe = RecipeModel()
    var itemToScale: RecipeItem?
    var allowEditing = false
    @IBOutlet var tableView: UITableView!
    @IBOutlet var leftNavButton: UIBarButtonItem?
    @IBOutlet var rightNavButton: UIBarButtonItem?
    @IBOutlet var navItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.recipe.addItem(RecipeItem(name: "Milk", quantity: 2.0, unit: nil))
        self.recipe.addItem(RecipeItem(name: "egg", quantity: 1.0, unit: nil))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        if section == 0 {
            return "Scale To"
        }
        else {
            return "Recipe"
        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return self.recipe.itemCount
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:EditableUITableViewCell = tableView.dequeueReusableCellWithIdentifier("editableItemCell") as EditableUITableViewCell
        if indexPath.section == 0 {
            if let item = self.itemToScale {
                cell.qtyTextField.text = "\(item.quantity)"
                cell.ingredientTextField.text = item.name
            }
            if self.allowEditing {
                cell.accessoryType = UITableViewCellAccessoryType.None
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
        } else {
            cell.qtyTextField.text = self.recipe.getIngredientQuantity(indexPath.row)
            cell.ingredientTextField.text = self.recipe.getIngredientName(indexPath.row)
        }
        return cell
    }

    func textFieldShouldBeginEditing(textField: UITextField!) -> Bool {
        return self.allowEditing
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println("You selected cell #\(indexPath.row)!")
    }

    func tableView(tableView: UITableView!, editingStyleForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .None
        }
        else {
            return .Delete
        }
    }
    
    func tableView(tableView: UITableView!, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath!) -> String! {
        return "Remove"
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Insert {
            self.recipe.addItem(RecipeItem(name: "New \(indexPath.row)", quantity: 0.0, unit: nil))
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        else if editingStyle == .Delete {
            self.recipe.deleteItem(self.recipe.items[indexPath.row])
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

    func tableView(tableView: UITableView!, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath!) {
        println("scaling")
        if indexPath.section == 0 {
            let cell = self.tableView!.cellForRowAtIndexPath(indexPath) as EditableUITableViewCell
            self.recipe.scaleToUse(RecipeItem(name: cell.ingredientTextField.text, quantity: cell.qtyTextField.text.bridgeToObjectiveC().doubleValue, unit: nil))
            self.tableView.reloadData()
        }
    }
    
    @IBAction func scaleRecipe(sender : AnyObject) {
/*        self.recipe.scaleToUse(RecipeItem(name: self.ingredientTextField!.text, quantity: self.quantityTextField!.text.bridgeToObjectiveC().doubleValue, unit: nil))
 */       self.tableView!.reloadData()
    }

    @IBAction func stopEditing(field : UITextField) {
   /*
if field.editing {
            field.resignFirstResponder()
        }
*/
        var cell = field.superview.superview as EditableUITableViewCell
        var indexPath = self.tableView!.indexPathForCell(cell)
        if indexPath.section == 0 {
            self.itemToScale = RecipeItem(name: cell.ingredientTextField.text, quantity: cell.qtyTextField.text.bridgeToObjectiveC().doubleValue, unit: nil)
        }
        else {
            self.recipe.items[indexPath.row].quantity = cell.qtyTextField.text.bridgeToObjectiveC().doubleValue
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

    @IBAction func setEditMode(sender : AnyObject) {
        self.allowEditing = true
        self.navItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "clearEditMode:"), animated: true)
        self.navItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addRecipeItem:"), animated: true)
    }
    
    @IBAction func clearEditMode(sender : AnyObject) {
        self.allowEditing = false
        self.navItem.leftBarButtonItem = nil
        self.navItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "setEditMode:"), animated: true)
    }
    
    @IBAction func addRecipeItem(sender : AnyObject) {
        println("adding")
        self.recipe.addItem(RecipeItem(name: "ingredient", quantity: 0.0, unit: nil))
        println("\(self.recipe.itemCount) items")
        self.tableView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        let controller:TableViewController = segue.destinationViewController as TableViewController
        println(self.recipe.getIngredientQuantity(0))
        if let item = self.itemToScale {
            self.recipe.scaleToUse(item)
            println(self.recipe.getIngredientQuantity(0))
        }
        controller.recipe = self.recipe
    }
}

