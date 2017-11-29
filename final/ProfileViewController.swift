//
//  ProfileViewController.swift
//  final
//
//  Created by Benjamin Dagg on 10/24/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

/*
 Displays the profle info for the passed in User object
 */

/*
 TODO
 1. title of nav bar is messed up not detecting if the profile
 is the current users profile
 2. implement search bar
 3. implement deleting game from list
 4. implement edit profile

 */


import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FirebaseAuth
import CoreData
 

//reference to storage on Firebase databse
let storage = Storage.storage()
let storageRef = storage.reference()



class ProfileViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    
    
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var gameNavBar: UINavigationItem!
    @IBOutlet weak var gamesTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImg: UIImageView!

    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredGames:[Game] = []
    
    
    //user object for this users profile
    //passed in from viewcontroller that seegued to this VC
    var targetUser: User?
        
    
    
    override func viewDidLoad() {
        
        if let games = self.targetUser?.games {
            
        }
        
        super.viewDidLoad()
        print("user username ===== \(targetUser?.userName)")
        
       //set up table view
        self.gamesTableView.delegate = self
        self.gamesTableView.dataSource = self
        
        //set nav bars title depending on whos profile it is
        title = "Profile"
        
        if let user = targetUser {
            self.nameLabel.text = user.name
            self.usernameLabel.text = user.userName
            self.regionLabel.text = user.region.rawValue
        }
        
        //hides keyboard when usr click out
        hideKeyboardWhenTappedAround()
        
        //setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = UIBarStyle.black
        self.gamesTableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search Games"
        definesPresentationContext = true
        
        //add edit btn to nav controller
        let editBtn = UIBarButtonItem(title: "Edit", style: .done, target: self, action:#selector(editProfile))
        self.navigationItem.rightBarButtonItem = editBtn
        
        //add delete button to games nav controller
        let deleteBtn = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(enableEditing))
        self.gameNavBar.leftBarButtonItem = deleteBtn
        
        if let user = self.targetUser {
            if let CDUser = CoreDataHelper.getUser(email: user.email){
                print("got user from CD")
                print("core data getUser = \(CDUser.userName)")
            }else{
                print(")failed to get user from CD")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUserInfo()
        
        //check for updates on users games
        if let username = self.targetUser?.userName{
            DatabaseHelper.getUserGames(username: username) { result in
                self.targetUser?.games = result
                self.gamesTableView.reloadData()
                
            }
            //get user profile image
            getUserProfileImgifExists()
        }
        
        //make table view not in edit mode
        self.gamesTableView.isEditing = false
        self.gameNavBar.leftBarButtonItem?.title = "Delete"
        
        if let user = self.targetUser {
            CoreDataHelper.loadUserFromCD(username: user.userName)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //save users info to core data
        if let user = self.targetUser {
            CoreDataHelper.saveUserToCD(user: user)
        }
    }
    
    /*
     Called when delete button pressed. Puts game table view in editing mode
    */
    func enableEditing(sender: UIBarButtonItem) {
        if self.gamesTableView.isEditing == true {
            self.gamesTableView.isEditing = false
            self.gameNavBar.leftBarButtonItem?.title = "Delete"
        }else{
            self.gamesTableView.isEditing = true
            self.gameNavBar.leftBarButtonItem?.title = "Done"
        }
    }
    
    
    func getUserProfileImgifExists() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let user = self.targetUser {
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
                                            self.profileImg.image = userPhoto
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

    
    func editProfile(sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ShowEditProfileVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //send array of users games to AddGameVC before segue so it can see which games the user already has
        if segue.identifier == "ShowAddGameVC" {
            if let destinationVC = segue.destination as? AddGameViewController {
                if let user = self.targetUser {
                    if let games = user.games {
                        destinationVC.usersGames = games
                        
                        print("sent users games to add VC")
                    }
                    destinationVC.user = user
                }
            }
        }
        if segue.identifier == "ShowGameDetailsSegue" {
            let destination = segue.destination as? EditGameViewController
            //find which row was selected
            guard let index = gamesTableView.indexPathForSelectedRow?.row else{
                return
            }
            //send the info for the selected game depending on if user is filtering or not
            if isFiltering() {
                destination?.title = filteredGames[index].title
                if let user = self.targetUser{
                    destination?.user = user
                }
                destination?.game = filteredGames[index]
            }else{
                destination?.title = self.targetUser?.games?[index].title
                if let user = self.targetUser{
                    destination?.user = user
                }
                destination?.game = self.targetUser?.games?[index]
                
            }
        }
        if segue.identifier == "ShowEditProfileVC" {
            if let destination = segue.destination as? EditProfileViewController {
                
                if let user = self.targetUser {
                    destination.user = user
                }
                
            }
            
        }
    }
    
    
    func updateUserInfo() {
        
        if let passedUser = self.targetUser {
            let ref = Database.database().reference()
            ref.child("users").child(passedUser.userName).observeSingleEvent(of: .value, with: {snapshot in
                
                if snapshot.exists(){
                    let value = snapshot.value as? NSDictionary
                    if let value = value {
                        if let username = value["username"] as? String {
                            self.targetUser?.userName = username
    
                        }
                       
                        if let uid = value["uid"] as? String {
                            self.targetUser?.userID = uid
                        }
                        if let name = value["name"] as? String {
                            self.targetUser?.name = name
                        }
                        if let region = value["region"] as? String{
                            self.targetUser?.region = Region.stringToCase(string: region)
                        }
                        if let email = value["email"] as? String {
                            self.targetUser?.email = email
                        }
                        print("updated values")
                        DispatchQueue.main.async {
                            if let user = self.targetUser {
                                self.regionLabel.text = user.region.rawValue
                                
                            }
                        }

                    }
                }
            })
            
        }
    }
    
    //==================== Table View Funcs ====================
    //required method for tableview tells number of sections
    //in the tabble
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    //required method for table view tells the number of rows
    //to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //check if user has any games
        if let games = self.targetUser?.games {
            //if user is searching use the filtered games array
            if isFiltering(){
                return self.filteredGames.count
            }
            //if not filtering then use the regular games aray
            else{
                return games.count
            }
        }
        //if users games are nil return 0
        else{
            return 0
        }
    }
    
    
    
    
    //required tableview method. Tells table view which
    //cell to draw
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //m custom cell ID
        let cellIdentifier = "GameCell"
        
        //get a cell from the queue
        //and cast it as my cutsom cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GameTableViewCell else{
            fatalError("dequeue cell not instance of CrimeCell")
        }
        
        //crime objy.nect to display the crime info for this cell
        let game:Game
        
        if isFiltering(){
            game = filteredGames[indexPath.row]
        }
        else{
            game = (self.targetUser?.games?[indexPath.row])!
        }
        
        cell.gameTitleLabel.adjustsFontSizeToFitWidth = true
        
        switch game.platform{
        case .PC:
            cell.gamePlatformImg.image = UIImage(named: "steamlogo")
        case .PS3:
            cell.gamePlatformImg.image = UIImage(named: "ps3logo")
        case .PS4:
            cell.gamePlatformImg.image = UIImage(named: "ps4logo")
        case .Xbox360:
            cell.gamePlatformImg.image = UIImage(named: "xbox360logo")
        case .XboxOne:
            cell.gamePlatformImg.image = UIImage(named: "xboxonelogo")
        default: break
            
        }
        
        cell.gameImgLabel.image = game.icon
        cell.gameTitleLabel.text = game.title
        cell.gameTitleLabel.sizeToFit()

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowGameDetailsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if let user = self.targetUser {
                if let games = user.games {
                    if games.count > 0 && games.count >= indexPath.row {
                        
                        if isFiltering() == false {
                            let gameTitle = games[indexPath.row].title
                            let ref = Database.database().reference()
                            ref.child("users").child(user.userName).child("games").child(gameTitle).setValue(nil)
                        
                            self.targetUser?.games?.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                        else {
                            if self.filteredGames.count >= indexPath.row {
                                let ref = Database.database().reference()
                                let gameTitle = self.filteredGames[indexPath.row].title
                                
                                ref.child("users").child(user.userName).child("games").child(gameTitle).setValue(nil)
                                self.filteredGames.remove(at: indexPath.row)
                                for i in 0..<games.count {
                                    if games[i].title == gameTitle {
                                        self.targetUser?.games?.remove(at: i)
                                    }
                                }
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                        }
                        
                    }
                }
            }
            
            
        }
        else if editingStyle == .insert {
            
        }
    }
    //==========================================================
    
    /*
    Lets views in other view controllers unwind back to this VC
    */
    @IBAction func unwindToProfileVC(segue: UIStoryboardSegue){
        
    }
    
    /* ================= SearchBar stuff =======================*/
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        if let games = self.targetUser?.games {
            filteredGames = games.filter({(game: Game) -> Bool in
                return game.title.lowercased().contains(searchText.lowercased())
            })
        }
        self.gamesTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    
    
    
}
