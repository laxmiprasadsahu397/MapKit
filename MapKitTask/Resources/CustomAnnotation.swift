//
//  CustomAnnotation.swift
//  MapKitTask
//
//  Created by LaxmiPrasad Sahu on 27/03/19.
//  Copyright © 2019 C1X. All rights reserved.
//

import MapKit
import Contacts

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let title: String?
    let locationName: String
    let area: String
    
    init(title: String, locationName: String, area: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.area = area
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }

}
