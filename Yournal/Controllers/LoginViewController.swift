/*
 * ViewController.swift
 *
 * Copyright 2019 Iván Ávalos <ivan.avalos.diaz@hotmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 *
 */

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseEmailAuthUI
import FirebaseGoogleAuthUI

class LoginViewController: UIViewController {
    
    func showUI() {
        if Auth.auth().currentUser == nil {
            if let authUI = FUIAuth.defaultAuthUI() {
                print("It's all good!")
            
                authUI.delegate = self
                authUI.providers = [
                    FUIEmailAuth(),
                    FUIGoogleAuth(authUI: authUI)
                ]
            
                let authViewController = authUI.authViewController()
                authViewController.presentationController?.delegate = self
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

extension LoginViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
}

extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error != nil {
            return
        } else {
            showUI()
        }
    }
}

extension FUIAuthBaseViewController {
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
    }
}
