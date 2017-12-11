import UIKit

class SessionEntryViewController: UIViewController {

    // MARK: View Attributes
    
    @IBOutlet weak var textField: UITextField!

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let track = UIBarButtonItem(
            title: "Track",
            style: .plain,
            target: self,
            action: #selector(didPressTrackButton)
        )
        navigationItem.rightBarButtonItem = track
    }

    // MARK: Button Responders

    @objc func didPressTrackButton(_ sender: UIBarButtonItem) {
        guard let text = textField.text else { return }
        let session = TrackingSession(id: text)
        let followVC = FollowViewController(session: session)
        navigationController?.pushViewController(followVC, animated: true)
    }
}
