/*
 * MainViewController.swift
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
import FirebaseUI
import ProgressHUD
import CustomIOSAlertView

protocol LogoutProtocol {
    func logout()
}

class MainViewController: UITableViewController {
    let auth = Auth.auth().currentUser!
    let ref = Database.database().reference()
    var dataset: [Note] = []
    
    var selectedRow = 0
    var editNoteID: String!
    var noteCode: NoteCode!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView setup
        tableView.delegate = self
        tableView.dataSource = self
        
        // ProgressHUD
        ProgressHUD.show()
        
        // Firebase setup
        ref.child("users").child(auth.uid).observe(.value, with: { (snapshot) in
            ProgressHUD.dismiss()
            
            self.clearNotes()
            
            for note: DataSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                if let noteObject = note.value as? [String: String] {
                    self.add(note: Note(
                        uid: note.key,
                        title: noteObject["title"] ?? "",
                        date: noteObject["date"] ?? "",
                        body: noteObject["body"] ?? ""))
                }
            }
        })
    }
    
    // MARK: - Table view data source
    func clearNotes() {
        dataset.removeAll()
        tableView.reloadData()
    }
    
    func add(note: Note) {
        dataset.append(note)
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataset.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reversed = dataset.reversed()[indexPath.row]
        let noteCell = tableView.dequeueReusableCell(withIdentifier: "noteItem", for: indexPath) as! NoteCell
        noteCell.titleLabel.text = reversed.title
        noteCell.dateLabel.text = reversed.date
        
        return noteCell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .default, title: NSLocalizedString("edit", comment: "Edit button"))
        { (action, indexPath) in
            self.editNote(noteID: self.dataset.reversed()[indexPath.row].uid)
        }
        editAction.backgroundColor = UIColor(red: 25/255, green: 118/255, blue: 210/255, alpha: 1.0)
        
        let deleteAction =
            UITableViewRowAction(style: .destructive, title: NSLocalizedString("delete", comment: "Edit button"))
        { (action, indexPath) in
            self.deleteNote(id: self.dataset.reversed()[indexPath.row].uid)
        }
        
        return [deleteAction, editAction]
    }
    
    // MARK: - Table View Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "viewNote", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewNote" {
            let viewerVC = segue.destination as! ViewerViewController
            viewerVC.delegate = self
            viewerVC.noteID = dataset.reversed()[selectedRow].uid
        } else if segue.identifier == "addEditNote" {
            let navigationVC = segue.destination as! UINavigationController
            let noteVC = navigationVC.topViewController as! NoteViewController
            noteVC.code = noteCode
            noteVC.noteID = editNoteID
        }
        
    }
    
    // MARK: - Database Methods
    func editNote(noteID: String) {
        editNoteID = noteID
        noteCode = NoteCode.EDIT_NOTE
        performSegue(withIdentifier: "addEditNote", sender: self)
    }
    
    func addNote() {
        noteCode = NoteCode.ADD_NOTE
        performSegue(withIdentifier: "addEditNote", sender: self)
    }
    
    func deleteNote(id: String) {
        let alertController =
            UIAlertController(
                title: NSLocalizedString("delete", comment: "Title for alert"),
                message: NSLocalizedString("delete.title", comment: "Message for alert"),
                preferredStyle: .alert)
        
        let deleteAction =
            UIAlertAction(title: NSLocalizedString("delete.OK",comment: "OK button"),
                          style: .destructive) { (alertAction) in
            self.ref.child("users").child(self.auth.uid).child(id).removeValue()
        }; alertController.addAction(deleteAction)
        
        let cancelAction =
            UIAlertAction(title: NSLocalizedString("delete.cancel", comment: "Cancel button"),
                          style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Button events
    @IBAction func onAddPressed(_ sender: UIBarButtonItem) {
        addNote()
    }
    
    @IBAction func onLogoutPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: NSLocalizedString("logout", comment: "Alert title"),
            message: NSLocalizedString("logout.message", comment: "Alert message"),
            preferredStyle: .actionSheet)
        
        // iPad support
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = (sender.value(forKey: "view") as! UIView).bounds
        }
        
        let aboutAlertController = CustomIOSAlertView()
        aboutAlertController?.buttonTitles =
            [NSLocalizedString("about.website", comment: "Website button"),
             NSLocalizedString("delete.OK", comment: "OK button")]

        
        aboutAlertController?.delegate = self
        let view = UINib(nibName: "About", bundle: .main)
            .instantiate(withOwner: nil, options: nil).first as! UIView
        aboutAlertController?.containerView = view
        
        let aboutAction = UIAlertAction(
            title: NSLocalizedString("logout.about", comment: "About action label"),
            style: .default) { _ in
                aboutAlertController?.show()
        }
        alertController.addAction(aboutAction)
        
        let logoutAction = UIAlertAction(
            title: NSLocalizedString("logout", comment: "Logout action label"),
            style: .destructive) { _ in
                do {
                    try Auth.auth().signOut()
                    
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                } catch { ProgressHUD.show(error.localizedDescription) }
        }
        alertController.addAction(logoutAction)
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("delete.cancel", comment: "Cancel action label"),
            style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension MainViewController: CustomIOSAlertViewDelegate {
    func customIOS7dialogButtonTouchUp(inside alertView: Any!, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            UIApplication.shared.open(
                URL(string: "http://yournal.dulcedosystems.com")!,
                options: [:], completionHandler: nil)
        } else if buttonIndex == 1 {
            (alertView as! CustomIOSAlertView).close()
        }
    }
}

extension MainViewController: ViewerDelegate {
    
    func editNote(withID id: String) {
        editNote(noteID: id)
    }
    
    func deleteNote(withID id: String) {
        deleteNote(id: id)
    }
}
