import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var followButton: UIButton!

    // MARK: LifeCycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideActivity()
    }

    // MARK: Show / Hide

    func showActivity() {
        shareButton.isHidden = true
        followButton.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideActivity() {
        shareButton.isHidden = false
        followButton.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    // MARK: Button Responders

    @IBAction func didPressShareButton(_ sender: UIButton) {
        showActivity()
        WebServices.create(
            success: { [weak self] session in
                let share = ShareViewController(session: session)
                self?.navigationController?.pushViewController(share, animated: true)
            },
            failure: { [weak self] error in
                self?.alert(title: "Failed", message: "\(error)", then: {})
                self?.hideActivity()
            }
        )
    }

    @IBAction func didPressFollowButton(_ sender: UIButton) {
        let sessionEntryVC = SessionEntryViewController()
        navigationController?.pushViewController(sessionEntryVC, animated: true)
    }
}


