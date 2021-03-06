//
//  BodyFatPercentageBarChartViewController.swift
//  APRIMA EHR APP
//
//  Created by henry dinh on 4/21/16.
//  Copyright © 2016 david nguyen. All rights reserved.
//

import UIKit
import Charts
import HealthKit

class BodyFatPercentageBarChartViewController: UIViewController, ChartViewDelegate {
    
    // Chart stuff
    @IBOutlet weak var bar_chart_view: BarChartView!
    var dates = [String]()
    var values = [Double]()
    
    // Used to refresh data
    var refresh_control = UIRefreshControl()
    let is_health_kit_enabled = NSUserDefaults.standardUserDefaults().boolForKey("is_health_kit_enabled")
    
    // initialize a HealthKit object to pull data from
    let health_kit: HealthKit = HealthKit()
    
    // Array of samples pulled from HealhKit
    var body_fat_percentages = [HKSample]()
    
    let limit = 25
    
    // Refreshes the UI
    func refreshUI(){
        // Make sure the user authorized health kit before attempting to pull data
        if self.is_health_kit_enabled == true{
            let start_date = NSDate.distantPast()
            setUpBodyFatPercentages(start_date)
            if(self.dates.count > 0 && self.values.count > 0){
                self.setChart(self.dates, values: self.values)
            }
        }
    }
    
    
    // Sets up the array of HeartRate objects to display as table cells
    func setUpBodyFatPercentages(start_date: NSDate){
        // First clear array to make sure it's empty
        self.dates.removeAll()
        self.values.removeAll()
        
        self.health_kit.getBodyFatPercentage(self.limit, start_date: start_date){ body_fat_percentages, error in
            self.body_fat_percentages = body_fat_percentages
        }
        let body_fat_percentage_unit:HKUnit = HKUnit(fromString: "%")
        // Format date to make it readable
        let date_formatter = NSDateFormatter()
        date_formatter.dateFormat = "MMM dd, yyyy hh:mm a"
        for h in self.body_fat_percentages as! [HKQuantitySample]{
            self.dates.append(date_formatter.stringFromDate(h.endDate))
            self.values.append(h.quantity.doubleValueForUnit(body_fat_percentage_unit))
        }
    }
    
    
    
    func setChart(data_points: [String], values: [Double]){
        self.bar_chart_view.noDataTextDescription = "No health data available."
        
        var data_entries: [BarChartDataEntry] = []
        
        // Set data points in chart
        for i in 0..<data_points.count {
            let data_entry = BarChartDataEntry(value: values[i], xIndex: i)
            data_entries.append(data_entry)
        }
        
        let chart_data_set = BarChartDataSet(yVals: data_entries, label: "%")
        let chart_data = BarChartData(xVals: self.dates, dataSet: chart_data_set)
        chart_data_set.colors = [UIColor(red: 25.0/255, green: 150.0/255, blue: 197.0/255, alpha: 1)]
        self.bar_chart_view.data = chart_data
        
        // Set other chart properties
        self.bar_chart_view.descriptionText = ""
        
        self.bar_chart_view.xAxis.labelFont = UIFont(name: "Helvetica Neue", size: 0.0)!
        self.bar_chart_view.rightAxis.enabled = false
        self.bar_chart_view.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        // Set up what happens when user selects a value inside the chart
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.bar_chart_view.delegate = self
        
        
        self.refreshUI()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        refreshUI()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
