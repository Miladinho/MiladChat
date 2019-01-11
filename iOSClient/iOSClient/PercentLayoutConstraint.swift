// From: http://basememara.com/percentage-based-margin-using-autolayout-storyboard/
// May God bless his/her soul LOL

import UIKit

/// Layout constraint to calculate size based on multiplier.
class PercentLayoutConstraint: NSLayoutConstraint {
    
    @IBInspectable var marginPercent: CGFloat = 0
    
    var screenSize: (width: CGFloat, height: CGFloat) {
        return (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard marginPercent > 0 else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(layoutDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        // UIDevice.orientationDidChangeNotification
    }
    
    /**
     Re-calculate constant based on orientation and percentage.
     */
    @objc func layoutDidChange() {
        guard marginPercent > 0 else { return }
        
        switch firstAttribute {
        case .top, .topMargin, .bottom, .bottomMargin:
            constant = screenSize.height * marginPercent
        case .leading, .leadingMargin, .trailing, .trailingMargin:
            constant = screenSize.width * marginPercent
        default: break
        }
    }
    
    deinit {
        guard marginPercent > 0 else { return }
        NotificationCenter.default.removeObserver(self)
    }
}
