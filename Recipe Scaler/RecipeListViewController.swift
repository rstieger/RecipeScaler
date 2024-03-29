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
    @IBOutlet var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if self.recipes.count == 0 {
            addRecipe(nil)  // so we always have one
            self.detailViewController?.recipe = self.recipes[0]
            self.detailViewController?.title = ""
        }
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
    
    func deleteRecipeAtIndex(index: Int) {
        self.recipes.removeAtIndex(index)
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        // switch to a recipe that still exists
        if self.recipes.count == 0 {
            self.recipes.append(Recipe()) // so we always have one to see in detail view
            self.detailViewController?.recipe = self.recipes[0]
            self.detailViewController?.title = ""
            self.tableView.reloadData()
        }
        if let controller = self.detailViewController {
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
        let cell = tableView.dequeueReusableCellWithIdentifier("recipeNameCell") as! RecipeNameCell
        let name = self.recipes[indexPath.row].name
        cell.recipeName.text = name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    func addRecipe(recipe: Recipe?) {
        if let r = recipe {
            self.recipes.append(r)
        }
        else {
            self.recipes.append(Recipe())
        }
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
        let cell = getParentCell(field)
        if let indexPath = self.tableView.indexPathForCell(cell) {
            self.recipes[indexPath.row].name = cell.recipeName.text!
            // if this is a split view, update detail title
            if let controller = self.detailViewController {
                controller.updateFromMaster()
            }
        }
        else {
            RonicsError.report(.InvalidPath)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldReceiveTouch touch: UITouch!) -> Bool {
        return self.editingMode
    }
    
    @IBAction func viewTapped(sender : AnyObject) {
        for cell in self.tableView.visibleCells {
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

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var controller: ScalingViewController
        if let navigationController = segue.destinationViewController as? UINavigationController {
            controller = navigationController.viewControllers[0] as! ScalingViewController

        } else {
            controller = segue.destinationViewController as! ScalingViewController
        }
        if let cell = sender as? UITableViewCell {
            if let indexPath = self.tableView.indexPathForCell(cell) {
                let recipe = self.recipes[indexPath.row]
                controller.recipe = recipe
                if let itemToScale = recipe.scaleToItem {
                    controller.itemToScale = itemToScale
                }
            }
            else {
                RonicsError.report(.InvalidPath)
            }
        }
        else {
            RonicsError.report(.InvalidSender)
        }
    }

    func deleteRecipe(recipe: Recipe) {
        if let index = recipes.getRecipeIndex(recipe) {
            deleteRecipeAtIndex(index)
        }
    }
    
    @IBAction func unwindFromChildPage(segue:UIStoryboardSegue) {
        if segue.identifier == "unwindFromRecipe" {
            if let recipeViewController = segue.sourceViewController as? ScalingViewController {
// TODO: what did I mean to do here?
                _ = recipeViewController.recipe
            }
            else {
                RonicsError.report(.InvalidController)
            }
        }
        else {
            RonicsError.report(.InvalidIdentifier)
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
    
    @IBAction func showAddMenu(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "New".localize(), style: .Default, handler: {(action: UIAlertAction) -> Void in self.addRecipe(nil)}))
        if let textLines = UIPasteboard.generalPasteboard().string {
        
            alertController.addAction(UIAlertAction(title: "Paste".localize(), style: .Default, handler: {(action: UIAlertAction) -> Void in self.addRecipe(Recipe(fromString: textLines))}))
        }
        alertController.addAction(UIAlertAction(title: "Cancel".localize(), style: .Cancel, handler: nil))
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = self.addButton
        }
        self.navigationController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func restoreUserActivityState(activity: NSUserActivity) {
        if let recipeString = activity.userInfo?["Recipe"] as? String {
            let userRecipe = Recipe(fromString: recipeString)
            var foundIndex: Int?
            for index in 0..<self.recipes.count {
                if self.recipes[index] == userRecipe {
                    foundIndex = index
                    break
                }
            }
            if foundIndex == nil {
                foundIndex = self.recipes.count
                self.addRecipe(userRecipe)
            }
            let recipeIndex = NSIndexPath(forRow: foundIndex!, inSection: 0)
            self.tableView.selectRowAtIndexPath(recipeIndex, animated: true, scrollPosition: .Middle    )
            self.performSegueWithIdentifier("selectRecipe", sender: self.tableView.cellForRowAtIndexPath(recipeIndex))
        }
        else {
            RonicsError.report(.InvalidActivity)
        }
    }
}

