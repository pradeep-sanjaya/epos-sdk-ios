import UIKit

class IndicatorView: UIView {
    
    // MARK: - Properties
    
    private var indicator: UIActivityIndicatorView?
    
    // MARK: - Method
    
    deinit {
        hide()
    }
    
    func show(baseView: UIView?) {
        guard let baseView = baseView, self.indicator == nil else {
            return
        }
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.frame = CGRect(x: 0, y: 0, width: baseView.bounds.size.width, height: baseView.bounds.size.height)
        self.isHidden = false
        baseView.addSubview(self)
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.indicator = indicator
        indicator.bounds = CGRect(x: 0, y: 0, width: 36, height: 36)
        indicator.center = baseView.center
        indicator.hidesWhenStopped = true
        self.addSubview(indicator)
        
        indicator.startAnimating()
    }
    
    func hide() {
        guard let indcator = self.indicator else {
            return
        }
        
        indcator.stopAnimating()
        self.removeFromSuperview()
        self.indicator = nil
    }
}
