//
//  TableViewController.swift
//  On The Map
//
//  Created by joel johnson on 8/8/17.
//  Copyright © 2017 joel johnson. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Student.studentArray.count}
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studenttablecell", for: indexPath)
        let student = Student.studentArray[indexPath.row]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.imageView?.image = UIImage(named: "pin")
        cell.detailTextLabel?.text = student.mediaURL
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let student = Student.studentArray[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        let app = UIApplication.shared
        if app.canOpenURL(URL(string: student.mediaURL)!){
            app.openURL(URL(string: student.mediaURL)!)
        } else {
            let AlertController = UIAlertController(title: "", message: "Invalid Link", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel) {
                action in AlertController.dismiss(animated: true, completion: nil)
            }
            AlertController.addAction(cancelAction)
            present(AlertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        UdacityNetworkingMethods.sharedInstance().logout(){
            (success) in
            if success {
                print("Logged Out")
                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    
}
