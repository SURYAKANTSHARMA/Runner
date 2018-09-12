
import UIKit
import GoogleMaps
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
    
    let maxLat = latitudes.max()!
    let minLat = latitudes.min()!
    let maxLong = longitudes.max()!
    let minLong = longitudes.min()!
    
    //mapView.drawPathCoordinates(CLLocation(latitude: minLat, longitude: minLong), endLocation: CLLocation(latitude: maxLat, longitude: maxLong))
    getPolylineRoute(from: CLLocationCoordinate2D(latitude: minLat, longitude: minLong), to: CLLocationCoordinate2D(latitude: maxLat, longitude: maxLong))
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
  
  func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
    
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    
    let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=walking&key=AIzaSyCvk3KZS7-hPjiwLrUnhgloF5DoZpPB08k")!
    print(url)
    let task = session.dataTask(with: url, completionHandler: {
      (data, response, error) in
      if error != nil {
          print(error!.localizedDescription)
      } else {
        do {
          if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
            print(json)
            if let routes = json["routes"] as? JSONArray,
              let overViewPolyLine = routes[0]["overview_polyline"] as? JSON,
              let point = overViewPolyLine["points"] as? String {
              DispatchQueue.main.async {
                self.mapView.drawPath(point)
              }
            }
           }
          
        }catch{
          print("error in JSONSerialization")
        }
      }
    })
    task.resume()
  }
}


