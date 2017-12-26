//
//  PostViewController.swift
//  final
//
//  Created by Benjamin Dagg on 11/29/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FirebaseAuth

class PostViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    
    
    @IBOutlet weak var resetFilterBtn: UIButton!
    @IBOutlet weak var goBtn: UIButton!
    @IBOutlet weak var platformPicker: UIPickerView!
    @IBOutlet weak var regionField: UITextField!
    @IBOutlet weak var regionPicker: UIPickerView!
    @IBOutlet weak var gameField: UITextField!
    @IBOutlet weak var gamePicker: UIPickerView!
    @IBOutlet weak var platformField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContainer: UIView!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var filters: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var posts:[Post] = []
    var user:User?
    let platforms = ["PC", "PS3", "PS4", "Xbox360", "XboxOne"]
    let regions = ["NA", "SA", "Europe", "Asia"]
    var games:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup tabeview
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //seetup scrollview
        scrollView.delegate = self
        scrollView.isDirectionalLockEnabled = true
        
        //add function to filter button to show filters
        self.filterBtn.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        
        //add function to go button to filter table view
        self.goBtn.addTarget(self, action: #selector(filter), for: .touchUpInside)
        
        //add function to reset butn to reset filters and reload table view
        self.resetFilterBtn.addTarget(self, action: #selector(resetFilter), for: .touchUpInside)
        
        //put add button on nav bar
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPost))
        self.navigationItem.rightBarButtonItem = addBtn
        self.navigationItem.title = "Posts"
        
        //load the user passed from the other tab bars
        if let user = UserTransfer.sharedInstance.currentUser {
            self.user = user
            
        }
        
        //setup picker vies
        //game picker
        self.gamePicker.dataSource = self
        self.gamePicker.delegate = self
        //platform picker
        self.platformPicker.dataSource = self
        self.platformPicker.delegate = self
        //region picker
        self.regionPicker.dataSource = self
        self.regionPicker.delegate = self
        
        //make filter text fields un-editable
        self.gameField.isUserInteractionEnabled = false
        self.platformField.isUserInteractionEnabled = false
        self.regionField.isUserInteractionEnabled = false
        

        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //hide go button on filters
        self.goBtn.isHidden = true
        self.resetFilterBtn.isHidden = true
        
        getAllPosts()
        getGames()
    }
    
    
    
    
    /*
    When filters button pressed shows the filters container if it is hidden, or hides it if it is already being shown
    */
    func showFilters(sender: UIButton) {
        
        //if filters hiden, show it
        if self.filters.isHidden == true {
            //change title of filter btn
            self.filterBtn.setTitle("Close", for: .normal)
            //unhide the go and reset buttons
            self.resetFilterBtn.isHidden = false
            self.goBtn.isHidden = false
            self.filters.isHidden = false
        }
        //if filters showing then hide it
        else {
            //reset filter text
            self.filterBtn.setTitle("Filter", for: .normal)
            //hide the go and reset buttons
            self.resetFilterBtn.isHidden = true
            self.filters.isHidden = true
            self.goBtn.isHidden = true
        }
        
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //hide filters
        self.filters.isHidden = true
        
        
        //setup scrollview content size
        self.scrollView.frame = self.view.frame
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height:1000)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showAddPost" {
             if let destinationVC = segue.destination as? AddPostViewController {
                destinationVC.user = self.user
                
            }
        }
        if segue.identifier == "showPostDetail" {
            if let destinationVC = segue.destination as? PostDetailViewController {
                //find which row was selected
                guard let index = self.tableView.indexPathForSelectedRow?.row else{
                    return
                }
                
                destinationVC.post = self.posts[index]
            }
        }
    }
    
    
    
    /* Looks up games in the database and adds the name of each available game to the games array for the game picker
    */
    func getGames() {
        self.games.removeAll()
        
        let ref = Database.database().reference()
        ref.child("Games").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                if let value = snapshot.value as? NSDictionary {
                    for (key, _) in value {
                        if let gameTitle = key as? String {
                            self.games.append(gameTitle)
                        }
                    }
                    DispatchQueue.main.async {
                        self.gamePicker.reloadAllComponents()
                    }
                }
            }
        })
        
    }
    
    
    
    //segues to addPostVC when click on add button
    func addPost(sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "showAddPost", sender: self)
    }
    
    
    
    //this function disables horizontal scrolling on the scrollview
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 0 || scrollView.contentOffset.x < 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    
    
    
    /*
    When go button pushed filter table view results based on the entered values in the picker views then reload the table view
    */
    func filter(sender: UIButton) {
        
        if self.gameField.text != "Game" {
            self.posts = self.posts.filter({ $0.gameTitle == self.gameField.text })
        }
        if self.platformField.text != "Platform" {
            self.posts = self.posts.filter({$0.platform.rawValue == self.platformField.text})
        }
        if self.regionField.text != "Region" {
            self.posts = self.posts.filter({$0.region.rawValue == self.regionField.text})
        }
        self.tableView.reloadData()
        
    }
    
    
    
    /*
    When reset button pressed, clear the filter text fields then reload the original posts from the database
    */
    func resetFilter(sender: UIButton) {
        //reset filter
        self.gameField.text = "Game"
        self.platformField.text = "Platform"
        self.regionField.text = "Region"
        
        //reload table view
        getAllPosts()
    }
    
    
    
    
    /*
    Gets all posts from database and creates Post objects for them then puts them in the posts array and reloads the table view to display the posts
    */
    func getAllPosts() {
        
        let group = DispatchGroup()
        let ref = Database.database().reference()
        ref.child("Posts").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                self.posts.removeAll()
                let enumerator = snapshot.children
                while let child = enumerator.nextObject() as? DataSnapshot {
                    group.enter()
                    let value = child.value as? NSDictionary
                    
                    if let value = value {
                        print("in getallposts")
                        let tempPost = Post()
                        if let gamertag = value["gamertag"] as? String {
                            tempPost.gamertag = gamertag
                        }
                        if let platform = value["platform"] as? String {
                            tempPost.platform = Platform(rawValue: platform)!
                        }
                        if let postdate = value["postdate"] as? TimeInterval {
                            print("postdate = \(postdate)")
                            let date = NSDate(timeIntervalSince1970: postdate)
                            tempPost.postDate = date as Date
                            print("got date \(tempPost.postDate)")
                            
                        }
                        if let region = value["region"] as? String {
                            tempPost.region = Region.stringToCase(string: region)
                        }
                        
                        if let gameTitle = value["game"] as? String {
                            
                           tempPost.gameTitle = gameTitle
                            
                            let gameIdRef = Database.database().reference()
                            print("gametitle = \(gameTitle)")
                            gameIdRef.child("Games").child(gameTitle).observeSingleEvent(of: .value, with: { snapshot in
                                
                                if snapshot.exists() {
                                    let gameValue = snapshot.value as? NSDictionary
                                    if let gameValue = gameValue {
                                        if let id = gameValue["id"] as? String {
                                            DatabaseHelper.downloadGameIcon(id: id, completion: { icon in
                                                tempPost.gameImg = icon
                                                self.posts.append(tempPost)
                                            print("finished post")
                                            print("posts now have \(self.posts.count)")
                                            group.leave()
                                            })
                                        }
                                    }
                                }
                            })
                        }
                    }
                    
                }
                group.notify(queue: .main) {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            
        })
        
    }
    
    
    
    
    /* ============= Table View ================ */
    //sets number of section in table view
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    //sets the height for each cell in the table view. Sets to 150 for my cusstom table view cell class
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    //required method for table view tells the number of rows
    //to display. Sets # rows to size of post array from the database
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    
    
    
    /*required tableview method. Tells table view which
    cell to draw. Creates a cell object of PostTableViewCell. Sets its fields according to a Post object then adds it to the table view
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //m custom cell ID
        let cellIdentifier = "PostTableViewCell"
        
        //get a cell from the queue
        //and cast it as my cutsom cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PostTableViewCell else{
            fatalError("dequeue cell not instance of CrimeCell")
        }
        
        
        print("posts have \(self.posts.count)")
        print("index = \(indexPath.row)")
        //crime objy.nect to display the crime info for this cell
        let post = self.posts[indexPath.row]
        
        
        cell.gameTitleLabel.adjustsFontSizeToFitWidth = true
        
        //get platform image from the cell
        switch post.platform {
        case .PC:
            cell.platformImg.image = UIImage(named: "steamlogo")
        case .PS3:
            cell.platformImg.image = UIImage(named: "ps3logo")
        case .PS4:
            cell.platformImg.image = UIImage(named: "ps4logo")
        case .Xbox360:
            cell.platformImg.image = UIImage(named: "xbox360logo")
        case .XboxOne:
            cell.platformImg.image = UIImage(named: "xboxonelogo")
        //default: break
            
        }
        
        cell.gameTitleLabel.text = post.gameTitle
        cell.regionLabel.text = "Region: \(post.region.rawValue)"
        cell.usernameLabel.text = "Gamertag: \(post.gamertag)"
        cell.gameTitleLabel.sizeToFit()
        cell.gameImg.image = post.gameImg
        
        /*
        Gets the time since the post was posted
        */
        let cal = Calendar.current
        let today = Date()
        let diff = cal.dateComponents([.minute], from: today, to: post.postDate)
        //set cell time label to time since post was posted
        if let minute = diff.minute {
            let res  = abs(minute)
            
            if res < 60 {
                cell.timeLabel.text = "Posted \(res) minutes ago"
            }
            else if res >= 60 && res < 1440 {
                
                cell.timeLabel.text = "Posted \(res / 60) hours ago"
            }
            else {
                cell.timeLabel.text = "Posted \(res / 1440) days ago"
            }
        }
        
        return cell

    }
    
    
    /*
    When cell of table view is clicked, transfer the info of that post to the PostDetailViewController then segue
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row >= 0 && indexPath.row <= self.posts.count - 1 {
            self.performSegue(withIdentifier: "showPostDetail", sender: self)
        }
        
    }
    
    /*=================================================*/

    /* picker view methods */
    //sets number of column in pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //sets number of rows in picker view to # of available regions
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == self.gamePicker {
            return self.games.count
        }
        else if pickerView == self.platformPicker {
            return self.platforms.count
        }
        else {
            return self.regions.count
        }
        
    }
    
    //sets text for row of pickerView that is selected
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == self.gamePicker {
            return self.games[row]
        }
        else if pickerView == self.platformPicker {
            return self.platforms[row]
        }
        else {
            return self.regions[row]
        }
        
    }
    
    /*
    When row of picker clicked set the text field to the selected item
    */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == self.gamePicker {
            
            //set text on game field to the selected item
            self.gameField.text = self.games[row]
            
        }
        else if pickerView == self.platformPicker {
            self.platformField.text = self.platforms[row]
        }
        else {
            self.regionField.text = self.regions[row]
        }
        
    }
    
    
    
    
    //this function called in another view controller to unwind back to this view controller (called in add post vc)
    @IBAction func unwindToPosts(segue: UIStoryboardSegue) {
        //unwind
    }


    
    
}
extension Date {
    
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    
}
