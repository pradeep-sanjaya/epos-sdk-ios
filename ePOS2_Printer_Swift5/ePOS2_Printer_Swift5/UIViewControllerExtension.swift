import UIKit

extension UIViewController {
    public func showIndicator(_ msg: String?) {
        if msg == nil {
            return
        }
        OperationQueue.main.addOperation({ [self] in
            let alertController = UIAlertController(title: "", message: msg, preferredStyle: .alert)
            let view = UIActivityIndicatorView(style: .gray)
            view.center = CGPoint(x: 60, y: 30)
            alertController.view.addSubview(view)
            view.startAnimating()
            present(alertController, animated: true)
            view.setNeedsDisplay()
        })
    }
    public func hideIndicator() {
        OperationQueue.main.addOperation({ [self] in
            dismiss(animated: true)
            view.setNeedsDisplay()
        })
    }
}

