//
//  PikAnnotation.swift
//  PikMap
//
//  Created by John Leonardo on 8/30/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import Foundation
import MapKit

class PikAnnotation: NSObject, MKAnnotation {
    
    var coordinate = CLLocationCoordinate2D()
    var iid: String
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, iid: String) {
        self.coordinate = coordinate
        self.iid = iid
        self.title = "View"
        
        
    }
    
    
}
