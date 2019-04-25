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
import WebKit
import MMMarkdown

protocol ViewerDelegate {
    func editNote(withID id: String)
    func deleteNote(withID id: String, completion: @escaping ()->())
}

class ViewerViewController: UIViewController {
    var noteID: String!
    var delegate: ViewerDelegate!
    let htmlURL = Bundle.main.url(forResource: "template", withExtension: "html")!
    let markdownURL = Bundle.main.url(forResource: "template", withExtension: "md")!
    @IBOutlet var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userID = Auth.auth().currentUser?.uid {
            Database.database().reference()
                .child("users")
                .child(userID)
                .child(noteID)
                .observe(.value, with: { (snapshot) in
                    if let note = snapshot.value as? [String: String] {
                        self.title = note["title"]
                        if let html = self.loadFile(url: self.htmlURL),
                            let markdown = self.loadFile(url: self.markdownURL) {
                            let innerContent = String (
                                format: markdown,
                                note["title"] ?? "",
                                note["date"] ?? "",
                                note["body"] ?? "")
                            if let innerParsed = try? MMMarkdown.htmlString(withMarkdown: innerContent) {
                                let content = String(format: html, innerParsed)
                                self.webview.loadHTMLString(content, baseURL: Bundle.main.bundleURL)
                            }
                        }
                    }
            })
        }
    }
    
    func loadFile (url: URL) -> String? {
        return try? String(
            contentsOf: url,
            encoding: String.Encoding.utf8)
    }

    @IBAction func onEditPressed(_ sender: UIBarButtonItem) {
        delegate.editNote(withID: noteID)
    }
    
    @IBAction func onDeletePressed(_ sender: UIBarButtonItem) {
        delegate.deleteNote(withID: noteID) {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
