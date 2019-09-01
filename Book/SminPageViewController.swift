import UIKit

class SminPageViewController: UIViewController { //민
    
    
    @IBOutlet weak var poemTextView: UITextView!
    
    var fontSizeReceiver: String = ""
    var fontReceiver: String = ""
    var test: String!
    let defaults = UserDefaults.standard
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(fontSizeApplied(_:)), name: .fontSizeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fontTypeApplied(_:)), name: .fontTypeChanged, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        poemTextView.text = test
        var savedFontType = defaults.object(forKey: "defaultFontType")
        var savedFontSize = defaults.object(forKey: "defaultFontSize")
        
        if let defaultFontType = savedFontType as? String,
            let defaultFontSize = savedFontSize as? String{
            
            poemTextView.font = UIFont(name: defaultFontType, size: CGFloat(NSString(string: defaultFontSize).floatValue))
            
        }
    }
    
    @objc func fontSizeApplied(_ notification: Notification) {
        guard  let fontSizeText : String = notification.userInfo!["fontSizeKey"] as? String else {
            return
        }
        
        self.fontSizeReceiver = fontSizeText
        poemTextView.font = poemTextView.font?.withSize(CGFloat(NSString(string : fontSizeReceiver).floatValue))
        defaults.set(fontSizeReceiver, forKey: "defaultFontSize")
        
    }
    
    @objc func fontTypeApplied(_ notification: Notification) {
        
        guard  let fontTypeText : String = notification.userInfo!["fontTypeKey"] as? String else {
            return
        }
        
        self.fontReceiver = fontTypeText
        let withSize = CGFloat(NSString(string: fontSizeReceiver).floatValue)
        poemTextView.font = UIFont(name: fontReceiver, size: withSize)
        defaults.set(fontReceiver, forKey: "defaultFontType")
        
    }
    
    
}


extension Notification.Name {
    static let fontSizeChanged = Notification.Name("fontSizeChanged")
    static let fontTypeChanged = Notification.Name("fontTypeChanged")
    static let remindTimeChanged = Notification.Name("remindTimeChanged")
}




