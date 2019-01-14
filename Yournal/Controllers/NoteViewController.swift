//
//  NoteViewController.swift
//  Yournal
//
//  Created by Iván Ávalos on 11/18/18.
//  Copyright © 2018 Iván Ávalos. All rights reserved.
//

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
        
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }

}
