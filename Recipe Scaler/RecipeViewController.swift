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
    @IBOutlet var navItem: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
            var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("warningCell") as UITableViewCell
            cell.textLabel!.text = self.warningMessage
            cell.backgroundColor = UIColor(red: 0.98, green: 0.5, blue: 0.45, alpha: 1.0) // need to do it programatically on iPad
            return cell
        } else {
            var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("recipeItemCell") as UITableViewCell
            cell.textLabel!.text = self.recipe.getIngredientQuantity(indexPath.row)
            cell.detailTextLabel!.text = self.recipe.getIngredientName(indexPath.row)
            return cell
        }
    }
    
}

