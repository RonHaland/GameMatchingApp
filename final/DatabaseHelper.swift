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
    
    static func getUser(){
        
        //there is a user logged in
        if let user = Auth.auth().currentUser {
            
            /*
            let group = DispatchGroup()
            var returnedUser:User = User(userName: "", name: "", email: user.email!, userID: user.uid, games: nil)
            
            
            if let email = Auth.auth().currentUser?.email {
                print("if let email")
                
                group.enter()
                DatabaseHelper.getUsername(email: email) { result in
                    returnedUser.userName = result
                    print("result ---- \(result)")
                    group.enter()
                    DatabaseHelper.getUserGames(username: result) { games in
                        returnedUser.games = games
                        group.leave()
                        
                    }
                    group.enter()
                    DatabaseHelper.getNameByUsername(username: result) {name in
                        print("found name \(name)")
                        returnedUser.name = name
                        group.leave()
                    }
                    group.leave()
                }
                
            }
            group.notify(queue: .main){
                completion(returnedUser)
            }
            */
            ref.child("users").observeSingleEvent(of: .value, with: { snapshot in
                print("this username has \(snapshot.childrenCount) fields")
                let enumerator = snapshot.children
                while let child = enumerator.nextObject() as? DataSnapshot {
                    let value = child.value as? NSDictionary
                    
                    if let email = value?["email"] as? String {
                        
                        guard let name = value?["name"] as? String, let id = value?["uid"] as? String, let username = value?["username"] as? String, let region = value?["region"] as? String else{
                            return
                        }
                        let user = User(userName: username, name: name, email: email, userID: id, games: nil, region:Region.stringToCase(string: region))
                        
                    }
                    
                }
                
            })
            
        }
            
        //no user is logged in
        else{
            /*
            completion( User(userName: "", name: "", email: "", userID: "", games: nil,region:.NA))
            */
        }
        
    }
    
    
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
    static func getCurrentUser() ->User? {
        
        //default user object that is returned
        var returnedUser:User = User(userName: "", name: "", email: "", userID: "", games: nil, region:.NA)
        
        //make sure that there is a user logged in
        let user = Auth.auth().currentUser
        
        //user is signed in
        if ((user) != nil){
            var userName:String
            var email:String
            var uid:String
            var name:String
            var games:[Game]?
            
            
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
            
            
            returnedUser = User(userName: userName, name: name, email: email, userID: uid, games: nil,region:.NA)
            
            
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
                      "uid":user.userID,
                      "region":user.region.rawValue]
       let child = ["/users/\(user.userName)":newUser]
       ref.updateChildValues(child)
    }
    
    
    //return game title for given game id
    static func getGameTitleById(id:String, completion: @escaping(String)->Void){
        
        
        ref.child("Games").observeSingleEvent(of: .value, with: { snapshot in
            
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                
                
                let childSnapshot = snapshot.childSnapshot(forPath: rest.key)
                let value = rest.value as? NSDictionary
                let gameId = value?["id"] as? String?
                
                if gameId! == id {
                    print("found key")
                    completion(rest.key)
                    break
                }
            }
    
        })
        
    }
    
    static func getUsername(email:String, completion: @escaping (String)->Void){
        
        ref.child("users").observeSingleEvent(of: .value, with: { snapshot in
            print("this username has \(snapshot.childrenCount) fields")
            let enumerator = snapshot.children
            while let child = enumerator.nextObject() as? DataSnapshot {
                let value = child.value as? NSDictionary
                let childEmail = value?["email"] as? String?
                print("child email = \(childEmail)")
                if childEmail! == email {
                    print("found username")
                    completion(child.key)
                }
                
            }
            
        })
        
    }
    
    static func getGameIconURLById(id: String) -> String{
        
        switch id {
        case "0001" :
            return "overwatchlogo.png"
        case "0002":
            return "csgologo.jpg"
        case "0003":
            return "dota2logo.png"
        default:
            return ""
        }
        
    }
    
    //takes in game id and returns a UIImage of that games icon
    static func downloadGameIcon(id: String, completion: @escaping (UIImage) -> Void){
        //reference to storage on Firebase databse
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let imgName = getGameIconURLById(id:id)
        let imgRef = storageRef.child("gameIcons/\(imgName)")
        imgRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            
            if let error = error {
                print("error getting game icon")
                print(error)
            }
            else{
                let gameIcon = UIImage(data: data!)
                completion(gameIcon!)
            }
            
        }
        
    }
    
    
    /*
     Given a user's username as a string returns array of game
     objects filled with the users saved game data
    */
    static func getUserGames(username:String, completion: @escaping ([Game])->Void){
        
        //group to wait for every request to be finished
        //before returning values
        let group = DispatchGroup()
       
        ref.child("users").child(username).child("games").observeSingleEvent(of: .value, with: { snapshot in
            
            //check if valid index
            if snapshot.exists(){
                
                //hold games
                var games:[Game] = []
                
                //iterate over every one of users games
                let enumerator = snapshot.children
                while let child = enumerator.nextObject() as? DataSnapshot {
                    group.enter()
                    //find id of game stored in this index
                    let value = child.value as? NSDictionary
                    let childId = value?["id"] as? String?
                    let platform = value?["platform"] as? String
                    let childPlatform = Platform(rawValue: platform!)
                    
                    print("searching for id \(childId)")
                    //now that we have the id get the game info
                    //from the game tab
                    
                    getGameTitleById(id: childId as! String) { result in
                        print("found result \(result)")
                        
                        downloadGameIcon(id: childId as! String) { icon in
                            
                        
                            //add result to list
                            games.append(Game(title: result, id:childId!!, icon:icon,platform:childPlatform!))
                            group.leave()
                            
                        }
                    
                    }
                    
                }
                //return when every game is searched for
                group.notify(queue: .main){
                    completion(games)
                }
                
                
            }
                //invalid index
            else {
                print("getUserGames snapshot doesnt exist")
            }
        })
        
        
    }
    
    //returns users Name given thier username
    static func getNameByUsername(username: String, completion: @escaping (String)->Void){
        
        ref.child("users").child(username).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
                print("in getName found username")
                
                let value = snapshot.value as? NSDictionary
                if let value = value {
                    if let name = value["name"] as? String {
                        completion(name)
                    }
                }
            }else{
                print("username not found in getName")
                completion("")
            }
            
            })
    
    
    }
    
    
    
    
    
    
}
