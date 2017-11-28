//
//  AddGameViewController.swift
//  final
//
//  Created by Benjamin Dagg on 11/5/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import UIKit
import Firebase
/* TODO
 1. getGameIcon is putting wrong game icon in the imageview
 2. redo gameProperties dict to include name and get ride of allGames
 3. check form is valid
 4. append game to users profile
 */
class AddGameViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate {
    
    var user:User?
    var usersGames:[Game]? = []
    var allGames:[String] = []
    var gameProperties = Dictionary<String,Any>()
    var platforms:[String] = []
    var roles:[String] = ["DPS", "Support", "Tank", "Offtank", "Carry", "Jungle", "ADC"]
    
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var roleField: UITextField!
    @IBOutlet weak var rolePicker: UIPickerView!
    @IBOutlet weak var roleStackView: UIStackView!
    @IBOutlet weak var roleContainer: UIView!
    @IBOutlet weak var levelField: UITextField!
    @IBOutlet weak var levelContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContainer: UIView!
    @IBOutlet weak var selectedGameImg: UIImageView!
    @IBOutlet weak var gameContainer: UIView!
    @IBOutlet weak var gameStackView: UIStackView!
    @IBOutlet weak var gamePicker: UIPickerView!
    @IBOutlet weak var gameField: UITextField!
    @IBOutlet weak var rankField: UITextField!
    @IBOutlet weak var platformPicker: UIPickerView!
    @IBOutlet weak var platformField: UITextField!
    @IBOutlet weak var platformStackView: UIStackView!
    @IBOutlet weak var platformContainerView: UIView!

    @IBOutlet weak var rankContainer: UIView!
       override func viewDidLoad() {
        super.viewDidLoad()
        
        if let usr = user {
            print("username ======= \(usr.userName)")
        }
        
        self.scrollView.contentSize = CGSize(width:375,height:1400)
        
        //add bar button item to nav bar
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBtnPressed))
        self.navigationItem.rightBarButtonItem = doneBtn
        
        //setting up picker and game field
        self.gameField.delegate = self
        self.gameField.isEnabled = true
        gamePicker.delegate = self
        gamePicker.dataSource = self
        platformPicker.dataSource = self
        platformPicker.delegate = self
        rolePicker.delegate = self
        rolePicker.dataSource = self
        self.gameField.text = "Select One"
      
        //make keyboard not appear when user click on game field
        self.gameField.inputView = UIView()
        //when user clicks on game field show the picker
        self.gameField.addTarget(self, action:#selector(gameFieldClicked), for: .touchDown)
        self.platformField.addTarget(self, action:#selector(platformFieldClicked), for: .touchDown)
        self.roleField.addTarget(self, action:#selector(roleFieldClicked), for: .touchDown)
        self.scrollView.delegate = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        getAllGames()
        gamePicker.reloadAllComponents()
        
        //hide the image view and picker until user clicks select game button
        self.selectedGameImg.isHidden = true
        self.gamePicker.isHidden = true
        self.platformContainerView.isHidden = true
        self.platformPicker.isHidden = true
        self.rankContainer.isHidden = true
        self.levelContainer.isHidden = true
        self.roleContainer.isHidden = true
        self.rolePicker.isHidden = true
        self.selectedGameImg.image = nil
        
    }
    
    func doneBtnPressed(sender: UIBarButtonItem){
        print("done butn pressen")
        print("form is valid? \(formIsValid())")
        if formIsValid() == true{
            
            if let gameName = self.gameField.text {
                //get all info of that game as a dictionary
                let gameInfo = gameProperties[gameName] as? NSDictionary
                //check that info is not nil
                if let info = gameInfo {
                    print(gameInfo)
                    //get id 0f game
                    let gameID = info["id"] as? String
                    if let id = gameID {
                        print("id = \(id)")
                        //make new game dictionary to append to database
                        var newGame = ["id":id, "platform":self.platformField.text] as [String : Any]
                        //check if the optional fields are not nil if they arent then add them to the dict
                        if let rank = self.rankField.text {
                            if rank.isEmpty == false{
                                newGame["rank"] = rank
                            }
                        }
                        if let level = self.levelField.text {
                            if level.isEmpty == false {
                                newGame["level"] = level
                            }
                        }
                        if let role = self.roleField.text {
                            if role != "Choose One" {
                                newGame["role"] = role
                            }
                        }
                        
                        if let usr = self.user{
                        print("user = \(usr.userName)")
                        let ref = Database.database().reference()
                            if let gameTitle = self.gameField.text {
                        let child = ["/users/\(usr.userName)/games/\(gameTitle)": newGame]
                        ref.updateChildValues(child)
                        print("added game")
                        }
                        }
                    }
                }
                
            }

            
            self.performSegue(withIdentifier: "AddGameVCtoProfileVCSegue", sender: self)
        }
    }
    
    //checks if all fields on the VC are filled before adding the
    //game to the users profile and segue
    func formIsValid() -> Bool {
        var valid = true
        if self.gameField.text?.isEmpty == true || self.gameField.text == "Select One"{
            valid = false
        }
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
    

    //sets number of column in pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //sets number of rows in picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (pickerView == self.gamePicker){
            return allGames.count
        }
        else if pickerView == self.rolePicker {
            return self.roles.count
        }
        else{
            return platforms.count
        }
    }
    
    //sets text for row of pickerView that is selected
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.gamePicker {
            return allGames[row]
        }
        else if pickerView == self.rolePicker {
            return roles[row]
        }
        else{
            return platforms[row]
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        if pickerView == self.gamePicker {
        //index into the gameInfo dictionary
        let index = allGames[row]
        let gameInfo = gameProperties[index] as? NSDictionary
        //change gameField text to the selected item
        self.gameField.text = allGames[row]
        //re-enable the scrol view
        self.scrollView.isScrollEnabled = true
        //show/hide the platform view
        self.selectedGameImg.isHidden = false
        self.gameStackView.isHidden = false
        self.gamePicker.isHidden = false
        self.platformContainerView.isHidden = false
        
        
        if let gameInfo = gameInfo {
            let gamePlatforms = gameInfo["platforms"] as? NSDictionary
        
            //store the game platforms in the platofrms item picker
            if let gamePlatforms = gamePlatforms {
                print("gmae platforms: \(gamePlatforms)")
                //delete all elements from platform array
                self.platforms.removeAll()
                for (key, element) in gamePlatforms {
                    print("key = \(key)")
                    self.platforms.append(key as! String)
                }
                self.platformPicker.reloadAllComponents()
                print("platofrms has \(platforms.count)")
            }
            
            //show/hide game properties based on the selected game
            let info = gameInfo["properties"] as? NSDictionary
            if let info = info {
                if let rank = info["rank"] as? Int{
                    self.rankContainer.isHidden = false
                    self.rankField.isHidden = false
                }else{
                    self.rankContainer.isHidden = true
                    self.rankField.isHidden = true
                }
                if let role = info["role"] as? Int{
                    self.roleContainer.isHidden = false
                    self.roleField.isHidden = false
                }else{
                    self.roleContainer.isHidden = true
                    self.roleField.isHidden = true
                }
                if let level = info["level"] as? Int{
                    self.levelContainer.isHidden = false
                    self.levelField.isHidden = false
                }else{
                    self.levelContainer.isHidden = true
                    self.levelField.isHidden = true
                }
                
            }
            
            //show the game image
            let gameId = gameInfo["id"] as? String
            if let id = gameId {
                DatabaseHelper.downloadGameIcon(id: id) { icon in
                    self.selectedGameImg.image = icon
                    self.selectedGameImg.isHidden = false
                }

            }
            
        }
        
        print(gameInfo)
        }
        else if pickerView == self.rolePicker {
            self.roleField.text = roles[row]
            self.scrollView.isScrollEnabled = true
        }
        else{
            //set the platform field text to the selected item
            self.platformField.text = self.platforms[row]
            self.scrollView.isScrollEnabled = true
        }
       
        scrollView.isScrollEnabled = true
        
    }
    
    
    //disables user from editing textfield text
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    //when user clicks on game button hide the picker
    //if it is already open or show the picker if it is hidden
    func gameFieldClicked(sender: UITextField) {
            print("clicked")
        
            //if picker is hidden then show it
            if gamePicker.isHidden == true {
                scrollView.isScrollEnabled = false
                self.selectedGameImg.isHidden = true
                UIView.animate(withDuration: 0.25, animations: {
                    self.selectedGameImg.isHidden = true
                    self.platformContainerView.isHidden = true
                    self.gamePicker.isHidden = false
                })
            }
            //if picker is open then hide it
            else{
                
                print("clicked")
                scrollView.isScrollEnabled = true
                //animate picker hiding
                UIView.animate(withDuration: 0.25, animations: {
                    self.gamePicker.isHidden = true
                    self.platformContainerView.isHidden = false
                })
            }
        
    }
    
    func platformFieldClicked(sender: UITextField) {
        print("clicked")
        
        //if picker is hidden then show it
        if platformPicker.isHidden == true {
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
    
    func roleFieldClicked(sender: UITextField) {
        print("clicked")
        
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
    
    func getAllGames(){
        let database = Database.database()
        let ref = database.reference()
        
        ref.child("Games").observeSingleEvent(of: .value, with: { snapshot in
            
            //snapshot success
            if snapshot.exists(){
                
                //loop over 'games' children to get each game
                let enumerator = snapshot.children
                while let child = enumerator.nextObject() as? DataSnapshot {
                    print("key : \(child.key)")
                    //check if user already has this game
                    if let userGames = self.usersGames {
                        //if this childs key is not the title of a game in the users game list then add it
                        //game is alraedy in users game so skip it
                        if userGames.contains(where: {$0.title == child.key}){
                            continue
                        }
                        //game is not in users games so add to list
                        else{
                             //store database info as a dictionary
                             let value = child.value as? NSDictionary
                             let gameTitle = child.key
                             let gameId = value?["id"] as? String
                            //get game id so we can look up its icon
                            if let id = gameId {
                                DatabaseHelper.downloadGameIcon(id: id) { icon in
                                    self.selectedGameImg.image = icon
                                    self.allGames.append(child.key)
                                    print("added key to allgames")
                                    
                                    
                                    if let value = value{
                                        self.gameProperties[child.key] = value
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                    
                    else{
                        print("no user games found")
                        return
                    }
                    
                }

            }
            //snapshot failed
            else{
                print("failed to find games. Snapshot not found")
            }
        })
    }
    
    
}
