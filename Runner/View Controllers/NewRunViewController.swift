
import UIKit

class NewRunViewController: UIViewController {
  
  @IBOutlet weak var launchPromptStackView: UIStackView!
  @IBOutlet weak var dataStackView: UIStackView!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
  private var run: Run?
  override func viewDidLoad() {
    super.viewDidLoad()
    dataStackView.isHidden = true
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
  }
  
  private func stopRun() {
    launchPromptStackView.isHidden = false
    dataStackView.isHidden = true
    startButton.isHidden = false
    stopButton.isHidden = true
  }

}

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
