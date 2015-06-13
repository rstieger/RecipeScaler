//
//  TableViewController.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 8/6/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import UIKit

class RecipeViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource{
    var recipe = Recipe()
    var warningMessage: String?
    @IBOutlet var actionButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if self.isSplit() {
            self.navigationItem.rightBarButtonItem = actionButton
            self.toolbarItems?.removeAll(keepCapacity: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if warningMessage != nil {
            return 2
        } else {
            return 1
        }
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if warningMessage != nil && section == 0 {
            return 1
        } else {
            return self.recipe.itemCount
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if warningMessage != nil && indexPath.section == 0 {
            var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("warningCell") as! UITableViewCell
            cell.textLabel!.text = self.warningMessage
            cell.backgroundColor = UIColor.salmonColor() // need to do it programatically on iPad
            return cell
        } else {
            var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("recipeItemCell") as! UITableViewCell
            cell.textLabel!.text = self.recipe.getIngredientQuantity(indexPath.row)
            cell.detailTextLabel!.text = self.recipe.getIngredientName(indexPath.row)
            return cell
        }
    }
    
    @IBAction func showActions(sender : AnyObject) {
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
    
    private func isSplit() -> Bool {
        if let svc = self.splitViewController {
            return !svc.collapsed
        }
        else {
            return false
        }
    }
}

