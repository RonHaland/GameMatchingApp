//
//  Message.swift
//  final
//
//  Created by Ronny Håland on 11/12/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import Foundation
import UIKit

class Message:NSObject{
    var sender:String
    var reciever:String
    var displayName:String
    var date:Date
    var message:String
    
    init(sender:String, reciever:String, date:Date, message:String) {
        self.sender = sender
        self.reciever = reciever
        self.date = date
        self.message = message
        let isSender = (arc4random_uniform(2) == 0)
        if isSender {
            self.displayName = reciever
        } else {
            self.displayName = sender
        }
    }
}
class MessageCell:UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var time: UILabel!
}
