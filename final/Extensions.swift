//
//  Extensions.swift
//  final
//
//  Created by Ronny Håland on 11/20/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
    
    func hideKeyboardWhenTappedAround(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    //extension to show toast
    func showToast(message:String, segueIdentifier:String?){
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width / 2  - 85, y: self.view.frame.size.height - 100, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light",size:12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration:4.0,delay:0.1,options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        },completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
            
            if let segueIdentifier = segueIdentifier {
                self.performSegue(withIdentifier:segueIdentifier, sender: self)
            }
        })
        
    }
}
