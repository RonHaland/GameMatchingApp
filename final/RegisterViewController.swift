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

/*TODO 
 1. put a games section when appending user to users list
 2. put an error field for the name section and region section
*/
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FirebaseAuth

class RegisterViewController: UIViewController,UIScrollViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //outlets
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var regionPicker: UIPickerView!
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
    
    let regions = ["Select Region", "N. America","S. America","Europe","Asia"]
    
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
        
        //set up region Picker view
        regionPicker.delegate = self
        pickerTextField.isEnabled = false
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.pickerTextField.isUserInteractionEnabled = false
        
        //make errors hidden
        self.usernameError.isHidden = true
        self.emailError.isHidden = true
        self.passwordError.isHidden = true
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //setup scrollview content size
        self.scrollView.frame = self.view.frame
        self.scrollView.contentSize = CGSize(width: 375, height:900)
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
        
        //check if caller is the username field
        if textField.tag == 1 {
            //check if he username is ttaken
            guard let username = usernameField.text else {
                return
            }
            
            if username.isEmpty || username == "" {
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
        
        
        //get size of keyboard
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        //adjust scrollview insets
        var contentInsets = scrollView.contentInset
        contentInsets.bottom  = contentInsets.bottom - keyboardSize.height
        scrollView.contentInset = contentInsets
        
        //scroll scrollview up to top
        //scrollView.contentOffset.y = 0
        
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
        if (self.nameField.text?.isEmpty)! || self.nameField.text == "" {
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
        
        //checking region field
        if (self.pickerTextField.text?.isEmpty)! || self.pickerTextField.text == "Select Region"{
            print("Must select a region")
            valid = false
        }
        
        return valid
        
    }
    
    //disable horizontal scrolling on scroll view
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 0 || scrollView.contentOffset.x < 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    
    
    @IBAction func submitButtonPressed(sender:UIButton){
        print("pressed submit button")
        //check that the form is valid
        if formIsValid(){
            print("form valid")
            //make sure form values are valid. If not then return
            /*guard le_me = usernameField.text, let email = emailField.text,let name = nameField.text, let password = passwordField.text else {
                return
            }*/
            
            
            //create new user in database
            Auth.auth().createUser(withEmail: self.emailField.text!, password: self.passwordField.text!) { (user, error) in
                
                //creation failed
                if error != nil {
                    //print("failed to register user \(error)")
                    return
                }
                //craetion success
                else{
                    
                    //sign in user
                    Auth.auth().signIn(withEmail: self.emailField.text!, password:self.passwordField.text!) { (signinUser, signinError) in
                        
                        //sign in failed
                        if signinError != nil{
                            print("sign in failed")
                        }
                        //sign in success
                        else{
                            let newUser = User(userName: self.usernameField.text!, name: self.nameField.text!, email: self.emailField.text!, userID: (signinUser?.uid)!, games: nil, region: Region.stringToCase(string: (self.pickerTextField?.text)!))
                            DatabaseHelper.appendToUsers(user: newUser)
                            DatabaseHelper.appendToTakenUsernames(username: newUser.userName)
                            
                            self.showToast(message: "Registration Successful", segueIdentifier: "ShowLoginVCSegue")
                        }
                        
                    }
                }
                
            }
            
            
        
        }
        //form invalid just return
        else{
            print("form invalid")
            return
        }
    }
    
    //sets number of column in pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //sets number of rows in picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return regions.count
    }
    
    //sets text for row of pickerView that is selected
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return regions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if regions[row] == "Select Region"{
            return
        }
        else{
            pickerTextField.text = regions[row]
        }
    }
    
    
    
}
//extension to close keyboard when user click on background
extension UIViewController {
    
    
    func hideKeyboardWhenTappedAround(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    //extension to show toast
    func showToast(message:String, segueIdentifier:String?){
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width / 2  - 85, y: self.view.frame.size.height - 100, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light",size:12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration:3.0,delay:0.1,options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        },completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
            
            if let segueIdentifier = segueIdentifier {
                self.performSegue(withIdentifier:segueIdentifier, sender: self)
            }
        })
        
    }
    
}

