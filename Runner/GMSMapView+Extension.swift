//
//  GMSMapView+Extension.swift
//  FabU
//
//  Created by Cl-macmini-100 on 5/2/17.
//  Copyright © 2017 Aditya Aggarwal. All rights reserved.


import Foundation
import GoogleMaps

let kPadding: CGFloat = 115

extension GMSMapView {
  
  func drawPath(_ encodedPathString: String) {
    CATransaction.begin()
    CATransaction.setValue(NSNumber(value: 1), forKey: kCATransactionAnimationDuration)
    let path = GMSPath(fromEncodedPath: encodedPathString)
    guard let _path = path else { return }
    //adjust map to view all markers
    let bounds = GMSCoordinateBounds(path: _path)
    animate(with: GMSCameraUpdate.fit(bounds, withPadding: kPadding))
    let redYellow =
      GMSStrokeStyle.gradient(from: .red, to: .yellow)
    let line = GMSPolyline(path: path)
    line.strokeWidth = 4.0
    line.spans = [GMSStyleSpan(style: redYellow)]
    line.isTappable = true
    line.map = self
    CATransaction.commit()
  }
  
  func updateMap(toLocation location: CLLocation, zoomLevel: Float? = nil) {
        if let zoomLevel = zoomLevel {
            let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate, zoom: zoomLevel)
            animate(with: cameraUpdate)
        } else {
            animate(toLocation: location.coordinate)
        }
    }
  
}
