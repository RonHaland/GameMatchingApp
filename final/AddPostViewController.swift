//
//  AddPostViewController.swift
//  final
//
//  Created by Benjamin Dagg on 12/2/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FirebaseAuth

class AddPostViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContainer: UIView!
    @IBOutlet weak var gameImg: UIImageView!
    @IBOutlet weak var gamePicker: UIPickerView!
    @IBOutlet weak var gameField: UITextField!
    @IBOutlet weak var gamertagField: UITextField!
    @IBOutlet weak var messageField: UITextView!
    
    
    var user:User?
    var games:[String] = []
    var gameInfo = Dictionary<String,Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        
        //adds submit button to right of nav bar
        let submitBtn = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submitNewPostIfValid))
        self.navigationItem.rightBarButtonItem = submitBtn
        
        //close keyboard when user clicks on background
        hideKeyboardWhenTappedAround()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //setup game picker view
        self.gamePicker.delegate = self
        self.gamePicker.dataSource = self
        
        //hide game img
        self.gameImg.isHidden = true
        
        //disable user touch on game field
        self.gameField.isUserInteractionEnabled = false
        
        getUserGameInfo()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        //setup scrollview content size
        self.scrollView.frame = self.view.frame
        self.scrollView.contentSize = CGSize(width: 375, height:800)
    }
    
    
    //gets user info from database and returns it in a dictionary
    func getUserGameInfo() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let ref = Database.database().reference()
            
            if let user = self.user {
                ref.child("users").child(user.userName).child("games").observeSingleEvent(of: .value, with: { snapshot in
                    
                    if snapshot.exists() {
                        
                        if let value = snapshot.value as? NSDictionary {
                            self.gameInfo = value as! Dictionary<String, Any> 
                        }
                        
                        //add games to game picker
                        DispatchQueue.main.async {
                            self.games.removeAll()
                            
                            for (key, _) in self.gameInfo {
                                print("key = \(key)")
                                self.games.append(key )
                            }
                            if self.games.count <= 1 {
                                self.games.append("")
                                self.games.append("")
                            }
                            self.gamePicker.reloadAllComponents()
                        }
                        
                        
                    }else {
                        print("user has no games")
                        DispatchQueue.main.async {
                            self.games.removeAll()
                            self.games.append("You have no games")
                            self.games.append("")
                            self.games.append("")
                            self.gamePicker.reloadAllComponents()
                        }
                    }
                    
                })
            }
        }
        
    }
    
    
    //sets number of column in pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    //sets number of rows in picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return games.count
        
    }
    
    
    
    //sets text for row of pickerView that is selected
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return games[row]
        
    }
    
    
    
    //disable horizontal scrolling on scroll view
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 0 || scrollView.contentOffset.x < 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    
    
    /*
    When an item is selected in the picker, download that games icon and set the game field to the title of the selected game
    */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if self.games[row] != "You have no games" && self.games[row] != "" {
            //set text on games field
            self.gameField.text = games[row]
            
            //get the game icon from the database
            let title = self.games[row]
            let ref = Database.database().reference()
            //get game id from database to find its image
            ref.child("Games").child(title).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    if let value = snapshot.value as? NSDictionary {
                        if let id = value["id"] as? String {
                            DatabaseHelper.downloadGameIcon(id: id, completion: { icon in
                                self.gameImg.image = icon
                                if self.gameImg.isHidden {
                                    self.gameImg.isHidden = false
                                }
                            })
                        }
                    }
                }
                
                })
            
        }
        
        
    }
    
    
    
    //checks if all fields in the view controller are correctly filled out before submitting the post
    func formIsValid() -> Bool {
        var valid:Bool = true
        
        if (self.gameField.text?.isEmpty)! || self.gameField.text == "Game" || self.gameField.text == "" {
            valid = false
        }
        if (self.gamertagField.text?.isEmpty)! {
            valid = false
        }
        
        return valid
    }
    
    
    
    /*
    Checks if form is valid. If not displays an alert and does nothing. If valid, create a new post, append it to the post table view, then segue to post view controller
    */
    func submitNewPostIfValid() {
        
        //post valid, submit new post and segue
        if formIsValid() == true {
            
            if let user = self.user {
                //construct new post object to add
                let gameTitle = self.gameField.text
                let gamertag = self.gamertagField.text
                var message:String?
                if self.messageField.text.isEmpty || self.messageField.text == "(optional)" {
                    message = nil
                }else {message = self.messageField.text }
                //let gameImg = self.gameImg.image
                let region = user.region.rawValue
                
                if let gameTitle = gameTitle {
                    if let gameInfo = self.gameInfo[gameTitle] as? Dictionary<String,Any> {
                        if let platform = gameInfo["platform"] as? String {
                            let time = NSDate()
                             //let newPost = Post(gameTitle: gameTitle, gameImg: gameImg!, platform: Platform.stringToCase(string: platform), gamertag: gamertag!, postDate: time as Date, region: user.region, message: message)
                            if let gt = gamertag {
                                let postDB = ["game":gameTitle,
                                              "gamertag":gt,
                                              "platform":platform,
                                              "postdate":time.timeIntervalSince1970,
                                              "region":region,
                                              "message":message ?? "none",
                                              "user":user.userName,
                                              "properties":gameInfo] as [String : Any]
                                let ref = Database.database().reference()
                                let child = ["/Posts/\(time)/": postDB]
                                ref.updateChildValues(child)
                                
                                //show user toast confirming the post was added
                                self.showToast(message: "Post Added Successfully", segueIdentifier: "unwindToPosts")
                            }
                            
                        }
                    }
                }
            }
            
        }
        //form invalid, display alrt
        else {
            let alert = UIAlertController(title: "Error", message: "One or more fields misssing", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated:true,completion:nil)
        }
        
    }

    
}
