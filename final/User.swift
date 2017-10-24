//
//  User.swift
//  final
//
//  Created by Benjamin Dagg on 10/19/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

/*
 Holds information for a database user so you dont
 have to get it from the database every time. Need to add
 games array and other user info like location, time zone
*/
class User {
    
    var userName:String
    var name:String
    var email:String
    var userID:String
    
    init(userName:String, name:String,email:String,userID:String) {
        self.userName = userName
        self.name = name
        self.email = email
        self.userID = userID
    }
    
}
