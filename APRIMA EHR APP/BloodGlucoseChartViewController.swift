//
//  BloodGlucoseChartViewController.swift
//  APRIMA EHR APP
//
//  Created by david on 4/10/16.
//  Copyright © 2016 david nguyen. All rights reserved.
//

import UIKit
import Charts
import HealthKit
import Foundation

class BloodGlucoseChartViewController: UIViewController {


        let health_kit: HealthKit = HealthKit()
        let is_health_kit_enabled = NSUserDefaults.standardUserDefaults().boolForKey("is_health_kit_enabled")
        
        @IBOutlet weak var barChartView: BarChartView!
        var bloodglucose = [HKSample]()
        var dates = [String]()
    
        let limit = 25
    
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
              
            refreshUI()
            
            
            // Do any additional setup
            //after loading the view.
        }
        
        
        
        override func viewWillAppear(animated: Bool) {
            refreshUI()
        }
        
    func setupChart(start_date: NSDate){
            health_kit.getBloodGlucose(self.limit, start_date: start_date){results, error in
                self.bloodglucose = results
                print("worked")
                print(results.count)
            }
            let bloodGUNIT:HKUnit = HKUnit(fromString: "mg/dL")
            dates = [String]()
            var bloodglucoseCount = [Double]()
            let date_formatter = NSDateFormatter()
            date_formatter.dateFormat = "MMM dd, yyyy hh:mm a"
            for bg in self.bloodglucose as! [HKQuantitySample]{
                bloodglucoseCount.append(bg.quantity.doubleValueForUnit(bloodGUNIT))
                self.dates.append(date_formatter.stringFromDate(bg.endDate))
            }
            print(bloodglucose.count)
            if(bloodglucose.count > 0){
                setChart(dates, values: bloodglucoseCount)
            }
            
        }
        
        func refreshUI(){
            if self.is_health_kit_enabled == true{
                let start_date = NSDate.distantPast()

                setupChart(start_date)
                
            }
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        
        
        func setChart(dataPoints: [String], values: [Double]) {
            barChartView.noDataText = "No health data available."
            
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 0..<dataPoints.count {
                let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "mg/dL")
            let chartData = BarChartData(xVals: dates, dataSet: chartDataSet)
            chartDataSet.colors = [UIColor(red: 25.0/255, green: 150.0/255, blue: 197.0/255, alpha: 1)]
            barChartView.data = chartData
            
            // Set other chart properties
            barChartView.descriptionText = ""
            self.barChartView.xAxis.labelFont = UIFont(name: "Helvetica Neue", size: 0.0)!
            self.barChartView.rightAxis.enabled = false
            self.barChartView.xAxis.labelPosition = .Bottom
            self.barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        }
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
         }
         */
        
}