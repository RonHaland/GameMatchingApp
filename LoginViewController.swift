//
//  LoginViewController.swift
//  final
//
//  Created by Benjamin Dagg on 10/4/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //reset all fields
        usernameField.text = ""
        passwordField.text = ""
        usernameError.isHidden = true
        passwordError.isHidden = true
        
        
        
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
     Called when the login button is presed.Checks if form is valid and that the user exists then logs them in
    */
    @IBAction func loginButtonPressed(sender:UIButton){
        //Auth.auth().createUser(withEmail: usernameField.text!, password: passwordField.text!)
        //check if fieds are blank
        if formIsValid() == true {
            //if errors are displayed then disable them
            usernameError.isHidden = true
            passwordError.isHidden = true
            
            //try to log user in
            Auth.auth().signIn(withEmail: usernameField.text!, password: passwordField.text!, completion: { (user, error) in
                
                    //login failed
                    if error != nil {
                        print("incorrect login")
                    }
                    //login success
                    else{
                        /*
                        let username = Auth.auth().currentUser?.email
                        let password = Auth.auth().currentUser?.uid
                        print(username)
                        */
                    }
                })
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
        if segue.identifier == "ShowRegiterVCSegue" {
            if let destinationVC = segue.destination as? RegisterViewController {
                
            }
        }
        
    }
}
