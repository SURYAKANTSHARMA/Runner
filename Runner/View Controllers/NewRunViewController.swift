
import UIKit
import CoreLocation

class NewRunViewController: UIViewController {
  
  @IBOutlet weak var launchPromptStackView: UIStackView!
  @IBOutlet weak var dataStackView: UIStackView!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
  private var run: Run?
  private let locationManager = LocationManager.shared
  private var seconds = 0
  private var timer: Timer?
  private var distance = Measurement(value: 0, unit: UnitLength.meters)
  private var locationList: [CLLocation] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    dataStackView.isHidden = true
  }
  
  private func startLocationUpdates() {
    locationManager.delegate = self
    locationManager.activityType = .fitness
    locationManager.distanceFilter = 10
    locationManager.startUpdatingLocation()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    timer?.invalidate()
    locationManager.stopUpdatingLocation()
  }

  
  @IBAction func startTapped() {
    startRun()
  }
  
  @IBAction func stopTapped() {
    let alertController = UIAlertController(title: "End run?",
                                            message: "Do you wish to end your run?",
                                            preferredStyle: .actionSheet)
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
      self.stopRun()
      self.saveRun()
      self.performSegue(withIdentifier: .details, sender: nil)
    })
    alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
      self.stopRun()
      _ = self.navigationController?.popToRootViewController(animated: true)
    })
    
    present(alertController, animated: true)

  }
  private func startRun() {
    launchPromptStackView.isHidden = true
    dataStackView.isHidden = false
    startButton.isHidden = true
    stopButton.isHidden = false
    seconds = 0
    distance = Measurement(value: 0, unit: UnitLength.meters)
    locationList.removeAll()
    updateDisplay()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      self.eachSecond()
    }
    startLocationUpdates()
  }
  
  private func stopRun() {
    launchPromptStackView.isHidden = false
    dataStackView.isHidden = true
    startButton.isHidden = false
    stopButton.isHidden = true
    locationManager.stopUpdatingLocation()
  }
  
  func eachSecond() {
    seconds += 1
    updateDisplay()
  }
  
  private func updateDisplay() {
    let formattedDistance = FormatDisplay.distance(distance)
    let formattedTime = FormatDisplay.time(seconds)
    let formattedPace = FormatDisplay.pace(distance: distance,
                                           seconds: seconds,
                                           outputUnit: UnitSpeed.minutesPerMile)
    
    distanceLabel.text = "Distance:  \(formattedDistance)"
    timeLabel.text = "Time:  \(formattedTime)"
    paceLabel.text = "Pace:  \(formattedPace)"
  }
  
  private func saveRun() {
    let newRun = Run(context: CoreDataStack.context)
    newRun.distance = distance.value
    newRun.duration = Int16(seconds)
    newRun.timestamp = Date()
    
    for location in locationList {
      let locationObject = Location(context: CoreDataStack.context)
      locationObject.timestamp = location.timestamp
      locationObject.latitude = location.coordinate.latitude
      locationObject.longitude = location.coordinate.longitude
      newRun.addToLocations(locationObject)
    }
    CoreDataStack.saveContext()
    run = newRun
  }
  
}


// MARK: - SegueHandlerType
extension NewRunViewController: SegueHandlerType {
  enum SegueIdentifier: String {
    case details = "RunDetailsViewController"
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segueIdentifier(for: segue) {
    case .details:
      let destination = segue.destination as! RunDetailsViewController
      destination.run = run
    }
  }
}

// MARK: - CLLocationManagerDelegate
extension NewRunViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for newLocation in locations {
      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
      
      if let lastLocation = locationList.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta, unit: UnitLength.meters)
      }
      
      locationList.append(newLocation)
    }
  }
}

