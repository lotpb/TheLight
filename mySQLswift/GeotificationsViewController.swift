//
//  GeotificationsViewController.swift
//  Geotify
//
//  Created by Ken Toh on 24/1/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications


struct PreferencesKeys {
    static let savedItems = "savedItems"
}

class GeotificationsViewController: UIViewController, RegionsProtocol {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var geotifications: [Geotification] = []
    //var locationManager = CLLocationManager() //Setup AddGeotification
    
    var circle:MKCircle! //setup GetRegion
    
    //var geoNames: [String]?
    
    //Get Address
    var thoroughfare: String?
    var subThoroughfare: String?
    var locality: String?
    var sublocality: String?
    var postalCode: String?
    var administrativeArea: String?
    var subAdministrativeArea: String?
    var country: String?
    var ISOcountryCode: String?
    
    var floatingButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.red
        button.setTitle("+", for: UIControlState.normal)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0)
        button.addTarget(self, action: #selector(maptype), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var locationManager : CLLocationManager = {
        var locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters //kCLLocationAccuracyHundredMeters;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        return locationManager
    }()
    
    func registerNotification() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] (notification) in
            if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                self?.locationManager.stopUpdatingLocation()
                self?.locationManager.startMonitoringSignificantLocationChanges()
            } else {
                // Error: Significant location change monitoring is not available
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: nil) { [weak self](notification) in
            if CLLocationManager.significantLocationChangeMonitoringAvailable() {
                self?.locationManager.stopMonitoringSignificantLocationChanges()
                self?.locationManager.startUpdatingLocation()
            } else {
                // Error: Significant location change monitoring is not available
            }
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    //var monitoredRegions: Dictionary<String, NSDate> = [:] //Setup Eatery
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar
        
        //geoNames: Array<String> = ["Geotify", "Get Region", "Get Address"]
        //segmentedControl? = UISegmentedControl(items: geoNames)
        
        // Setup AddGeotification
        //locationManager.delegate = self
        //locationManager.requestAlwaysAuthorization()
        // Setup GetAddress
        //locationManager.startUpdatingLocation()
        //loadAllGeotifications()
        
        // Setup Eatery
        //locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        mapView.delegate = self //added
        //mapView.showsUserLocation = true //added
        mapView.userTrackingMode = .none //.follow //added
        
        // Float Button
        setupConstraints()
        registerNotification()
    }
    
    deinit {
        locationManager.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       segmentedControl.selectedSegmentIndex = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestAlwaysAuthorization()
        // Setup GetAddress
        locationManager.startUpdatingLocation()
        loadAllGeotifications()
    }
    
    
    func setupConstraints() {
        
        self.view.addSubview(floatingButton)
    
        floatingButton.trailingAnchor.constraint( equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        floatingButton.bottomAnchor.constraint( equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -85).isActive = true
        
        let buttonSize: CGFloat
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            buttonSize = 60
            floatingButton.titleLabel?.font = UIFont(name: floatingButton.titleLabel!.font.familyName , size: buttonSize)
        } else {
            buttonSize = 50
            floatingButton.titleLabel?.font = UIFont(name: floatingButton.titleLabel!.font.familyName , size: buttonSize)
        }
        let widthConstraint = NSLayoutConstraint(item: floatingButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: buttonSize)
        let heightConstraint  = NSLayoutConstraint(item: floatingButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: buttonSize)
        
        view.addConstraints([widthConstraint, heightConstraint])

    }
    
    // MARK: - AddGeotification
    
    func maptype() {
        
        if self.mapView.mapType == MKMapType.standard {
            self.mapView.mapType = MKMapType.hybridFlyover
        } else {
            self.mapView.mapType = MKMapType.standard
        }
        
    }
    
    // MARK: Loading and saving functions
    
    func loadAllGeotifications() {
        geotifications = []
        guard let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) else { return }
        for savedItem in savedItems {
            guard let geotification = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? Geotification else { continue }
            add(geotification: geotification)
        }
    }
    
    func saveAllGeotifications() {
        var items: [Data] = []
        for geotification in geotifications {
            let item = NSKeyedArchiver.archivedData(withRootObject: geotification)
            items.append(item)
        }
        UserDefaults.standard.set(items, forKey: PreferencesKeys.savedItems)
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    func add(geotification: Geotification) {
        geotifications.append(geotification)
        mapView.addAnnotation(geotification)
        addRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func remove(geotification: Geotification) {
        if let indexInArray = geotifications.index(of: geotification) {
            geotifications.remove(at: indexInArray)
        }
        mapView.removeAnnotation(geotification)
        removeRadiusOverlay(forGeotification: geotification)
        updateGeotificationsCount()
    }
    
    func updateGeotificationsCount() {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            title = "TheLight Software - Geotifications (\(geotifications.count))"
        } else {
            title = "Geotifications (\(geotifications.count))"
        }
        navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20)
    }
    
    // MARK: Map overlay functions
    func addRadiusOverlay(forGeotification geotification: Geotification) {
        mapView?.add(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    func removeRadiusOverlay(forGeotification geotification: Geotification) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
                mapView?.remove(circleOverlay)
                break
            }
        }
    }
    
    
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToUserLocation()
    }
    
    
    func region(withGeotification geotification: Geotification) -> CLCircularRegion {
        
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = (geotification.eventType == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region    }
    
    func startMonitoring(geotification: Geotification) {
        
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showAlert(withTitle:"Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
        }
        let region = self.region(withGeotification: geotification)
        locationManager.startMonitoring(for: region)
    }
    
    
    func stopMonitoring(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    
    // MARK: - Get Address Button
    
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            
            thoroughfare = (containsPlacemark.thoroughfare != nil) ? containsPlacemark.thoroughfare : ""
            subThoroughfare = (containsPlacemark.subThoroughfare != nil) ? containsPlacemark.subThoroughfare : ""
            locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            sublocality = (containsPlacemark.subLocality != nil) ? containsPlacemark.subLocality : ""
            postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            subAdministrativeArea = (containsPlacemark.subAdministrativeArea != nil) ? containsPlacemark.subAdministrativeArea : ""
            country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            ISOcountryCode = (containsPlacemark.isoCountryCode != nil) ? containsPlacemark.isoCountryCode : ""
            
        }
    }
    
    // MARK: - SegmentedControl
    
    @IBAction func indexChanged(sender: UISegmentedControl)
    {
        switch segmentedControl.selectedSegmentIndex
        {
         
        case 0: break;
            /*
            self.performSegue(withIdentifier: "geotifySegue", sender: self)
            */
        case 1:
            self.performSegue(withIdentifier: "getregionSegue", sender: self)
            
        case 2:
            self.performSegue(withIdentifier: "getaddressSegue", sender: self)
        default:
            break;
        }
    }

    
    //---------------------------------------------------------------------
    /*
    // MARK: - Setup Eatery
    
    func setupEatery() {
        // check if can monitor regions
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            // region data
            let title = "Balsamo's Eatery"
            let coordinate = CLLocationCoordinate2DMake(40.71347652938283, -73.48204686313261)
            let regionRadius = 300.0
            
            // setup region
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), radius: regionRadius, identifier: title)
            locationManager.startMonitoring(for: region)
            
            // setup annotation
            let restaurantAnnotation = MKPointAnnotation()
            restaurantAnnotation.coordinate = coordinate;
            restaurantAnnotation.title = "\(title)";
            mapView.addAnnotation(restaurantAnnotation)
            
            // setup circle
            let circle = MKCircle(center: coordinate, radius: regionRadius)
            mapView.add(circle)
        }
        else {
            print("System can't track regions")
        }
    }
    
    
    func updateRegionsWithLocation(_ location: CLLocation) {
        
        let regionMaxVisiting = 10.0
        var regionsToDelete: [String] = []
        
        for regionIdentifier in monitoredRegions.keys {
            if Date().timeIntervalSince(monitoredRegions[regionIdentifier]! as Date) > regionMaxVisiting {
                self.simpleAlert(title: "Balsamo's Eatery", message: "Thanks for visiting our restaurant")
                regionsToDelete.append(regionIdentifier)
            }
        }
        
        for regionIdentifier in regionsToDelete {
            monitoredRegions.removeValue(forKey: regionIdentifier)
        }
    }
    */
    /*
    func showAlert(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    } */
    
    //MARK: RegionsProtocol
    
    //setup GetRegion
    func loadOverlayForRegionWithLatitude(_ latitude: Double, andLongitude longitude: Double) {
        
        //1
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //2
        circle = MKCircle(center: coordinates, radius: 200000)
        //3
        self.mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7)), animated: true)
        //4
        self.mapView.add(circle)
    }

    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addGeotification" {
            let navigationController = segue.destination as! UINavigationController
            let vc = navigationController.viewControllers.first as! AddGeotificationViewController
            vc.delegate = self
        }
        
        if segue.identifier == "getaddressSegue" {

            let VC = segue.destination as? GetAddress
            VC!.thoroughfare = self.thoroughfare
            VC!.subThoroughfare = self.subThoroughfare
            VC!.locality = self.locality
            VC!.sublocality = self.sublocality
            VC!.postalCode = self.postalCode
            VC!.administrativeArea = self.administrativeArea
            VC!.subAdministrativeArea = self.subAdministrativeArea
            VC!.country = self.country
            VC!.ISOcountryCode = self.ISOcountryCode
        }
        
        if segue.identifier == "getregionSegue" {
            let regionsController = segue.destination as! RegionsListController
            regionsController.delegate = self
            
        }
    }

}
//---------------------------------------------------------------------

// MARK: - Extensions
//AddGeotification
extension GeotificationsViewController: AddGeotificationsViewControllerDelegate {
    
    func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: EventType) {
        controller.dismiss(animated: true, completion: nil)
        
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
        add(geotification: geotification)
        
        startMonitoring(geotification: geotification)
        saveAllGeotifications()
    }
}

//AddGeotification and GetAddress
extension GeotificationsViewController: CLLocationManagerDelegate {
    
    //AddGeotification
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = status == .authorizedAlways
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    //Get Address Button
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Get Address Button
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                self.simpleAlert(title: "Alert", message: "Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                self.displayLocationInfo(pm)
            } else {
                self.simpleAlert(title: "Alert", message: "Problem with the data received from geocoder")
            }
        })
        //Setup Eatery
        //updateRegionsWithLocation(locations[0])
    }
    
    /*
     //Setup Eatery
     func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
     self.simpleAlert(title: "Enter Balsamo's Eatery", message: "enter \(region.identifier)")
     monitoredRegions[region.identifier] = NSDate()
     }
     
     func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
     self.simpleAlert(title: "Exit Balsamo's Eatery", message: "exit \(region.identifier)")
     monitoredRegions.removeValue(forKey: region.identifier)
     } */
    
    // MARK: - Geotify AddGeotification
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    func handleEvent(forRegion region: CLRegion!) {

        let state: UIApplicationState = UIApplication.shared.applicationState
        
        if state == .background {
            
            let content = UNMutableNotificationContent()
            content.title = "Tutorial Reminder"
            content.body = note(fromRegionIdentifier: region.identifier)!
            content.badge = 1
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "myCategory"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "AddGeotification", content: content, trigger: trigger)
            //UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        else if state == .active {
            
            guard let message = note(fromRegionIdentifier: region.identifier) else { return }
            showAlert(withTitle: nil, message: message)
        }
    }
    
    func note(fromRegionIdentifier identifier: String) -> String? {
        let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) as? [NSData]
        let geotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? Geotification }
        let index = geotifications?.index { $0?.identifier == identifier }
        return index != nil ? geotifications?[index!]?.note : nil
    }
}


//AddGeotification
extension GeotificationsViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myGeotification"
        if annotation is Geotification {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(named: "DeleteGeotification")!, for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.lineWidth = 2.0
            renderer.strokeColor = .blue
            renderer.fillColor = UIColor.orange.withAlphaComponent(0.3) //UIColor.blue.withAlphaComponent(0.4)
            return renderer
        } else if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geotification
        let geotification = view.annotation as! Geotification
        remove(geotification: geotification)
        saveAllGeotifications()
    }
    
}
/*
extension MKMapView {
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
        setRegion(region, animated: true)
    }
} */
