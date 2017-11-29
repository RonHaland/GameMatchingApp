//
//  EditProfileViewController.swift
//  final
//
//  Created by Benjamin Dagg on 11/19/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FirebaseAuth

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UIScrollViewDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var favGamePicker: UIPickerView!
    @IBOutlet weak var favGameField: UITextField!
    @IBOutlet weak var chooseImgBtn: UIButton!
    @IBOutlet weak var regionField: UITextField!
    @IBOutlet weak var regionPicker: UIPickerView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContainer: UIView!
    
    //passes in user
    var user:User?
    //dictionary of user info from the database
    var userInfo = Dictionary<String,Any>()
    var imagePicker = UIImagePickerController()
    //array of regions for region picker
    let regions = ["Select Region", "N. America","S. America","Europe","Asia"]
    //holds names of all of the users games for game picker
    var userGames:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        //dont know what this does but makes it look better
        self.imagePicker.modalPresentationStyle = .overCurrentContext
        
        //setup pickers
        self.regionPicker.delegate = self
        self.regionPicker.dataSource = self
        self.favGamePicker.delegate = self
        self.favGamePicker.dataSource = self
        
        chooseImgBtn.addTarget(self, action: #selector(chooseImgButtonPressed), for: .touchUpInside)
        
        //add done button on nav controller
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action:#selector(saveInfoAndSegueToProfile))
        self.navigationItem.rightBarButtonItem = doneBtn
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //retrieve user info
        getUserInfo()
        getUserProfileImgifExists()
        
        //make text fields un-editable
        self.favGameField.isUserInteractionEnabled = false
        self.regionField.isUserInteractionEnabled = false
    }
    
    
    /*
    Makes sure info entered by user is valid before entering it into the database. Returns true if valid and false otherwise
    */
    func formIsValid() -> Bool {
        
        //region only required field so return if it is valid
        if (regionField.text?.isEmpty)! || regionField.text == "Select One" {
            return false
        }else{
            return true
        }
        
    }
    
    
    /*
    When user done entering info press done button. Saves info to database then segues back to profile VC
    */
    func saveInfoAndSegueToProfile(sender: UIBarButtonItem) {
        
        //if form invalid display an alert telling user to fill out missing info
        if formIsValid() == false {
            let alert = UIAlertController(title: "Error", message: "One or more fields misssing", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated:true,completion:nil)
        }
         //form is valid so submit entered info into database
        else {
            let ref = Database.database().reference()
            
            if let user = self.user {
                if let region = self.regionField.text {
                    let regionEnum = Region.stringToCase(string: region)
                    let regionStr = regionEnum.rawValue
                    ref.child("users").child(user.userName).child("region").setValue(regionStr)
                }
                if let favGame = self.favGameField.text {
                    if favGame != "Select One" {
                        ref.child("users").child(user.userName).child("favGame").setValue(favGame)
                    }
                }
            }
            self.showToast(message: "Changes Saved", segueIdentifier : nil)
        }
        
    }
    
    
    func getUserProfileImgifExists() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let user = self.user {
                let ref = Database.database().reference()
                ref.child("users").child(user.userName).observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.hasChild("userPhoto") {
                        let value = snapshot.value as? NSDictionary
                        if let value = value {
                            if let filePath = value["userPhoto"] as? String{
                                storageRef.child(filePath).getData(maxSize: 10 * 1024 * 1024, completion: {(data, error) in
                                    
                                    if let error = error {
                                        print(error.localizedDescription)
                                        return
                                    }else {
                                        let userPhoto = UIImage(data: data!)
                                        
                                        DispatchQueue.main.async {
                                            self.imageView.image = userPhoto
                                        }
                                    }
                                })
                                
                            }
                        }
                    }
                })
            }

        }

    }
    
    
    func chooseImgButtonPressed(sender: UIButton){
        print("choose button pressed")
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            self.present(imagePicker,animated:  true,completion: nil)
        }
    }
    
    
    /*
    Called when view appears. Get user info from database and put it in a dictionary for later use
    */
    func getUserInfo() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let user = self.user {
                let ref = Database.database().reference()
                
                ref.child("users").child(user.userName).observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.exists() {
                        
                        if let value = snapshot.value as? NSDictionary {
                            self.userInfo = value as! Dictionary<String, Any>
                            print(self.userInfo)
                            
                            //get users games and put them in
                            //the userGames array for the fav game picker
                            self.userGames.removeAll()
                            if let games = self.userInfo["games"] as? NSDictionary {
                                for (key, element) in games {
                                    self.userGames.append(key as! String)
                                }
                                DispatchQueue.main.async {
                                    self.favGamePicker.reloadAllComponents()
                                }
                            }
                            
                        }
                    }
                })
            }
        }
    }
    
    //========== Image Picker methods =============
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("inside second'0")
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            imageView.image = editedImage
        
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = originalImage
            var data = NSData()
            data = UIImageJPEGRepresentation(imageView.image!, 0.8) as! NSData
            let filePath = "profileImages/\(user!.userName)/\("imageView")"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            storageRef.child(filePath).putData(data as Data,metadata: metaData) { (metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }else{
                    let downloadURL = metaData!.downloadURL()?.absoluteString
                    if let user = self.user {
                        let ref = Database.database().reference()
                        ref.child("users").child(user.userName).child("userPhoto").setValue(filePath)
                    }
                }
            }
            print("se image")
        }
        else{
            print("error")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    //==============================================
    
    
    //==================== Picker Methods ==================
    //sets number of column in pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //sets number of rows in picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == self.regionPicker {
            return regions.count
        }else{
            return userGames.count
        }
        
    }
    
    //sets text for row of pickerView that is selected
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == self.regionPicker {
            return regions[row]
        }else{
            return userGames[row]
        }
    }
    
    /*
     When user selects an item in the picker view, change the text on that picker views text field
    */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == self.regionPicker {
            self.regionField.text = regions[row]
        }else{
            self.favGameField.text = userGames[row]
        }
    }
    //====================================================
    
}
