//
//  Music+CoreDataProperties.swift
//  
//
//  Created by Chadwick Zhao on 11/11/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Music {

    @NSManaged var name: String?
    @NSManaged var record: String?
    @NSManaged var speed: String?

}
