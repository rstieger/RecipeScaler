//
//  TableViewController.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 8/6/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import UIKit

class ScaledRecipeViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource{
    var recipe = Recipe()
    var warningMessage: String?
    @IBOutlet var actionButton: UIBarButtonItem!
    var savedToolbar: [AnyObject]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setActionLocation:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        self.savedToolbar = self.toolbarItems
        setActionLocation(NSNotification(name: UIDeviceOrientationDidChangeNotification, object: nil))
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
    
    func setActionLocation(notification: NSNotification) {
        // check if still split (iPhone 6 Plus will change)
        if self.isSplit() {
            self.toolbarItems = nil
            self.navigationItem.rightBarButtonItem = self.actionButton
            // TODO: may want to hide toolbar completely, but need to make sure it's restored on pop segue
        }
        else {
            self.toolbarItems = self.savedToolbar
            self.navigationItem.rightBarButtonItem = nil
        }
        // bug: if changed from portrait to landscape to quickly in simulator, isSplit() may still return the old state
    }

}

