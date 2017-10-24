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

import UIKit
import Firebase
import FirebaseDatabase
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
                    
                    //get current user info in a User object
                    let currentUser = DatabaseHelper.getCurrentUser()
                    //check if the info was loaded correctly
                    if let currentUser = currentUser {
                        print(currentUser.email)
                        print(currentUser.name)
                        print(currentUser.userID)
                        print(currentUser.userName)
                    }
                     //if user came back as nil something
                    //went wrong
                    else{
                        print("error in getting user info")
                    }
                    
                    //save username to directory
                    self.saveUsername(username: (currentUser?.email)!)
                    
                    //SEGUE IS NIL LATER WHEN YOU WANT TO SEGUE
                    //OUT OF LOGINVIEWCONTROLLER TO ANOTHER VC
                    //PUT THE SEGUE IDENTIFIER IN THE SECOND
                    //PARAMETER OF SHOWTOAST()
                    //show toast confirming the registration then
                    //segue back to next view controller
                    self.showToast(message: "Login Successful", segueIdentifier : nil)
                    
                    
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
            if let destinationVC = segue.destination as? RegisterViewController {
                
            }
        }
        
    }
}
