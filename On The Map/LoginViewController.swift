//
//  ViewController.swift
//  On The Map
//
//  Created by joel johnson on 8/4/17.
//  Copyright © 2017 joel johnson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func Login(_ sender: Any) {
         if !emailTextField.text!.isEmpty || !passwordTextField.text!.isEmpty {
            UdacityNetworkingMethods.sharedInstance().login(emailTextField.text!, passwordTextField.text!, self){ (success, error) in
            if success {
                print("login successful")
                ParseObject.sharedInstance().getStudentLocations()
                    { (success, error) in
                        if success {
                            print("student locations recieved")
                            DispatchQueue.main.async {
                                self.emailTextField.text = ""
                                self.passwordTextField.text = ""
                                let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapTabBarController") as! UITabBarController
                                self.present(controller, animated: true, completion: nil)
                            }
                        } else {
                            DispatchQueue.main.async{
                            UdacityNetworkingMethods.sharedInstance().showError(self, "Sign in Unsuccessful")
                            }
                        }
                }
                }
            }
        }
        
    }
    
    @IBAction func signUp(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated")!,
                                  options: [:], completionHandler: nil)
    }
}

