import UIKit

class AlertUtility {

    static func alert(title: String, message: String, buttonTitle: String, currentViewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        
        currentViewController.present(alert, animated: true, completion: nil)
    }
    
    static func localizableAlert(title: String, message: String, buttonTitle: String, currentViewController: UIViewController) {
        alert(title: NSLocalizedString(title, comment: ""),
              message: NSLocalizedString(message, comment: ""),
              buttonTitle: NSLocalizedString(buttonTitle, comment: ""),
              currentViewController: currentViewController)
    }
}
