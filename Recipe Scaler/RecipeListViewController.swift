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

class RecipeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {
    var recipes: [Recipe] = []
    var isEditing = false
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tapRec: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.recipes.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell:RecipeNameCell = tableView.dequeueReusableCellWithIdentifier("recipeNameCell") as RecipeNameCell
        cell.recipeName.text = self.recipes[indexPath.row].name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    @IBAction func addRecipe(sender : AnyObject) {
        let recipe = Recipe()
        recipe.name = "New Recipe"
        self.recipes.append(recipe)
        self.tableView.reloadData()
    }

    @IBAction func startEditing(field: UITextField) {
        self.isEditing = true
    }
    @IBAction func stopEditing(field : UITextField) {
        self.isEditing = false
        var cell = field.superview.superview as RecipeNameCell
        var indexPath = self.tableView.indexPathForCell(cell)
        self.recipes[indexPath.row].name = cell.recipeName.text
        self.tableView.reloadData()
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

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        let controller:ScalingViewController = segue.destinationViewController as ScalingViewController
        let cell = sender as UITableViewCell
        let indexPath = self.tableView.indexPathForCell(cell)
        controller.recipe = self.recipes[indexPath.row]
    }

}

