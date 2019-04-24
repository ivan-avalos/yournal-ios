/*
 * ViewerViewController.swift
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
                        self.title = note["title"]
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
