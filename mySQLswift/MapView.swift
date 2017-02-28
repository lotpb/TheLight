//
//  MapView.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/7/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapView: UIViewController, MKMapViewDelegate,  CLLocationManagerDelegate {
    
    let celllabel1 = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
    let cellsteps = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var travelTime: UILabel!
    @IBOutlet weak var travelDistance: UILabel!
    @IBOutlet weak var stepView: UITextView!
    @IBOutlet weak var routView: UIView!
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!

    var mapaddress : NSString?
    var mapcity : NSString?
    var mapstate : NSString?
    var mapzip : NSString?
    
    var route: MKRoute!
    var allSteps : String?
    
    var locationManager: CLLocationManager!
    var annotationPoint: MKPointAnnotation!
    
    var activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    var floatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.red
        button.setTitle("+", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0)
        button.addTarget(self, action: #selector(routehideView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: button.titleLabel!.font.familyName , size: 50)
        return button
    }()
    
    var routeviewHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar
        
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(MapView.shareButton))
        navigationItem.rightBarButtonItems = [actionButton]
        
        addActivityIndicator()
        setupForm()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupLocation()
        setupMap()

        let location: String = String(format: "%@ %@ %@ %@", self.mapaddress!, self.mapcity!, self.mapstate!, self.mapzip!)
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) in
            
            if error != nil{
                print("Geocode failed with error: \(error!.localizedDescription)")
            } else if placemarks!.count > 0 {
                let placemark = placemarks![0]
                
                if(self.annotationPoint == nil)
                {
                    self.annotationPoint = MKPointAnnotation()
                    self.annotationPoint.coordinate = placemark.location!.coordinate
                    self.annotationPoint.title = self.mapaddress as String?
                    self.annotationPoint.subtitle = String(format: "%@ %@ %@", self.mapcity!, self.mapstate!, self.mapzip!)
                    self.mapView.addAnnotation(self.annotationPoint)
                }
                self.locationManager.stopUpdatingLocation()
                
                // MARK:  Directions
                
                let request = MKDirectionsRequest()
                
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!), addressDictionary: nil))
                
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude), addressDictionary: nil))
                
                // MARK:  AlternateRoutes
                request.requestsAlternateRoutes = true
                // MARK:  transportType
                request.transportType = .automobile
                
                let directions = MKDirections(request: request)
                
                directions.calculate { [unowned self] response, error in
                    guard let unwrappedResponse = response else { return }
                    
                    for route in unwrappedResponse.routes {
                        self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        self.showRoute(response!)
                        self.hideActivityIndicator()
                    }
                }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupMap() {
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .followWithHeading
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.isRotateEnabled = true
        self.mapView.showsPointsOfInterest = true
        self.mapView.showsCompass = true
        self.mapView.showsScale = true
        //self.mapView.showsBuildings = true
    }
    
    func setupLocation() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func setupForm() {
        self.routView.isHidden = false
        self.stepView.font = cellsteps
        self.stepView.isSelectable = false
        self.allSteps = ""
        self.travelTime.text = ""
        self.travelDistance.text = ""
        self.travelTime.font = celllabel1
        self.travelTime.textColor = .white
        self.travelDistance.textColor = .white
        self.travelDistance.font = celllabel1
        self.routView.backgroundColor = Color.DGrayColor
    }
    
    
    func setupConstraints() {
        mapView.addSubview(floatingButton)
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            routeviewHeight = 350
        } else {
            routeviewHeight = 220
        }
        routView.heightAnchor.constraint(equalToConstant: routeviewHeight).isActive = true
        
        floatingButton.trailingAnchor.constraint( equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        floatingButton.bottomAnchor.constraint( equalTo: mapView.layoutMarginsGuide.bottomAnchor, constant: -40).isActive = true
        floatingButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // MARK: - ActivityIndicator
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: UIScreen.main.bounds)
        activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor(hue: 0/360, saturation: 0/100, brightness: 0/100, alpha: 0.4) //UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha: 1.0)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    
    // MARK: - Routes
    
    func showRoute(_ response: MKDirectionsResponse) {
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        
        let temp:MKRoute = response.routes.first! as MKRoute
        self.route = temp
        self.travelTime.text = String(format:"Time: %0.1f min drive", route.expectedTravelTime/60) as String
        self.travelDistance.text = String(format:"Distance: %0.1f miles", route.distance/1609.344) as String
        self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
        
        for i in 0 ..< self.route.steps.count {
            
            let step:MKRouteStep = self.route.steps[i] as MKRouteStep
            let newStep = (step.instructions)
            let distStep = String(format:"%0.2f miles", step.distance/1609.344)
            self.allSteps = self.allSteps!.appending( "\(i+1). ") as String?
            self.allSteps = self.allSteps!.appending(newStep) as String?
            self.allSteps = self.allSteps!.appending("\n") as String?
            self.allSteps = self.allSteps!.appending(distStep) as String?
            self.allSteps = self.allSteps!.appending("\n\n") as String?
            self.stepView.text = self.allSteps
        }
        
        if mapView.overlays.count == 1 {
            mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0), animated: false)
        } else {
            let polylineBoundingRect =  MKMapRectUnion(mapView.visibleMapRect, route.polyline.boundingMapRect)
            mapView.setVisibleMapRect(polylineBoundingRect, edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0), animated: false)
        }
    }
    
    // MARK: - Map Annotation
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) { //added blue circle userlocation
        return nil
        }
        
        let annotationView = MKPinAnnotationView()
        annotationView.pinTintColor = .red
        annotationView.isDraggable = true
        annotationView.canShowCallout = true
        annotationView.animatesDrop = true
        return annotationView
    }
    
    // MARK: - Map Overlay
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
            
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            if mapView.overlays.count == 1 {
                renderer.strokeColor = UIColor.blue.withAlphaComponent(0.75)
            } else if mapView.overlays.count == 2 {
                renderer.strokeColor = UIColor.orange.withAlphaComponent(0.75)
            } else if mapView.overlays.count == 3 {
                renderer.strokeColor = UIColor.red.withAlphaComponent(0.75)
            }
            renderer.lineWidth = 3
            return renderer
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(polygon: overlay as! MKPolygon)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    // MARK: - SegmentedControl

    @IBAction func mapTypeChanged(_ sender: AnyObject) {
        
        if(mapTypeSegmentedControl.selectedSegmentIndex == 0) {
            self.mapView.mapType = MKMapType.standard
        }
        else if(mapTypeSegmentedControl.selectedSegmentIndex == 1) {
            self.mapView.mapType = MKMapType.hybridFlyover
        }
        else if(mapTypeSegmentedControl.selectedSegmentIndex == 2) {
            self.mapView.mapType = MKMapType.satellite
        }
    }
    
    // MARK: - Button
    
    func routehideView(_ sender: AnyObject) {
        
        if self.routView.isHidden == false {
            
            self.routView.isHidden = true
            mapView.bottomAnchor.constraint( equalTo: view.bottomAnchor, constant: 0).isActive = true
        } else {
            self.routView.isHidden = false
            mapView.bottomAnchor.constraint( equalTo: view.bottomAnchor, constant: -routeviewHeight).isActive = true
        }
    }
    
    func trafficBtnTapped(_ sender: AnyObject) {
        
        if mapView.showsTraffic == mapView.showsTraffic {
            mapView.showsTraffic = !mapView.showsTraffic
            //sender.setTitle("Hide Traffic", for: .normal)
        } else {
            mapView.showsTraffic = mapView.showsTraffic
            //sender.setTitle("Show Traffic", for: .normal)
        }
    }
    
    func scaleBtnTapped() {
        
        if mapView.showsScale == mapView.showsScale {
            mapView.showsScale = !mapView.showsScale
        } else {
            mapView.showsScale = !mapView.showsScale
        }
    }
    
    func compassBtnTapped() {
        
        if mapView.showsCompass == mapView.showsCompass {
            mapView.showsCompass = !mapView.showsCompass
        } else {
            mapView.showsCompass = mapView.showsCompass
        }
    }
    
    func buildingBtnTapped() {
        
        if mapView.showsBuildings == mapView.showsBuildings {
            mapView.showsBuildings = !mapView.showsBuildings
        } else {
            mapView.showsBuildings = mapView.showsBuildings
        }
    }
    
    func userlocationBtnTapped() {
        
        if mapView.showsUserLocation == mapView.showsUserLocation {
            mapView.showsUserLocation = !mapView.showsUserLocation
        } else {
            mapView.showsUserLocation = mapView.showsUserLocation
        }
    }
    
    func pointsofinterestBtnTapped() {
        
        if mapView.showsPointsOfInterest == mapView.showsPointsOfInterest {
            mapView.showsPointsOfInterest = !mapView.showsPointsOfInterest
        } else {
            mapView.showsPointsOfInterest = mapView.showsPointsOfInterest
        }
    }
    
    func requestsAlternateRoutesBtnTapped() {
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.7127, longitude: -74.0059), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.783333, longitude: -122.416667), addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.add(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func displayInFlyoverMode() {
        
        if mapView.mapType == .satelliteFlyover {
            mapView.mapType = .standard
        } else {
            mapView.mapType = .satelliteFlyover
            mapView.showsBuildings = true
            let location = CLLocationCoordinate2D(latitude: 51.50722, longitude: -0.12750)
            let altitude: CLLocationDistance  = 500
            let heading: CLLocationDirection = 90
            let pitch = CGFloat(45)
            let camera = MKMapCamera(lookingAtCenter: location, fromDistance: altitude, pitch: pitch, heading: heading)
            mapView.setCamera(camera, animated: true)
        }
    }
    
    func shareButton(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title:"", message:"", preferredStyle: .actionSheet)
        
        let buttonOne = UIAlertAction(title: "Show Traffic", style: .default, handler: { (action) in
            self.trafficBtnTapped(self)
        })
        let buttonTwo = UIAlertAction(title: "Show Scale", style: .default, handler: { (action) in
            self.scaleBtnTapped()
        })
        let buttonThree = UIAlertAction(title: "Show Compass", style: .default, handler: { (action) in
            self.compassBtnTapped()
        })
        let buttonFour = UIAlertAction(title: "Show Buildings", style: .default, handler: { (action) in
            self.buildingBtnTapped()
        })
        let buttonFive = UIAlertAction(title: "Show User Location", style: .default, handler: { (action) in
            self.userlocationBtnTapped()
        })
        let buttonSix = UIAlertAction(title: "Show Points of Interest", style: .default, handler: { (action) in
            self.pointsofinterestBtnTapped()
        })
        let buttonSeven = UIAlertAction(title: "Alternate Routes", style: .default, handler: { (action) in
            self.requestsAlternateRoutesBtnTapped()
        })
        let buttonEight = UIAlertAction(title: "Show Flyover", style: .default, handler: { (action) in
            self.displayInFlyoverMode()
        })

        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        alertController.addAction(buttonOne)
        alertController.addAction(buttonTwo)
        alertController.addAction(buttonThree)
        alertController.addAction(buttonFour)
        alertController.addAction(buttonFive)
        alertController.addAction(buttonSix)
        alertController.addAction(buttonSeven)
        alertController.addAction(buttonEight)
        alertController.addAction(buttonCancel)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        self.present(alertController, animated: true, completion: nil)
    }

}
