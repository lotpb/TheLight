//
//  Utilities.swift
//  Geotify
//
//  Created by Ken Toh on 3/3/15.
//  Copyright (c) 2015 Ken Toh. All rights reserved.
//

import UIKit
import MapKit

// MARK: Helper Extensions
extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension MKMapView {
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
        setRegion(region, animated: true)
    }
}
