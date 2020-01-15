//
//  ViewController.swift
//  759831_labAssignment1
//
//  Created by Evneet kaur on 2020-01-14.
//  Copyright © 2020 Evneet kaur. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    

    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var destination :CLLocationCoordinate2D?
    var pressed = false
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tapgesture.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tapgesture)
        
        
    }
    
    @objc func doubleTapped(gesture: UIGestureRecognizer) {
        
        let alloverlays = mapView.overlays
        
        if alloverlays.count>0{
            mapView.removeOverlays(alloverlays)
        }
        
        count += 1
        pressed = true
        
        let allannotations = mapView.annotations

                      if allannotations.count > 1{
                          let ann = allannotations[1]
                          mapView.removeAnnotation(ann)
                      }
        
        let touchPoint = gesture.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        destination = coordinate
        
        
    }
    
    @IBAction func showDirectionButton(_ sender: UIButton) {
        
        
       if pressed{
        
                let alert = UIAlertController(title: "Preferences", message: "Select transport type", preferredStyle:.actionSheet )
                let auto = UIAlertAction(title: "Automobile", style: .default) { (action) in
                    self.showDirection(transport: .automobile)
                }
                let walk = UIAlertAction(title: "Walk", style: .default) { (action) in
                    self.showDirection(transport: .walking)
                }
                alert.addAction(auto)
                alert.addAction(walk)
                self.present(alert, animated: true, completion: nil)
            
        }else{
            let alert = UIAlertController(title: "location missing", message: " please select a location", preferredStyle:.actionSheet )
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
       
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        print("renderer")
        
    
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 4.0
                   
                       return renderer
        
    }
    
    func showDirection(transport: MKDirectionsTransportType) {
         
               print("inside button")
               
               let source = mapView.annotations[0].coordinate

                       
                       let sourceplacemark = MKPlacemark(coordinate: source)
                       let destinationplacemark = MKPlacemark(coordinate: destination!)
                       
                       let sourceMapItem = MKMapItem(placemark: sourceplacemark)
                       let destinationMapItem = MKMapItem(placemark: destinationplacemark)

                       
                       let directionRequest = MKDirections.Request()
                       directionRequest.source = sourceMapItem
                       directionRequest.destination = destinationMapItem
                       directionRequest.transportType = transport
               
               print("after direction")
                       
                       let directions = MKDirections(request: directionRequest)
                       
                       directions.calculate { (response, error) in
                           guard let response = response else{
                               if let error = error{
                                let alert = UIAlertController(title: "OOPS", message: "Directions not available", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                                   print("Error: \(error)")
                               }
                               return
                           }
                           
                           print("in calculate")
                           
                           let route = response.routes[0]
                        self.mapView.addOverlay((route.polyline))
//                           self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
                           print("add overlay")
                           
                           let rect = route.polyline.boundingMapRect
                           self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                           print("set region")
                       
                       }
    }
    
    
   
    @IBAction func zoomIN(_ sender: UIButton) {
        
        var zoomRegion = mapView.region
        zoomRegion.span.latitudeDelta = zoomRegion.span.latitudeDelta/2
        zoomRegion.span.longitudeDelta = zoomRegion.span.longitudeDelta/2
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    
    @IBAction func zoomOUT(_ sender: UIButton) {
        
        var zoomRegion = mapView.region
        zoomRegion.span.latitudeDelta = zoomRegion.span.latitudeDelta*2
        zoomRegion.span.longitudeDelta = zoomRegion.span.longitudeDelta*2
        mapView.setRegion(zoomRegion, animated: true)
    }
    
}

