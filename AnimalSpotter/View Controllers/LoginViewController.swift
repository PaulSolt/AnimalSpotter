//
//  LoginViewController.swift
//  AnimalSpotter
//
//  Created by Scott Gardner on 4/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

enum LoginType: String {
    case signUp = "Sign Up"
    case signIn = "Sign In"
}

class LoginViewController: UIViewController {
    // MARK: - Properties
    
    static let identifier: String = String(describing: LoginViewController.self)
    
    @IBOutlet weak var loginTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var loginType = LoginType.signUp
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.layer.cornerRadius = 8
    }
    
    // MARK: - Actions
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func loginTypeChanged(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        
    }
}
