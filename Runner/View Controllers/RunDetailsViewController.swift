
import UIKit
import GoogleMaps
import CoreLocation

typealias JSON = [String: Any]
typealias JSONArray = [JSON]

class RunDetailsViewController: UIViewController {
  

  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
  var run: Run!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
    drawPathOnMap()
  }
  
  private func drawPathOnMap() {
    guard
      let locations = run.locations,
      locations.count > 0
      else {
        return
    }
    
    let latitudes = locations.map { location -> Double in
      let location = location as! Location
      return location.latitude
    }

    let longitudes = locations.map { location -> Double in
      let location = location as! Location
      return location.longitude
    }
    
    
    let _locations = locations.map { location -> CLLocation in
      let location = location as! Location
      return CLLocation(latitude: location.latitude, longitude: location.longitude)
    }
    
    let maxLat = latitudes.max()!
    let minLat = latitudes.min()!
    let maxLong = longitudes.max()!
    let minLong = longitudes.min()!
    
     let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: minLat, longitude: minLong), coordinate: CLLocationCoordinate2D(latitude: maxLat, longitude: maxLong))
     mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: kPadding))
     mapView.animate(toViewingAngle: 30)
     let path = GMSMutablePath()
     for location in _locations {
      path.addLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude)
     }
    
    
    let polyLine = GMSPolyline()
    polyLine.path = path
    polyLine.strokeWidth = 2.0
    let redYellow =
      GMSStrokeStyle.gradient(from: .red, to: .yellow)
    polyLine.spans = [GMSStyleSpan(style: redYellow)]
    polyLine.map = mapView
  
  }
  
  private func configureView() {
    let distance = Measurement(value: run.distance, unit: UnitLength.meters)
    let seconds = Int(run.duration)
    let formattedDistance = FormatDisplay.distance(distance)
    let formattedDate = FormatDisplay.date(run.timestamp)
    let formattedTime = FormatDisplay.time(seconds)
    let formattedPace = FormatDisplay.pace(distance: distance,
                                           seconds: seconds,
                                           outputUnit: UnitSpeed.minutesPerMile)
    
    distanceLabel.text = "Distance:  \(formattedDistance)"
    dateLabel.text = formattedDate
    timeLabel.text = "Time:  \(formattedTime)"
    paceLabel.text = "Pace:  \(formattedPace)"
  }
}


