import UIKit
import MapKit

class ShareViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MARK: Variables

    let session: TrackingSession
    let locationManager = CLLocationManager()

    // MARK: View Attributes

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sessionButton: UIButton!

    // MARK: Initializers

    init(session: TrackingSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SHARING"
        sessionButton.setTitle(session.id, for: .normal)

        let close = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(didPressCloseButton(_:))
        )
        navigationItem.leftBarButtonItem = close

        mapView.delegate = self
        locationManager.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }

    // MARK: Tracking
    
    func startTracking() {
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
    }

    // MARK: Button Responders

    @IBAction func didPressSessionButton(_ sender: UIButton) {
        let activityViewController = UIActivityViewController(
            activityItems: [
                "I've like to share my location: \n\n \(session.id)"
            ],
            applicationActivities: nil
        )
        present(activityViewController, animated: true, completion: nil)
    }


    @objc func didPressCloseButton(_ sender: UIButton) {
        WebServices.close(session) { [weak self] success in
            print("Closed session")
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }

    // MARK: MKMapViewDelegate

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let location = Location(latitude: latitude, longitude: longitude)
        WebServices.update(location, for: session) { success in
            if success {
                print("... updated location")
            } else {
                print("... location update FAILED")
            }
        }
    }

    // MARK: CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorizationStatus()
    }

    // MARK: Location Authorization

    func checkLocationAuthorizationStatus() {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            startTracking()
        } else if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationFail()
        }
    }

    func locationFail() {
        alert(
            title: "Location Required",
            message: "We don't have location permissions, reinstall app, or update in settings.",
            then: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        )
    }
}
