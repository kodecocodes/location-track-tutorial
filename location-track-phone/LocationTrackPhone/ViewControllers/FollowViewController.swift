import UIKit
import MapKit

class FollowViewController: UIViewController {

    // MARK: Variables

    let session: TrackingSession
    var socket: WebSocket?

    // MARK: View Attributes

    let annotation = MKPointAnnotation()
    @IBOutlet weak var mapView: MKMapView!

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
        mapView.addAnnotation(annotation)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSocket()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        socket?.close()
    }

    // MARK: Updates

    func startSocket() {
        let ws = WebSocket("ws://\(host)/listen/\(session.id)")

        ws.event.close = { [weak self] code, reason, clean in
            self?.navigationController?.popToRootViewController(animated: true)
        }

        ws.event.message = { [weak self] message in
            guard let bytes = message as? [UInt8] else { fatalError("// TODO: ") }
            let data = Data(bytes: bytes)
            let decoder = JSONDecoder()
            do {
                let location = try decoder.decode(
                    Location.self,
                    from: data
                )
                self?.focusMapView(location: location)
            } catch {
            }
        }
    }

    func focusMapView(location: Location) {
        let mapCenter = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        annotation.coordinate = mapCenter
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(mapCenter, span)
        mapView.region = region
    }
}
