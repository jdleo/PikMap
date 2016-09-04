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
        
        let pathRef = storageRef.child(segId)
        let localURL: NSURL! = NSURL(string: "file:///local/images/\(segId).jpg")
        
        pathRef.metadata { (metadata, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let meta = metadata?.customMetadata
                let caption = meta?["caption"]
                self.PikCaption.text = caption
                
                
                
            }
        }
        
        pathRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                // Data returned and converted to our UImage
                self.PikImg.image = UIImage(data: data!)
            }
        }
        
        
    }


    @IBAction func goBack(_ sender: AnyObject) {
    
        self.performSegue(withIdentifier: "goBack", sender: self)
    
    }
    
    

}
