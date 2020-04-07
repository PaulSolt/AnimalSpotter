//
//  LoginViewModel.swift
//  AnimalSpotter
//
//  Created by Scott Gardner on 4/7/20.
//  Copyright © 2020 Scott Gardner. All rights reserved.
//

import Foundation

final class LoginViewModel {
    enum LoginResult: String {
        case signUpSuccess = "Sign up successful. Now please log in."
        case signInSuccess
        case signUpError = "Error occurred during sign up."
        case signInError = "Error occurred during sign in."
    }
    
    private let apiController: APIController
    
    init(apiController: APIController = APIController()) {
        self.apiController = apiController
    }
    
    private func signUp(with user: User, completion: @escaping (LoginResult) -> Void) {
        apiController.signUp(with: user) { result in
            switch result {
            case .success(_):
                completion(.signUpSuccess)
            case .failure(_):
                completion(.signUpError)
            }
        }
    }
    
    private func signIn(with user: User, completion: @escaping (LoginResult) -> Void) {
        apiController.signIn(with: user) { result in
            switch result {
            case .success(_):
                completion(.signInSuccess)
            case .failure(_):
                completion(.signInError)
            }
        }
    }
}
