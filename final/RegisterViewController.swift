//
//  RegisterViewController.swift
//  final
//
//  Created by Benjamin Dagg on 10/6/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

/*
 Register Screen for user.
 User enters login info then it
 check if it is valid. If valid it logs user in,
 creates new entry in database for user and segues to
 the login screen so they can log in
*/

import UIKit
import Firebase

class RegisterViewController: UIViewController,UIScrollViewDelegate, UITextFieldDelegate {
    
    //outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var usernameField: UITextField! //tag = 1
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField! //tag = 2
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var submitButto:UIButton!
    @IBOutlet weak var usernameError:UILabel!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var passwordError: UILabel! //tag = 3
    
    //used when user enters a username
    //to track if it is a duplicate
    var isDuplicateUserame = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up scrollview
        scrollView.delegate = self
        
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        //notifications for when keyboard pops up
        //keyboard notificaions
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //keyboard extension (see bottom of page)
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //make errors hidden
        self.usernameError.isHidden = true
        self.emailError.isHidden = true
        self.passwordError.isHidden = true
    }
    
    
    /*
     Called when a textfield is clicked on. Used to 
     diable the errors for that field
    */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //dont know if this actually does anything
        scrollView.isScrollEnabled = true
        let viewRect: CGRect = textField.frame
        scrollView.scrollRectToVisible(viewRect, animated: true)
    
    }
    
    
    /*
    Delagate method that triggers when user clicks out of a
     text field. Used by usernameField to check if the entered username is alread taken.
    */
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("did end editing called")
        //check if caller is the username field
        if textField.tag == 1 {
            //check if he username is ttaken
            guard let username = usernameField.text else {
                return
            }
            //call database to check for username
            DatabaseHelper.usernameTaken(username:username, completion: { result in
                //set the global dupe variable to the resultt
                self.isDuplicateUserame = result
                
                //if it was a duplicatet then show error
                if result == true {
                    //change usernameerror on the main queue
                    DispatchQueue.main.async {
                        self.usernameError.isHidden = false
                    }
                }
                //if not duplicate then reset the error
                else {
                    //change usernameerror on the main queue
                    DispatchQueue.main.async {
                        self.usernameError.isHidden = true
                    }
                }
            })
        }
        //email field clicked off
        else if textField.tag == 2 {
            print("clicked off of emial fielf")
            
            let emailPattern = "[a-zA-Z0-9]+\\@[a-zA-Z0-9]+\\.[a-z]{3}"
            let emailStr = emailField.text
            let emailRegex = try! NSRegularExpression(pattern: emailPattern, options: [])
            let emailMatches = emailRegex.matches(in: emailStr!, options: [], range: NSRange(location: 0, length: (emailStr?.characters.count)!))
            //if result array is empty then it didnt pass the regex
            if emailMatches.count == 0 {
                emailError.isHidden = false
            }
            //if passes regex then remove error
            else{
                emailError.isHidden = true
            }

        }
        //password field clicked off
        else if textField.tag == 3 {
            print("password field clicked off")
            if (passwordField.text?.characters.count)! < 8 || (passwordField.text?.characters.count)! > 15 {
                passwordError.isHidden = false
            }
            else{
                passwordError.isHidden = true
            }
            
        }
    }
    
    /*
     This function called when recieve a notification
     that the keyboard has popped up
     */
    func keyboardWillShow(notification: NSNotification){
        print("TRIGGERED")
        
        //enable scrolling of scrollview so screen can move
        scrollView.isScrollEnabled = true
        
        //get size of keyboard
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        //adjust scrollview insets for keyboard
        var contentInsets = scrollView.contentInset
        contentInsets.bottom = keyboardSize.height
        scrollView.contentInset = contentInsets
        
        
    }
    
    
    /*
     this  function called when recieve notificationn that
     keyboard has been dismissed
     */
    func keyboardWillHide(notification:NSNotification){
        print("TRIGGERED")
        
        //disable scrolling
        scrollView.isScrollEnabled =  false
        
        //get size of keyboard
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        //adjust scrollview insets
        var contentInsets = scrollView.contentInset
        contentInsets.bottom  = contentInsets.bottom - keyboardSize.height
        scrollView.contentInset = contentInsets
        
        //scroll scrollview up to top
        scrollView.contentOffset.y = 0
        
    }
    
    /*
     Called when submit button is pressed. Chekc is the form is valid using regular expressions
    */
    func formIsValid() -> Bool {
        
        var valid = true
        
        //testing username
        //starts with a letter and contains no special characters
        let usernamePatter = "^([a-zA-Z])[a-zA-Z0-9]"
        let usernameStr = usernameField.text
        let regex = try! NSRegularExpression(pattern: usernamePatter, options: [])
        let usernameMatches = regex.matches(in: usernameStr!,options:[],range:NSRange(location:0,length:(usernameStr?.characters.count)!))
        //if result array is empty then it didnt pass the regex
        if usernameMatches.count == 0 {
            valid = false
        }
        else if (usernameField.text?.characters.count)! < 5 || (usernameField.text?.characters.count)! > 15 {
            valid = false
        }
        
        
        //testing name field
        //starts with capital letter and has any number of letters afer
        let namePattern = "^[a-z][a-z]+"
        let nameStr = nameField.text
        let nameRegex = try! NSRegularExpression(pattern: namePattern, options: [])
        let nameMatches = nameRegex.matches(in: nameStr!,options:[],range:NSRange(location:0,length:(nameStr?.characters.count)!))
        //if result array is empty then it didnt pass the regex
        if nameMatches.count == 0 {
            valid = false
        }
        
        //testing email field
        //starts witth any number of letters or tnumbers then an @ sign fallowed by any number of letters or numbers and hen a period
        let emailPattern = "[a-zA-Z0-9]+\\@[a-zA-Z0-9]+\\.[a-z]{3}"
        let emailStr = emailField.text
        let emailRegex = try! NSRegularExpression(pattern: emailPattern, options: [])
        let emailMatches = emailRegex.matches(in: emailStr!, options: [], range: NSRange(location: 0, length: (emailStr?.characters.count)!))
        //if result array is empty then it didnt pass the regex
        if emailMatches.count == 0 {
            valid = false
        }
        
        //testing password field
        if (passwordField.text?.characters.count)! < 8 || (passwordField.text?.characters.count)! > 15 {
            valid = false
        }
        
        if isDuplicateUserame == true {
            print("invalid: username is taken")
            valid = false
        }
        
        return valid
        
    }
    
    @IBAction func submitButtonPressed(sender:UIButton){
        
        //check that the form is valid
        if formIsValid(){
            print("in form is valid")
            //make sure form values are valid. If not then return
            guard let username = usernameField.text, let email = emailField.text,let name = nameField.text, let password = passwordField.text else {
                return
            }
            //register user
            Auth.auth().createUser(withEmail: email, password: password)
            print("user registered")
            
            //update the users info in the database
            if Auth.auth().currentUser != nil {
                print("updating user")
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { (error) in
                    print(error as Any)
                }
            }
            
            //get a User object containing the new users info
            let newUser = DatabaseHelper.getCurrentUser()
            
            //make sure the new user object is not nil
            if newUser != nil {
                print("got current user")
                //add the info to the username
                newUser?.name = name
                newUser?.userName = username
                
                
                print("updated user info")
                //add users username to the takenUsernames list
                DatabaseHelper.appendToTakenUsernames(username:username)
                print("added username to taken list")
                
                DatabaseHelper.appendToUsers(user: newUser!)
                
            }
            
            //show toast confirming the registration then
            //segue back to login screen
            self.showToast(message: "Registration Successful", segueIdentifier : "ShowLoginVCSegue")
        
        }
        //form invalid just return
        else{
            return
        }
    }
    
    
}

