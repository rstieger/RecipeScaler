//
//  RecipeItem.swift
//  Recipe Scaler
//
//  Created by Ron Stieger on 8/9/14.
//  Copyright (c) 2014 Ron Stieger. All rights reserved.
//

import Foundation
import CoreData

class ManagedRecipeItem: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var quantity: NSNumber
    @NSManaged var unit: String
    @NSManaged var recipe: ManagedRecipe
}
