//
//  Note.swift
//  Yournal
//
//  Created by Iván Ávalos on 11/16/18.
//  Copyright © 2018 Iván Ávalos. All rights reserved.
//

import Foundation

class Note {
    var uid: String
    var title: String
    var date: String
    var body: String
    
    init(uid: String, title: String, date: String, body: String) {
        self.uid = uid
        self.title = title
        self.date = date
        self.body = body
    }
}
