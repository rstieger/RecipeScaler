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
    var detailViewController: ScalingViewController? {
        get {
            var ret: ScalingViewController?
            if let splitViewController = self.splitViewController {
                let detailNavigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
                if let controller = detailNavigationController.viewControllers[0] as? ScalingViewController {
                    ret = controller
                }
            }
            return ret
        }
    }
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideOrShowToolbar:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        hideOrShowToolbar(NSNotification(name: UIDeviceOrientationDidChangeNotification, object: nil))

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
    
    func deleteRecipeAtIndex(index: Int) {
        self.recipes.removeAtIndex(index)
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        // switch to a recipe that still exists
        if let controller = self.detailViewController {
            if self.recipes.count == 0 {
                self.recipes.append(Recipe()) // so we always have one to see in detail view
                self.tableView.reloadData()
            }
            var newRow = index
            if newRow >= self.recipes.count {
                newRow = self.recipes.count - 1
            }
            controller.recipe = self.recipes[newRow]
            controller.updateFromMaster()
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteRecipeAtIndex(indexPath.row)
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:RecipeNameCell = tableView.dequeueReusableCellWithIdentifier("recipeNameCell") as! RecipeNameCell
        let name = self.recipes[indexPath.row].name
        cell.recipeName.text = name
        if name != "" {
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }
    
    @IBAction func addRecipe(sender : AnyObject) {
        let recipe = Recipe()
        self.recipes.append(recipe)
        self.tableView.reloadData()
    }
    
    private func getParentCell(view: UIView) -> RecipeNameCell {
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
        if let controller = self.detailViewController {
            controller.updateFromMaster()
        }
        self.tableView.reloadData()
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

    func keyboardWillShow(notification: NSNotification) {
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
        let cell = getParentCell(field)
        var indexPath = self.tableView.indexPathForCell(cell)!
        self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }

    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "selectRecipe" {
            let cell = sender as! RecipeNameCell
            if cell.recipeName.text == "" {
                return false
            }
        }
        return true
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

    func deleteRecipe(recipe: Recipe) {
        if let index = recipes.getRecipeIndex(recipe) {
            deleteRecipeAtIndex(index)
        }
    }
    
    @IBAction func deleteFromChildPage(segue:UIStoryboardSegue) {
        if segue.identifier == "deleteRecipe" {
            if let recipeViewController = segue.sourceViewController as? ScalingViewController {
                let recipe = recipeViewController.recipe
                deleteRecipe(recipe)
            }
            else {
                println("bad segue!")
            }
        }
        else {
            println("not delete")
        }
    }
    
    private func isSplit() -> Bool {
        if let svc = self.splitViewController {
            return !svc.collapsed
        }
        else {
            return false
        }
    }
    
    func hideOrShowToolbar(notification: NSNotification) {
        // check if still split (iPhone 6 Plus will change)
        if self.isSplit() {
            self.navigationController?.setToolbarHidden(true, animated: false)
        }
        else {
            self.navigationController?.setToolbarHidden(false, animated: false)
        }
        // bug: if changed from portrait to landscape to quickly in simulator, isSplit() may still return the old state
    }
}

