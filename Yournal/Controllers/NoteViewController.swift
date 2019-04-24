/*
 * NoteViewController.swift
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

enum NoteCode {
    case ADD_NOTE
    case EDIT_NOTE
}

class NoteViewController: UIViewController, UITextFieldDelegate {
    var code: NoteCode!
    var noteID: String?
    var note: DatabaseReference!
    var dismiss = false
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.becomeFirstResponder()
        titleTextField.delegate = self
        
        /* Keyboard events */
        NotificationCenter.default
            .addObserver(self, selector: #selector(keyboardWillShow),
                         name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default
            .addObserver(self, selector: #selector(keyboardWillHide),
                         name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let userID = Auth.auth().currentUser?.uid {
            if (code == NoteCode.ADD_NOTE) {
                navigationItem.title = "Add Note"
                
                note = Database.database().reference()
                    .child("users")
                    .child(userID).childByAutoId()
                
            } else if (code == NoteCode.EDIT_NOTE) {
                navigationItem.title = "Edit Note"
                
                note = Database.database().reference()
                    .child("users")
                    .child(userID)
                    .child(noteID!)
                
                note.observe(.value, with: { (snapshot) in
                    if let note = snapshot.value as? [String: String] {
                        self.titleTextField.text = note["title"]
                        self.bodyTextView.text = note["body"]
                    }
                })
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        bodyTextView.becomeFirstResponder()
        bodyTextView.selectedTextRange = bodyTextView.textRange(from: bodyTextView.beginningOfDocument, to: bodyTextView.beginningOfDocument)
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue =
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            bottomConstraint.constant = keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 0
        if dismiss {
            dismiss(animated: true, completion: nil)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        if (code == NoteCode.ADD_NOTE) {
            // Date format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
            
            var noteDict = [String: String]()
            noteDict["title"] = titleTextField.text
            noteDict["date"] = dateFormatter.string(from: Date())
            noteDict["body"] = bodyTextView.text
            
            note.setValue(noteDict)
        } else if (code == NoteCode.EDIT_NOTE) {
            note?.child("title").setValue(titleTextField.text)
            note?.child("body").setValue(bodyTextView.text)
        }
        
        dismiss = true
        view.endEditing(false)
    }
    
    @IBAction func onCancelPressed(_ sender: UIBarButtonItem) {
        dismiss = true
        view.endEditing(false)
    }
    

}
