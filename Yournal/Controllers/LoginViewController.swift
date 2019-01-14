//
//  ViewController.swift
//  Yournal
//
//  Created by Iván Ávalos on 11/16/18.
//  Copyright © 2018 Iván Ávalos. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class LoginViewController: UIViewController {
    
    func showUI() {
        if Auth.auth().currentUser == nil {
            if let authUI = FUIAuth.defaultAuthUI() {
                print("It's all good!")
            
                authUI.delegate = self
                authUI.providers = [FUIGoogleAuth()]
            
                let authViewController = authUI.authViewController()
                present(authViewController, animated: true, completion: nil)
            }
        } else {
            performSegue(withIdentifier: "goToHome", sender: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showUI()
    }
    
}

extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error != nil {
            return
        }
    }
}

extension FUIAuthBaseViewController {
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
    }
}
