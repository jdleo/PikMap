//
//  Constants.swift
//  PikMap
//
//  Created by John Leonardo on 8/30/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

let storage = FIRStorage.storage()
let storageRef = storage.reference(forURL: "gs://pikmap-f133c.appspot.com")

let aC = UIAlertController(title: "Oops", message: "You don't have a caption :(", preferredStyle: .alert)

let aC1 = UIAlertController(title: "Oops", message: "You didn't select a picture", preferredStyle: .alert)

let okAction = UIAlertAction(title:"K", style: .cancel)


