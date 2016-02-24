//
//  SettingsViewController.swift
//  APRIMA EHR APP
//
//  Created by henry dinh on 2/23/16.
//  Copyright © 2016 david nguyen. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    // Create HealthKit object
    let health_kit = HealthKit()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Authorizes HealthKit with user pressing the Authorize HealthKit cell in Settings
    @IBAction func authroizeHealthKit(){
        health_kit.authorize()
    }

}
