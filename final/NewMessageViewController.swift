//
//  NewMessageViewController.swift
//  final
//
//  Created by Ronny Håland on 11/20/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import UIKit

class NewMessageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var Contacts:[String] = ["Ronny","Ben","Jason","Jonas"]

    @IBOutlet weak var recipientField: UITextField!
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        let pickerView = UIPickerView()
        pickerView.delegate = self
        recipientField.inputView = pickerView
        messageTextView.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Contacts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Contacts[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        recipientField.text = Contacts[row]
    }

    @IBAction func sendMessageAction(_ sender: Any) {
    }
}
