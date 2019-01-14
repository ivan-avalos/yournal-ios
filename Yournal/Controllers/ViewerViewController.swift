//
//  ViewerViewController.swift
//  Yournal
//
//  Created by Iván Ávalos on 11/17/18.
//  Copyright © 2018 Iván Ávalos. All rights reserved.
//

import UIKit
import Firebase

protocol ViewerDelegate {
    func editNote(withID id: String)
    func deleteNote(withID id: String)
}

class ViewerViewController: UIViewController {
    var noteID: String!
    var delegate: ViewerDelegate!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userID = Auth.auth().currentUser?.uid {
            Database.database().reference()
                .child("users")
                .child(userID)
                .child(noteID)
                .observe(.value, with: { (snapshot) in
                    if let note = snapshot.value as? [String: String] {
                        /*self.navigationItem.title = note["title"]*/
                        self.titleLabel.text = note["title"]
                        self.dateLabel.text = note["date"]
                        self.bodyTextView.text = note["body"]
                    }
            })
        }
    }

    @IBAction func onEditPressed(_ sender: UIBarButtonItem) {
        delegate.editNote(withID: noteID)
    }
    
    @IBAction func onDeletePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
        navigationController?.popViewController(animated: false)
        delegate.deleteNote(withID: noteID)
    }
    
}
