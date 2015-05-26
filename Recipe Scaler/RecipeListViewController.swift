//
//  RecipeListViewController.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 8/10/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import UIKit

class RecipeNameCell: UITableViewCell {
    @IBOutlet var recipeName: UITextField!
}

class RecipeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var recipes = RecipeList()
    var editingMode = false
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tapRec: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
   }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recipes.count
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Remove"
    }
    
    func deleteRecipe(index: Int) {
        self.recipes.removeAtIndex(index)
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        // switch to a recipe that still exists
        if let splitViewController = self.splitViewController {
            let detailNavigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
            if let controller = detailNavigationController.viewControllers[0] as? ScalingViewController {
                if self.recipes.count == 0 {
                    self.recipes.append(Recipe()) // so we always have one to see in detail view
                    self.tableView.reloadData()
                }
                var newRow = index
                if newRow >= self.recipes.count {
                    newRow = self.recipes.count - 1
                }
                controller.recipe = self.recipes[newRow]
                controller.title = self.recipes[newRow].name
                controller.tableView.reloadData()
            }
        }

    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteRecipe(indexPath.row)
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:RecipeNameCell = tableView.dequeueReusableCellWithIdentifier("recipeNameCell") as! RecipeNameCell
        cell.recipeName.text = self.recipes[indexPath.row].name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    @IBAction func addRecipe(sender : AnyObject) {
        let recipe = Recipe()
        self.recipes.append(recipe)
        self.tableView.reloadData()
    }
    func getParentCell(view: UIView) -> RecipeNameCell {
        var v: UIView? = view
        while v != nil && !v!.isKindOfClass(RecipeNameCell) {
            v = v!.superview
        }
        return v as! RecipeNameCell
    }

    @IBAction func startEditing(field: UITextField) {
        self.editingMode = true
        scrollToRow(field)
    }
    @IBAction func stopEditing(field : UITextField) {
        self.editingMode = false
        var cell = getParentCell(field)
        var indexPath = self.tableView.indexPathForCell(cell)!
        self.recipes[indexPath.row].name = cell.recipeName.text
        // if this is a split view, update detail title
        if let splitViewController = self.splitViewController {
            let detailNavigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
            if let controller = detailNavigationController.viewControllers[0] as? ScalingViewController {
                controller.title = cell.recipeName.text
                controller.recipe = self.recipes[indexPath.row]
                controller.tableView.reloadData()
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldReceiveTouch touch: UITouch!) -> Bool {
        return self.editingMode
    }
    
    @IBAction func viewTapped(sender : AnyObject) {
        for cell in self.tableView.visibleCells() {
            if let cell = cell as? RecipeNameCell {
                if cell.recipeName.editing {
                    cell.recipeName.resignFirstResponder()
                    break
                }
            }
        }
    }

    func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo as! [String:AnyObject]
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        let contentInsets = UIEdgeInsetsMake(self.navigationController!.navigationBar.frame.height + self.tableView.sectionHeaderHeight, 0.0, kbSize.height, 0.0)
        self.tableView.contentInset = contentInsets
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsMake(self.navigationController!.navigationBar.frame.height + self.tableView.sectionHeaderHeight, 0.0, 0.0, 0.0)
        self.tableView.contentInset = contentInsets
    }
  
    @IBAction func scrollToRow(field: UITextField) {
       var view: UIView? = field
        while view != nil && !view!.isKindOfClass(RecipeNameCell) {
            view = view!.superview
        }
        let cell = view as! RecipeNameCell
        var indexPath = self.tableView.indexPathForCell(cell)!
        self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var controller: ScalingViewController
        if let navigationController = segue.destinationViewController as? UINavigationController {
            controller = navigationController.viewControllers[0] as! ScalingViewController

        } else {
            controller = segue.destinationViewController as! ScalingViewController
        }
        let cell = sender as! UITableViewCell
        let indexPath = self.tableView.indexPathForCell(cell)!
        let recipe = self.recipes[indexPath.row]
        controller.recipe = recipe
        if let itemToScale = recipe.scaleToItem {
            controller.itemToScale = itemToScale
        }
    }

    @IBAction func deleteFromRecipe(segue:UIStoryboardSegue) {
        if segue.identifier == "deleteRecipe" {
            if let recipeViewController = segue.sourceViewController as? ScalingViewController {
                let recipe = recipeViewController.recipe
                if let index = recipes.getRecipeIndex(recipe) {
                    deleteRecipe(index)
                }
            }
            else {
                println("bad segue!")
            }
        }
        else {
            println("not delete")
        }
    }
}

