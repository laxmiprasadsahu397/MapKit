//
//  MapVC.swift
//  MapKitTask
//
//  Created by LaxmiPrasad Sahu on 27/03/19.
//  Copyright © 2019 C1X. All rights reserved.
//

import UIKit
import MapKit


class MapVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lbl_distance: UILabel!
    let regionRadius: CLLocationDistance = 100
    let locationManager = CLLocationManager()
    var customAnnotation: [CustomAnnotation] = []
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)

        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            let route = response.routes[0]
            self.lbl_distance.text = "Distance: \(route.distance * 0.001)km"
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }

}
extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        if let location = locations.last{
            currentLocation = location
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            let location1 = CLLocationCoordinate2D(latitude: location.coordinate.latitude + 0.001, longitude: location.coordinate.longitude)
            let location2 = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude + 0.001)
            
            self.setAddress(location: center) { (name, cityName, areaName) in
               
                self.mapView.addAnnotation(CustomAnnotation(title: name, locationName: cityName, area: areaName , coordinate: center))
            }
            self.setAddress(location: location1) { (name, cityName, areaName) in
               
                self.mapView.addAnnotation(CustomAnnotation(title: name, locationName: cityName, area: areaName , coordinate: location1))
            }
            self.setAddress(location: location2) { (name, cityName, areaName) in
                self.mapView.addAnnotation(CustomAnnotation(title: name, locationName: cityName, area: areaName , coordinate: location2))
            }
            self.mapView.setRegion(region, animated: true)
            self.showRouteOnMap(pickupCoordinate: center, destinationCoordinate: location1)
            self.showRouteOnMap(pickupCoordinate: center, destinationCoordinate: location2)
        }
    }
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomAnnotation else { return nil }
    
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! CustomAnnotation
        guard let current = self.currentLocation else { return  }
        self.showRouteOnMap(pickupCoordinate: current.coordinate, destinationCoordinate: location.coordinate)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    func setAddress(location: CLLocationCoordinate2D, completionHandler: @escaping (_ name: String, _ cityname: String , _ areaName: String) -> Void) {
        let geoCoder = CLGeocoder()
        let local = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geoCoder.reverseGeocodeLocation(local, completionHandler: {  placemarks, error -> Void in
            
            var name: String?
            var cityname: String?
            var areaName: String?
                guard let placeMark = placemarks?.first else {
                    print("fhkghj")
                    return }
                if let locationName = placeMark.name {
                    name = locationName
                }
                if let city = placeMark.subAdministrativeArea {
                    cityname = city
                }
                if let area = placeMark.locality {
                    areaName = area
                }
            completionHandler(name ?? "", cityname ?? "", areaName ?? "")
            
        })

    }
    
}


