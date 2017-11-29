//
//  EditGameViewController.swift
//  final
//
//  Created by Benjamin Dagg on 11/15/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FirebaseAuth
import FontAwesomeKit

class EditGameViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var roleContainer: UIView!
    @IBOutlet weak var roleField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContainer: UIView!
    @IBOutlet weak var gameImg: UIImageView!
    @IBOutlet weak var platformFieldContainer: UIView!
    @IBOutlet weak var platformField: UITextField!
    @IBOutlet weak var platformPicker: UIPickerView!
    @IBOutlet weak var levelField: UITextField!
    @IBOutlet weak var rolePicker: UIPickerView!
    @IBOutlet weak var roleFieldContainer: UIView!
    @IBOutlet weak var rankContainer: UIView!
    @IBOutlet weak var rankField: UITextField!
    @IBOutlet weak var levelContainer: UIView!
    @IBOutlet weak var platformContainer: UIView!
    
    var game:Game?
    var user:User?
    var gameInfo = Dictionary<String,Any>()
    var editMode:Bool = false
    var roles:[String] = ["DPS", "Support", "Tank", "Offtank", "Carry", "Jungle", "ADC"]
    var platforms:[String] = []
    var isFavorite:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: 375, height: 1400)
        
        
        self.platformField.inputView = UIView()
        self.platformField.addTarget(self, action: #selector(platformFieldClicked), for: .touchUpInside)
        self.roleField.inputView = UIView()
        self.roleField.addTarget(self, action: #selector(roleFieldClicked), for: .touchUpInside)
        
        //notifications for when keyboard pops up
        //keyboard notificaions
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        hideKeyboardWhenTappedAround()
        
        //navigation buttons
        //edit button
        let editBtn = UIBarButtonItem(title: "Edit", style: .done, target: self, action:#selector(enableEditing))
        //star button
        let star = FAKFontAwesome.starOIcon(withSize: 30.0) as FAKFontAwesome
        star.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
        let favBtn = UIButton(type: UIButtonType.system) as UIButton
        favBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        favBtn.setImage(star.image(with: CGSize(width: 30, height: 30)), for: .normal)
        favBtn.addTarget(self, action: #selector(favorite), for: .touchUpInside)
        let favBarBtn = UIBarButtonItem(customView: favBtn)
        
        self.navigationItem.rightBarButtonItems = [editBtn,favBarBtn]
        
        //set up pickers
        self.platformPicker.delegate = self
        self.platformPicker.dataSource = self
        self.rolePicker.delegate = self
        self.rolePicker.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //hide the pickers
        self.platformContainer.isHidden = true
        self.roleContainer.isHidden = true
        
        //set game info on the text fields
        if let game = game {
            self.gameImg.image = game.icon
            getGameInfo()
            getPlatforms()
            getFav()
            
        }
        
        //makes text fields un editable if not in edit mode
        self.platformField.isUserInteractionEnabled = false
        self.roleField.isUserInteractionEnabled = false
        self.rankField.isUserInteractionEnabled = false
        self.levelField.isUserInteractionEnabled = false
        
    }
    
    
    //shows/hides platform pickeeer when clicked
    func platformFieldClicked(sender: UITextField) {
        print("clicked")
        
        if editMode == false{
            return
        }
        
        //if picker is hidden then show it
        if platformPicker.isHidden == true{
            self.platformPicker.reloadAllComponents()
            scrollView.isScrollEnabled = false
            UIView.animate(withDuration: 0.25, animations: {
                
                self.platformPicker.isHidden = false
            })
        }
            //if picker is open then hide it
        else{
            
            print("clicked")
            scrollView.isScrollEnabled = true
            //animate picker hiding
            UIView.animate(withDuration: 0.25, animations: {
                self.platformPicker.isHidden = true
                
            })
        }
    }
    
    // show/hide role field when clicked
    func roleFieldClicked(sender: UITextField) {
        print("clicked")
        
        if editMode == false {
            return
        }
        
        //if picker is hidden then show it
        if rolePicker.isHidden == true {
            self.rolePicker.reloadAllComponents()
            scrollView.isScrollEnabled = false
            UIView.animate(withDuration: 0.25, animations: {
                
                self.rolePicker.isHidden = false
            })
        }
            //if picker is open then hide it
        else{
            
            print("clicked")
            scrollView.isScrollEnabled = true
            //animate picker hiding
            UIView.animate(withDuration: 0.25, animations: {
                self.rolePicker.isHidden = true
                
            })
        }
        
    }
    
    
    //checks if all fields on the VC are filled before adding the
    //game to the users profile and segue
    func formIsValid() -> Bool {
        var valid = true
        
        if self.platformField.text?.isEmpty == true || self.platformField.text == "Choose One"{
            valid = false
        }
        if self.rankContainer.isHidden == false && self.rankField.text?.isEmpty == true {
            valid = false
        }
        if self.levelContainer.isHidden == false && self.levelField.text?.isEmpty == true {
            valid = false
        }
        if (self.roleContainer.isHidden == false && self.roleField.text?.isEmpty == true) || (self.roleField.text == "Choose One" && self.roleField.isHidden == false){
            valid = false
        }
        
        return valid
        
    }

    
    
    func saveChanges(){
        
        if formIsValid() {
            let ref = Database.database().reference()
            if let user = self.user {
                if let game = self.game {
                    let key = ref.child("users").child(user.userName).child("games").child(game.title)
                    let id = self.gameInfo["id"] as? String
                    if let id = id {
                    var newGame = ["id":id, "platform":self.platformField.text] as [String : Any]
                    //check if the optional fields are not nil if they arent then add them to the dict
                    if let rank = self.rankField.text {
                        if rank.isEmpty == false && self.rankField.isHidden == false{
                            newGame["rank"] = rank
                        }
                    }
                    if let level = self.levelField.text {
                        if level.isEmpty == false && self.levelField.isHidden == false{
                            newGame["level"] = level
                        }
                    }
                    if let role = self.roleField.text{
                        if role != "Select One" && self.roleField.isHidden == false{
                            newGame["role"] = role
                        }
                    }
                        let updates = ["users/\(user.userName)/games/\(game.title)":newGame]
                        ref.updateChildValues(updates)
                        
                        self.showToast(message: "Changes Saved", segueIdentifier : nil)
                    }

                }
            }
            
        }else{
            let alert = UIAlertController(title: "Error", message: "One or more fields misssing", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated:true,completion:nil)
        }

    }

    
    
    /*
    called when done bar button item clicked. Enables editing mode and makes the textfields visible and editable
    */
    func enableEditing(sender: UIBarButtonItem){
        
        //not in edit mode so enable edit mode
        if self.editMode == false {
            
            //update bar button item
            self.navigationItem.rightBarButtonItems?.removeAll()
            let editBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action:#selector(enableEditing))
            //star button
            let star = FAKFontAwesome.starOIcon(withSize: 30.0) as FAKFontAwesome
            star.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
            let favBtn = UIButton(type: UIButtonType.system) as UIButton
            favBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            favBtn.setImage(star.image(with: CGSize(width: 30, height: 30)), for: .normal)
            favBtn.addTarget(self, action: #selector(favorite), for: .touchUpInside)
            let favBarBtn = UIBarButtonItem(customView: favBtn)
            if self.isFavorite {
                favBtn.tintColor = UIColor.yellow
            }else{
                favBtn.tintColor = UIColor.white
            }
            self.navigationItem.rightBarButtonItems = [editBtn,favBarBtn]
            
            //enable edit mode
            self.editMode = true
            
            //unhide hidden views
            self.platformContainer.isHidden = false
            if self.roleFieldContainer.isHidden == false {
                self.roleContainer.isHidden = false
            }
            
        
            self.rankField.isUserInteractionEnabled = editMode
            self.levelField.isUserInteractionEnabled = editMode
            
            self.editButtonItem.title = "Done"
        }
        //already is edit mode and user just clicked done
        else {
            
            //update bar button item
            //update bar button item
            self.navigationItem.rightBarButtonItems?.removeAll()
            let editBtn = UIBarButtonItem(title: "Edit", style: .done, target: self, action:#selector(enableEditing))
            //star button
            let star = FAKFontAwesome.starOIcon(withSize: 30.0) as FAKFontAwesome
            star.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
            let favBtn = UIButton(type: UIButtonType.system) as UIButton
            favBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            favBtn.setImage(star.image(with: CGSize(width: 30, height: 30)), for: .normal)
            favBtn.addTarget(self, action: #selector(favorite), for: .touchUpInside)
            let favBarBtn = UIBarButtonItem(customView: favBtn)
            if self.isFavorite {
                favBtn.tintColor = UIColor.yellow
            }else{
                favBtn.tintColor = UIColor.white
            }
            self.navigationItem.rightBarButtonItems = [editBtn,favBarBtn]
            
            self.editMode = false
            
            //hide views
            UIView.animate(withDuration: 0.25, animations: {
                self.platformContainer.isHidden = true
                if self.roleFieldContainer.isHidden == false {
                    self.roleContainer.isHidden = true
                }
            })
            
            saveChanges()
            
            self.rankField.isUserInteractionEnabled = editMode
            self.levelField.isUserInteractionEnabled = editMode
            
            
        }
    }
    
    
    func getFav() {
        let ref = Database.database().reference()
        
        if let user = self.user {
            ref.child("users").child(user.userName).observe(.value, with: {snapshot in
                    if snapshot.exists() {
                        
                        let value = snapshot.value as? NSDictionary
                        if let value = value {
                            if let favGame = value["favGame"] as? String {
                                if let game = self.game {
                                    if game.title == favGame {
                                        self.isFavorite = true
                                        if self.isFavorite {
                                            self.navigationItem.rightBarButtonItems?.removeAll()
                                            var editBtn: UIBarButtonItem
                                            if self.isEditing == false{
                                                editBtn = UIBarButtonItem(title: "Edit", style: .done, target: self, action:#selector(self.enableEditing))
                                            }
                                            else{
                                                editBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action:#selector(self.enableEditing))
                                            }
                                            
                                            //star button
                                            let star = FAKFontAwesome.starOIcon(withSize: 30.0) as FAKFontAwesome
                                            star.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
                                            let favBtn = UIButton(type: UIButtonType.system) as UIButton
                                            favBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                                            favBtn.setImage(star.image(with: CGSize(width: 30, height: 30)), for: .normal)
                                            favBtn.addTarget(self, action: #selector(self.favorite), for: .touchUpInside)
                                            let favBarBtn = UIBarButtonItem(customView: favBtn)
                                            favBtn.tintColor = UIColor.yellow
                                            self.navigationItem.rightBarButtonItems = [editBtn,favBarBtn]
                                        }
                                    }
                                }
                            }else{
                                self.isFavorite = false
                                if self.isFavorite {
                                    self.navigationItem.rightBarButtonItems?.removeAll()
                                    var editBtn: UIBarButtonItem
                                    if self.isEditing == false{
                                        editBtn = UIBarButtonItem(title: "Edit", style: .done, target: self, action:#selector(self.enableEditing))
                                    }
                                    else{
                                        editBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action:#selector(self.enableEditing))
                                    }
                                    
                                    //star button
                                    let star = FAKFontAwesome.starOIcon(withSize: 30.0) as FAKFontAwesome
                                    star.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
                                    let favBtn = UIButton(type: UIButtonType.system) as UIButton
                                    favBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                                    favBtn.setImage(star.image(with: CGSize(width: 30, height: 30)), for: .normal)
                                    favBtn.addTarget(self, action: #selector(self.favorite), for: .touchUpInside)
                                    let favBarBtn = UIBarButtonItem(customView: favBtn)
                                    favBtn.tintColor = UIColor.white
                                    self.navigationItem.rightBarButtonItems = [editBtn,favBarBtn]
                                }
                            }
                        }
                    
                    }
                })
        }
    }
    
    
    
    func favorite(){
        //is this game is the favorite then remove it
        if self.isFavorite {
            let alert = UIAlertController(title: "Confirm", message: "Remove this game as your favorite?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {(alert: UIAlertAction!) in
                let ref = Database.database().reference()
                if let user = self.user {
                    if let game = self.game {
                        ref.child("users").child(user.userName).child("favGame").setValue(nil)
                    }
                }
            
                self.isFavorite = false
                self.navigationItem.rightBarButtonItems?.removeAll()
                var editBtn: UIBarButtonItem
                if self.isEditing == false{
                    editBtn = UIBarButtonItem(title: "Edit", style: .done, target: self, action:#selector(self.enableEditing))
                }
                else{
                    editBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action:#selector(self.enableEditing))
                }
                
                //star button
                let star = FAKFontAwesome.starOIcon(withSize: 30.0) as FAKFontAwesome
                star.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
                let favBtn = UIButton(type: UIButtonType.system) as UIButton
                favBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                favBtn.setImage(star.image(with: CGSize(width: 30, height: 30)), for: .normal)
                favBtn.addTarget(self, action: #selector(self.favorite), for: .touchUpInside)
                let favBarBtn = UIBarButtonItem(customView: favBtn)
                favBtn.tintColor = UIColor.white
                self.navigationItem.rightBarButtonItems = [editBtn,favBarBtn]
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated:true,completion:nil)
        }else{
            let ref = Database.database().reference()
            if let user = self.user {
                if let game = self.game {
                    ref.child("users").child(user.userName).child("favGame").setValue(game.title)
                }
                self.isFavorite = true
                self.navigationItem.rightBarButtonItems?.removeAll()
                var editBtn: UIBarButtonItem
                if isEditing == false{
                    editBtn = UIBarButtonItem(title: "Edit", style: .done, target: self, action:#selector(enableEditing))
                }
                else{
                    editBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action:#selector(enableEditing))
                }
                
                //star button
                let star = FAKFontAwesome.starOIcon(withSize: 30.0) as FAKFontAwesome
                star.addAttribute(NSForegroundColorAttributeName, value: UIColor.white)
                let favBtn = UIButton(type: UIButtonType.system) as UIButton
                favBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                favBtn.setImage(star.image(with: CGSize(width: 30, height: 30)), for: .normal)
                favBtn.addTarget(self, action: #selector(favorite), for: .touchUpInside)
                let favBarBtn = UIBarButtonItem(customView: favBtn)
                favBtn.tintColor = UIColor.yellow
                self.navigationItem.rightBarButtonItems = [editBtn,favBarBtn]
            }
        }
    }
    
    
    /*
    Gets the users game info for the selected game from the
    database and puts it in a dictionary. Then puts the game info into the text fields and hides the unsused fields
    */
    func getGameInfo(){
        let ref = Database.database().reference()
        
        //check if valid user and game
        if let user = self.user{
            if let game = self.game{
                
            ref.child("users").child(user.userName).child("games").child(game.title).observeSingleEvent(of: .value, with: {snapshot in
                    
                    if snapshot.exists(){
                        let value = snapshot.value as? NSDictionary
                        if let value = value {
                            self.gameInfo = value as! Dictionary<String, Any>
                        }
                        DispatchQueue.main.async {
                            if let level = self.gameInfo["level"] as? String {
                                self.levelField.text = level
                            }else{
                                self.levelContainer.isHidden = true
                            }
                            if let platform = self.gameInfo["platform"] as? String {
                                self.platformField.text = platform
                            }
                            
                            if let rank = self.gameInfo["rank"] as? String {
                                self.rankField.text = rank
                            }else{
                                self.rankContainer.isHidden = true
                            }
                            if let role = self.gameInfo["role"] as? String {
                                self.roleField.text = role
                            }else{
                                self.roleFieldContainer.isHidden = true
                                self.roleContainer.isHidden = true
                            }
                            
                            
                        }
                        
                    }
                    
                    })
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
        scrollView.isScrollEnabled =  true
        
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
    
    
    //disables user from editing textfield text when edit mode is off and enables if when edit mode is one
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //if not in edit mode then dont change text
        if self.editMode == false{
            return false
        }else{
            return true
        }
    }
    
    func getPlatforms() {
        let database = Database.database()
        let ref = database.reference()
        
        if let game = self.game {
            
            ref.child("Games").child(game.title).child("platforms").observeSingleEvent(of: .value, with: { snapshot in
                
                //snapshot success
                if snapshot.exists(){
                    
                    let enumerator = snapshot.children
                    while let child = enumerator.nextObject() as? DataSnapshot {
                        self.platforms.append(child.key)
                    }
                    DispatchQueue.main.async {
                        self.platformPicker.reloadAllComponents()
                    }
                }
            })
        }
    }
    
    
    //==================== Picker Methods ==================
    //sets number of column in pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //sets number of rows in picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == self.platformPicker {
            return self.platforms.count
        }else{
            return self.roles.count
        }
        
    }
    
    //sets text for row of pickerView that is selected
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == self.platformPicker {
            return self.platforms[row]
        }else{
            return self.roles[row]
        }
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == self.platformPicker {
            self.platformField.text = self.platforms[row]
        }else{
            self.roleField.text = self.roles[row]
        }
    }
    

    
    
    
}
