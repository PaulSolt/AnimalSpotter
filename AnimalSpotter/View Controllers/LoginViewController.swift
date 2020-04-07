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
    lazy var viewModel = LoginViewModel()
    
    private var isFetching: Bool = false {
        didSet {
            if isFetching {
                activityIndicator.startAnimating()
                submitButton.isEnabled = false
            } else {
                activityIndicator.stopAnimating()
                submitButton.isEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.layer.cornerRadius = 8
    }
    
    // MARK: - Actions
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func loginTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            loginType = .signIn
            passwordTextField.textContentType = .password
        default:
            loginType = .signUp
            passwordTextField.textContentType = .newPassword
        }
        
        submitButton.setTitle(loginType.rawValue, for: .normal)
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
        submitButton.isEnabled = usernameTextField.text?.isEmpty == false &&
            passwordTextField.text?.isEmpty == false
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        isFetching = true
        
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            username.isEmpty == false,
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            password.isEmpty == false
            else { return }
        
        let user = User(username: username, password: password)
        
        viewModel.submit(with: user, forLoginType: loginType) { loginResult in
            DispatchQueue.main.async {
                self.isFetching = false
                let alert: UIAlertController
                let action: () -> Void
                
                switch loginResult {
                case .signUpSuccess:
                    alert = self.alert(title: "Success", message: loginResult.rawValue)
                    action = {
                        self.present(alert, animated: true)
                        self.loginTypeSegmentedControl.selectedSegmentIndex = 1
                        self.loginTypeSegmentedControl.sendActions(for: .valueChanged)
                    }
                case .signInSuccess:
                    action = { self.dismiss(animated: true) }
                case .signUpError, .signInError:
                    alert = self.alert(title: "Error", message: loginResult.rawValue)
                    action = { self.present(alert, animated: true) }
                }
                
                action()
            }
        }
    }
    
    private func alert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        return alert
    }
}
