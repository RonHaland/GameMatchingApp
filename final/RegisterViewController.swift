//
//  RegisterViewController.swift
//  final
//
//  Created by Benjamin Dagg on 10/6/17.
//  Copyright © 2017 Benjamin Dagg. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController,UIScrollViewDelegate {
    
    //outlets
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var registerButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up scrollview
        scrollView.delegate = self
    
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Register"
    }
    
}
