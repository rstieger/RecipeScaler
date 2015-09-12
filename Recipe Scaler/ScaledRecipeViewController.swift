//
//  TableViewController.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 8/6/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import UIKit

class ScaledRecipeViewController: UITableViewController, CommonViewController {
    var recipe = Recipe()
    var warningMessage: String?
    @IBOutlet var actionButton: UIBarButtonItem!
    var topActionButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: nil, action: "showActions:")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.tintColor = UIColor.salmonColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (self.isSplit()) {
            self.changeToSplitView()
        }
        else {
            self.changeToCollapsedView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if warningMessage != nil {
            return 2
        }
        else {
            return 1
        }
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if warningMessage != nil && section == 0 {
            return 1
        }
        else {
            return self.recipe.itemCount
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if warningMessage != nil && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("warningCell") as UITableViewCell!
            cell.textLabel?.text = self.warningMessage
            cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.textLabel?.numberOfLines = 0
            cell.backgroundColor = UIColor.salmonColor() // need to do it programatically on iPad
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("recipeItemCell") as UITableViewCell!
            cell.textLabel?.text = self.recipe.getIngredientQuantity(indexPath.row)
            cell.detailTextLabel?.text = self.recipe.getIngredientName(indexPath.row)
            return cell
        }
    }
    
    @IBAction func showActions(sender : AnyObject) {
        if let button = sender as? UIBarButtonItem {
            let activityController = UIActivityViewController(activityItems: [String(recipe: recipe)], applicationActivities: nil)
            if let popoverController = activityController.popoverPresentationController {
                popoverController.barButtonItem = button
            }
            self.navigationController?.presentViewController(activityController, animated: true, completion: nil)
        }
        else {
            RonicsError.report(.InvalidSender)
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
    
    func changeToSplitView() {
        self.navigationItem.rightBarButtonItem = self.topActionButton
        self.navigationController?.toolbarHidden = true
    }
    
    func changeToCollapsedView() {
        self.navigationController?.toolbarHidden = false
        self.navigationItem.rightBarButtonItem = nil
    }
}

