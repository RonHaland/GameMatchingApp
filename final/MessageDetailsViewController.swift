//
//  MessageDetailsViewController.swift
//  final
//
//  Created by Ronny Håland on 11/12/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import UIKit

class MessageDetailsViewController: UIViewController {

    @IBOutlet weak var message: UILabel!
    var messageItem:Message?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = messageItem?.displayName
        self.message.text = messageItem?.message
    }

    

}
