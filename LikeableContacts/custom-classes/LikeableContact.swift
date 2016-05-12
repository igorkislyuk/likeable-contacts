//
//  LikeableContact.swift
//  LikeableContacts
//
//  Created by Igor on 12/05/16.
//  Copyright © 2016 Igor Kislyuk. All rights reserved.
//

import Foundation
import CoreData


class LikeableContact: NSManagedObject {
    
    override var hashValue: Int {
        var result = ""
        if let firstName = birthName {
            result.appendContentsOf(firstName)
        }
        if let secondName = middleName {
            result.appendContentsOf(secondName)
        }
        
        return result.hashValue
        
    }
    
}
