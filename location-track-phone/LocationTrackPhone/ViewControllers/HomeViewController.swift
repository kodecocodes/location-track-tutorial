import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var followButton: UIButton!

    private let echo = WebSocket("ws://\(host)/echo-test")

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEcho()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideActivity()
    }

    // MARK: Echo

    func setupEcho() {
        addEchoButton()
        addEchoListener()
    }

    func addEchoButton() {
        let echoButton = UIBarButtonItem(
            title: "Echo",
            style: .plain,
            target: self,
            action: #selector(didPressEchoButton)
        )

        navigationItem.leftBarButtonItem = echoButton
    }

    func addEchoListener() {
        echo.event.message = { message in
            print("got message: \(message)")
        }
    }

    @objc func didPressEchoButton() {
        let message = "sending echo \(Date().timeIntervalSince1970)"
        print("sending \(message)")
        echo.send(message)
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


