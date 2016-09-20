//
//  DetailViewController.swift
//  Neighbors
//
//  Created by Diana Chen on 3/1/16.
//  Copyright © 2016 Pocoa. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    //MARK: Properties

//MARK: Actions
    
//    @IBAction func loginButton(sender: UIButton) {
//        //check username and password
//        //connect to the account
//        if usernameTextField != nil {
//            if passwordTextField != nil {
//                //check password
//                self.performSegueWithIdentifier(loginSegue, sender: <#T##AnyObject?#>)
//            }
//            else
//            {
//                self.messageLabel.text = "
//            }
//        }
//    }

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

