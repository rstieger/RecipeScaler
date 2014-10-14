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
    var isEditing = false
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
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.recipes.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
  
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:RecipeNameCell = tableView.dequeueReusableCellWithIdentifier("recipeNameCell") as RecipeNameCell
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
        return v as RecipeNameCell
    }

    @IBAction func startEditing(field: UITextField) {
        self.isEditing = true
        scrollToRow(field)
    }
    @IBAction func stopEditing(field : UITextField) {
        self.isEditing = false
        var cell = getParentCell(field)
        var indexPath = self.tableView.indexPathForCell(cell)!
        self.recipes[indexPath.row].name = cell.recipeName.text
        // TODO: edit nav controller of detail view in split view
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldReceiveTouch touch: UITouch!) -> Bool {
        return self.isEditing
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
        let info = notification.userInfo as [String:AnyObject]
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
        let cell = view as RecipeNameCell
        var indexPath = self.tableView.indexPathForCell(cell)!
        self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var controller: ScalingViewController
        if let navigationController = segue.destinationViewController as? UINavigationController {
            controller = navigationController.viewControllers[0] as ScalingViewController

        } else {
            controller = segue.destinationViewController as ScalingViewController
        }
        let cell = sender as UITableViewCell
        let indexPath = self.tableView.indexPathForCell(cell)!
        controller.recipe = self.recipes[indexPath.row]
    }

}

