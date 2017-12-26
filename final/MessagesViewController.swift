//
//  MessagesViewController.swift
//  final
//
//  Created by Ronny Håland on 11/12/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

/*
 Message Object description:
 
 MessageID:
 {
 "Sender":senderID
 "Reciever":recieverID
 "Date":Date
 "Message":MessageContent
 }
 
 */

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FirebaseAuth

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var messageData: [String:Message]?
    var messageList: [Message] = []
    var loggedInUser:String = "unknown"
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var leftButton: UIBarButtonItem!
    
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TODO: OBTAIN USERNAME FOR CURRENT USER
        DatabaseHelper.getUserMessages(username: self.loggedInUser) { messages in
            self.messageList = messages
            self.messageTableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTableView.dataSource = self
        let email = Auth.auth().currentUser?.email
        DatabaseHelper.getUsername(email: email!) { name in
            self.loggedInUser = name
            DatabaseHelper.getUserMessages(username: self.loggedInUser) { messages in
                self.messageList = messages
                self.messageTableView.reloadData()
            }
        }
    }
    
    
    @IBAction func showEditing(_ sender: Any) {
        if(messageTableView.isEditing == true)
        {
            messageTableView.setEditing(false, animated: true)
            self.navigationItem.leftBarButtonItem?.title = "Edit"
        }
        else
        {
            messageTableView.setEditing(true, animated: true)
            self.navigationItem.leftBarButtonItem?.title = "Done"
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        
        let msg = messageList[indexPath.row]
        
        let date = DateFormatter.localizedString(from: msg.date, dateStyle: .short, timeStyle: .none)
        cell.name.text = msg.displayName
        cell.time.text = date
        cell.message.text = msg.message
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let msg = messageList[indexPath.row]
            
            let date = DateFormatter.localizedString(from: msg.date, dateStyle: .medium, timeStyle: .short)
            let title = "Delete the message from \(msg.sender), \(date)?"
            let message = "Are you sure you want to delete this item?"
            
            let ac = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {Void in
                
                let messageID = String(Int(self.messageList[indexPath.row].date.timeIntervalSince1970*10))
                print(self.messageList[indexPath.row].date.timeIntervalSince1970*10)
                let ref = Database.database().reference()
                ref.child("users").child(self.loggedInUser).child("messages").child(messageID).setValue(nil)
                // Remove the item from the store
                self.messageList.remove(at: indexPath.row)
                
                // Also remove that row from the table view with an animation
                self.messageTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            ac.addAction(deleteAction)
            present(ac, animated: true, completion: nil)
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "MessageDetails"?:
            if let row = messageTableView.indexPathForSelectedRow?.row {
                let msg = messageList[row]
                let otherVC = segue.destination as! MessageDetailsViewController
                
                otherVC.messageItem = msg
                
            }
        case "MessageNew"?:
            print("New Message")
            
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }

}
