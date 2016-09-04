//
//  PikController.swift
//  PikMap
//
//  Created by John Leonardo on 8/31/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import UIKit

class PikController: UIViewController {

    @IBOutlet weak var PikImg: UIImageView!
    @IBOutlet weak var PikCaption: UITextView!
    var segId: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PikCaption.text = segId
    }


    @IBAction func goBack(_ sender: AnyObject) {
    
        self.performSegue(withIdentifier: "goBack", sender: self)
    
    }
    
    

}
