//
//  TableViewController.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 8/6/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource{
    var recipe = RecipeModel()
    @IBOutlet var leftNavButton: UIBarButtonItem!
    @IBOutlet var rightNavButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.recipe.itemCount
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
           var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("recipeItemCell") as UITableViewCell
            cell.textLabel.text = self.recipe.getIngredientQuantity(indexPath.row)
            cell.detailTextLabel.text = self.recipe.getIngredientName(indexPath.row)
            return cell
    }
    
}

