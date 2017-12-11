import UIKit

extension UIViewController {
    func alert(
        title: String,
        message: String = "",
        then completion: @escaping () -> Void = {}
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in completion() }
        )
        alertController.addAction(ok)

        present(alertController, animated: true, completion: nil)
    }
}
