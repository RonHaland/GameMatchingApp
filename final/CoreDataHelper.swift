//
//  CoreDataHelper.swift
//  final
//
//  Created by Benjamin Dagg on 11/21/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//


/*
This class interacts with core data to easily save users info to core data or get the users info from core data. 
 
 User object = our class for storing users info + games from database
 Users object = core datas entity object
 */

import CoreData
import Foundation
import UIKit

class CoreDataHelper {
    
    
   /*
    Takes in user object to insert its info into core data. If user has no entry in core data then it creates a new entry. If user exists then it updates their info
    */
    static func saveUserToCD(user:User) {
        
        //user exists in core data. update their info then save
        if let fetchedUser = loadUserFromCD(username: user.userName) {
            print("user exists so upadting user info")
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            //update info with passed in info
            print("in saveUser region = \(user.region.rawValue)")
            fetchedUser.setValue(user.region.rawValue, forKey: "region")
            fetchedUser.setValue(user.userName, forKey: "username")
            fetchedUser.setValue(user.name, forKey: "name")
            fetchedUser.setValue(user.email, forKey: "email")
            fetchedUser.setValue(user.userID, forKey: "uid")
            
            //try and save
            do {
                try context.save()
            }catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        //user doesnt exist in core data so add a new entry
        else{
            print("saving new user to core data")
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            //make new user and enter info
            var newUser = NSEntityDescription.insertNewObject(forEntityName: "Users", into: context) as! Users
            newUser.email = user.email
            newUser.name = user.name
            newUser.region = user.region.rawValue
            newUser.uid = user.userID
            newUser.username = user.userName
            
            //try to save
            do {
                try context.save()
            }catch let error as NSError {
                print(error.localizedDescription)
                print("failed to save new user to core data")
            }
        }
    }
    
    
    
    /*
    Loads User profile info from core data if it exists. Returns a 'Users' core data entity to be passed to saveUser
    */
    static func loadUserFromCD(username: String) -> Users? {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //fetch only the entry in core data that has the given username
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        let predicate = NSPredicate(format: "username = %@", username)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = predicate
        
        //tro to fetch from core data (may return nil)
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            //if results are not empty then return result
            if fetchedResults.count != 0 {
                //create new Users entity and return it
                if let fetchedUser:Users  = fetchedResults[0] as? Users {
                    print("core data fetch results = \(fetchedUser.username)")
                    print("core data fetched region = \(fetchedUser.region)")
                    print("returning this suer")
                    return fetchedUser
                }
            }
        }catch let error as NSError {
            print(error.localizedDescription)
            
        }
        //results were empty so return nil
        print("something went wrong in fetching user returning nil")
        return nil
        
    }
    
    
    /*
    Takes in users email and fetches that users info from core data. Returns info in a User object if is found the user in core data or return nil if user not found. Does not include users games in the User object (it is nil) you have to go to the database to get users games. Used on LoginViewController to fetch user from core data before going to the database
    */
    static func getUser(email:String) -> User? {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //limit search to only entries with given email
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        let predicate = NSPredicate(format: "email = %@", email)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = predicate
        
        //try and find user in coredata
        do {
            let fetchedResults = try context.fetch(fetchRequest)
            //fetch results not empty so it found user
            if fetchedResults.count != 0 {
                if let fetchedUser:Users  = fetchedResults[0] as? Users {
                    //put core data info into  User object and return it
                    if let username = fetchedUser.username,let name =  fetchedUser.name, let email = fetchedUser.email, let region = fetchedUser.region, let uid = fetchedUser.uid {
                        return User(userName: username, name: name, email: email, userID: uid, games: nil, region: Region.stringToCase(string: region))
                    }
                }
            }
        }catch let error as NSError {
            print(error.localizedDescription)
            
        }
        //user not found in core data return nil
        print("something went wrong in fetching user returning nil")
        return nil
    }
    
}
