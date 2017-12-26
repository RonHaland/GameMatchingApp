//
//  LoginViewController.swift
//  final
//
//  Created by Benjamin Dagg on 10/4/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

/*
 Initial view controller of project.
 Login screen
 User enters login info then it checks if it
 is valid. If valid it attemps to log user in,
 creates a user object filled with the users info that can
 be passed to next view controller, then segues to
 next view controller. 
 Register button segues to RegisterViewController
*/

/* 
 TODO
 1. redo the getUser to just return a dictionary
 2. not sending username correctly to profile
 */


import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FirebaseAuth

 
class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //outlets
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var usernameError: UILabel!
    @IBOutlet var passwordError: UILabel!
    @IBOutlet var loginButton:UIButton!
    @IBOutlet weak var loginFailError: UILabel!
    
     var loginSuccess = false //successfull login?
     var dupe = false
    var passedUser:User = User(userName: "", name: "", email: "", userID: "", games: nil, region:.NA)
    
    //filepath to where the username is stores
    let usernameArchiveURL : URL = {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("username.archive")
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        //try to load username if one exists
        loadUsername()
        //keyboard extension to dismiss keyboard(see bottom of RegisterViewController)
        self.hideKeyboardWhenTappedAround()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //reset all fields
        usernameField.text = ""
        passwordField.text = ""
        usernameError.isHidden = true
        passwordError.isHidden = true
        loginFailError.isHidden = true
        
         self.navigationItem.setHidesBackButton(true, animated: true)
        loadUsername()
        
        let date = NSDate()
        let interval = date.timeIntervalSince1970
        print("date = \(date)")
        print("interval = \(interval)")
    }
    
    
    

    
    /*
     Textfield delegate methode that is called when user
     clicks on textfield. makes the error message for the 
     textfield dissapear when clicked
    */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.placeholder == "Username" {
            usernameError.isHidden = true
        }
        else{
            passwordError.isHidden = true
        }
    }
    
    /*
     Called when login button is pressed. Makes sure that
     username and password field are not blank
    */
    func formIsValid()-> Bool {
        if (usernameField.text?.isEmpty)! {
            return false
        }
        else if (passwordField.text?.isEmpty)! {
            return false
        }
        else{
            return true
        }
    }
    
    
    /*
     Save username in NSUserDefaults
    */
    func saveUsername(username: String) -> Bool{
        print("saving username")
        return NSKeyedArchiver.archiveRootObject(username, toFile: usernameArchiveURL.path)
    }
    
    /*
     Load archived username from directory
    */
    func loadUsername() {
        print("loading username")
        if let username = NSKeyedUnarchiver.unarchiveObject(withFile: usernameArchiveURL.path) as? String {
            self.usernameField.text = username
        }
    }

    
    /*
     Called when the login button is presed.Checks if form is valid and that the user exists then logs them in
    */
    @IBAction func loginButtonPressed(sender:UIButton){
        
        //check if fieds are blank
        if formIsValid() == true {
            //if errors are displayed then disable them
            usernameError.isHidden = true
            passwordError.isHidden = true
            
            //login user
            DatabaseHelper.loginUser(email: self.usernameField.text!, password: self.passwordField.text!) { success  in
                //login successfull
                if success == true{
                    //set login variable to true
                    self.loginSuccess = true
                    
                    //if login fail error is up then disable it
                    self.loginFailError.isHidden = true
                    
                    
                    
                    //try and get user from core data if it exists
                    if let user = CoreDataHelper.getUser(email: self.usernameField.text!) {
                        self.passedUser = user
                        DatabaseHelper.getUserGames(username: user.userName, completion: { result in
                            self.passedUser.games = result
                        })
                        print("got user form core data")
                    }
                    //user not in core data so retrieve from database
                    else{
                        print("getting user form database")
                        let ref = Database.database().reference()
                        ref.child("users").observeSingleEvent(of: .value, with: { snapshot in
                            
                            let enumerator = snapshot.children
                            while let child = enumerator.nextObject() as? DataSnapshot {
                                let value = child.value as? NSDictionary
                                if let value = value {
                                    if let email = value["email"] as? String {
                                        if email == self.usernameField.text {
                                            self.passedUser.email = email
                                            if let username = value["username"] as? String {
                                                self.passedUser.userName = username
                                                
                                                DatabaseHelper.getUserGames(username: username, completion: { result in
                                                    self.passedUser.games = result
                                                })
                                                
                                            }
                                            self.passedUser.email = email
                                            if let uid = value["uid"] as? String {
                                                self.passedUser.userID = uid
                                            }
                                            if let name = value["name"] as? String {
                                                self.passedUser.name = name
                                            }
                                            if let region = value["region"] as? String{
                                                self.passedUser.region = Region.stringToCase(string: region)
                                            }
                                            
                                            
                                        }
                                    }
                                }
                                
                            }
                            
                        })
                    }
                    //save username to directory
                    if self.saveUsername(username: self.passedUser.email){
                        print("saved")
                    }
                    //show toast an segue to ProfileViewController
                    self.showToast(message: "Login Successful", segueIdentifier : "ShowProfileVCSegue")
                    
                    
                    //DatabaseHelper.getUserGames(username: (DatabaseHelper.getCurrentUser()?.userName)!)
                    
                    
                }
                //login fail (incorrect username or password)
                else{
                    //show incorrect login error
                    self.loginFailError.isHidden = false
                }
                    
            }
            
            
            
        }
        //one of the fields are blank
        else{
            
            //check which fields are blank and put up their
            //error message
            if (usernameField.text?.isEmpty)! {
                usernameError.isHidden = false
            }
            if (passwordField.text?.isEmpty)! {
                passwordError.isHidden = false
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //segue from LoginViewController to RegisterViewController
        if segue.identifier == "ShowRegisterVCSegue" {
            if segue.destination is RegisterViewController {
                
            }
        }
        //segue from LoginViewController to ProfileViewController
        else if segue.identifier == "ShowProfileVCSegue" {
            print("in prepare for segue")
            
            //since destination VC is in tab bar we need to
            //index into tab bar to access the ProfileVC
            let barViewController = segue.destination as? UITabBarController
            let nav = barViewController?.viewControllers![0] as! UINavigationController
            let destinationVC = nav.topViewController as? ProfileViewController
            destinationVC?.targetUser = self.passedUser
            
            
        }
        
    }
    
    
    
    //lets profile view controller come backk to login screen to logout
    @IBAction func unwindFromLogout(sender: UIStoryboardSegue) {
        
    }
}
