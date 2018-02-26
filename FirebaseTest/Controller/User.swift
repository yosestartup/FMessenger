//
//  User.swift
//  FirebaseTest
//
//  Created by Александр on 25.02.18.
//  Copyright © 2018 hilton. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var email: String?
    var profileImageUrl: String?
    
    
    
    init(dictionary: [String: AnyObject]) {
        
        super.init()
        name = dictionary["name"] as? String
        email = dictionary["email"] as? String
        profileImageUrl = dictionary["profileImageUrl"] as? String
    }

}
