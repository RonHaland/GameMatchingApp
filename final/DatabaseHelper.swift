//
//  DatabaseHelper.swift
//  final
//
//  Created by Benjamin Dagg on 10/19/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import Firebase

/*
 This class lets you interact with the database from anywhere
 in the program. Has functions to log user in, get info from database
 */
class DatabaseHelper {
    
    //reference for database to get info
    static let ref = Database.database().reference()
  
    
    
    /*
     logs in user with Firebase's authentication function then returns true if login successfull or false if login failed
    */
    static func loginUser(email:String, password:String,handler: @escaping (Bool)->Void) {
    
        var loginSuccess = false
        
        //try to log user in
        Auth.auth().signIn(withEmail: email , password: password, completion: { (user, error) in
            
            //login failed
            if error != nil {
                loginSuccess = false
                //call handler to return value
                handler(loginSuccess)
                
            }
            //login success
            else{
                print("correct loginnn")
                loginSuccess = true
                //call handler tto return value
                handler(loginSuccess)
                }
            }
        )
    
    }
    
    
    /*
     Chekcs that there is a user currently logged
     in then returns a User object filled out with that users
     info retrieved from the database
    */
    static func getCurrentUser() -> User? {
        
        //default user object that is returned
        var returnedUser:User
        
        //make sure that there is a user logged in
        let user = Auth.auth().currentUser
        
        //user is signed in
        if ((user) != nil){
            var userName:String
            var email:String
            var uid:String
            var name:String
            
            if let username = user?.displayName{
                userName = username
            }
            else{
                userName = ""
            }
            if let userEmail = user?.email{
                email = userEmail
            }
            else{
                email = ""
            }
            if let userID = user?.uid {
                uid = userID
            }
            else{
                uid = ""
            }
            name = ""
            
            returnedUser = User(userName: userName, name: name, email: email, userID: uid)
            return returnedUser
            
        }
        //there is no user signed in
        else{
            return nil
        }
    }
    
    
    /*
     Takes in string username and returns true if it already exists or false if it is open
    */
    static func usernameTaken(username: String, completion: @escaping (Bool) -> Void) {
    
    
        ref.child("takenUsernames").child(username).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists() {
                print("in class i was a dupe")
                completion(true)
            
            }
            else {
                print("in class it was not a dupe")
                completion(false)
            }
        
        })
        
        
    }
    
    /*
     Takes in username as string and adds it to the takenUsernames
    */
    static func appendToTakenUsernames(username: String){
        ref.child("takenUsernames").child(username).setValue(["username":username])
    }
    
    
    
    /*
     Called in RegisterViewController. Adds new users info into the users table of the database
    */
    static func appendToUsers(user:User){
        
       
       let newUser = ["username":user.userName,
                      "name":user.name,
                      "email":user.email,
                      "uid":user.userID]
       let child = ["/users/\(user.userName)":newUser]
       ref.updateChildValues(child)
    }
    
    
    
    
    
}
