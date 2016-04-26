//
//  Alert.swift
//  MailCore
//
//  Created by Adam Cmiel on 4/5/16.
//  Copyright © 2016 Adam Cmiel. All rights reserved.
//

import UIKit

private typealias CB = (Void -> Void)?

func poorNetworkAlert(sender: UIViewController, completionHandler: (Void->Void)?) {
    let defaultMessage = "Poor network connection"
    recoverableErrorAlert(defaultMessage, sender: sender, completionHandler: completionHandler)
}

func recoverableErrorAlert(message: String, sender: UIViewController, completionHandler: (Void -> Void)?) {
    let alertController = recoverableErrorAlert(message, completionHandler: completionHandler)
    sender.presentViewController(alertController, animated: true, completion: nil)
}

func recoverableErrorAlert(message: String, completionHandler: (Void -> Void)?) -> UIAlertController {
    let alertTitle = "Error"
    
    let alertController = UIAlertController(title: alertTitle, message: message, preferredStyle: .Alert)
    
    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
        completionHandler?()
    }
    
    alertController.addAction(OKAction)
    return alertController
}