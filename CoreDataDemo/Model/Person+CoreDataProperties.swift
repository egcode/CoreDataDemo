//
//  Person+CoreDataProperties.swift
//  CoreDataDemo
//
//  Created by Eugene G on 4/29/22.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }
    
    @NSManaged public var idURL: URL?
    @NSManaged public var age: Int64
    @NSManaged public var gender: String?
    @NSManaged public var name: String?
    @NSManaged public var family: Family?

}

extension Person : Identifiable {

}
