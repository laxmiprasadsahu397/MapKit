//
//  AnnotationView.swift
//  MapKitTask
//
//  Created by LaxmiPrasad Sahu on 27/03/19.
//  Copyright © 2019 C1X. All rights reserved.
//

import UIKit
import MapKit

class AnnotationView: MKAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            guard let artwork = newValue as? CustomAnnotation else {return}
            
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            
            let detailLabel = UILabel()
            detailLabel.numberOfLines = 0
            detailLabel.font = detailLabel.font.withSize(12)
            detailLabel.text = artwork.subtitle
            detailCalloutAccessoryView = detailLabel
        }
    }

}
