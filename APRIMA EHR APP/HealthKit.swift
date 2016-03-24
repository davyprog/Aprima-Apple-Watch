//
//  HealthKit.swift
//  APRIMA EHR APP
//
//  Created by macOS on 2/21/16.
//  Copyright © 2016 david nguyen. All rights reserved.
// This class serves to authorize usage of the health kit

import Foundation
import HealthKit

// global variable to use anywhere so other view controllers can tell if user authorized health kit or not
// Make sure to check Authorized.enabled == true before pulling data.
struct Authorized{
    static var enabled = false
}

class HealthKit{
    // Create instance of health kit store
    let hk_store:HKHealthStore = HKHealthStore()
    
    //Lets user authorize the app to use health kit. returns if authorization was successful
    func authorize() -> Bool{
        
        var is_enabled = true
        
        // Array for types of data we want to read from the healthkit. Incomplete
        let read_hk_types: Set = [HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
                                          HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
                                          HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
                                          HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
                                          HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
                                          HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!]
        
        
        // check it see if healthkit is accessible on this device
        if HKHealthStore.isHealthDataAvailable(){
            // request authorization. no write type
            hk_store.requestAuthorizationToShareTypes(nil, readTypes: read_hk_types) { (success, error) -> Void in
                is_enabled = success
            }
        }else{
            is_enabled = false
        }
        Authorized.enabled = is_enabled
        return is_enabled
    }

    // Gets steps. Still need to define how we want to display this data.
    func getSteps(completion: (Double, NSError?) -> ()){
        // Testing getting steps from yesterday to today. Get yesterday's date by subtracting 24 hours (in secs) from today's date
        // So with yesterday's date as start parameter and today's date as the end parameter to the method below
        // Temporary of course
        let today = NSDate()
        let yesterday = NSDate(timeIntervalSinceNow: -86400.0)
        
        // The type of data being requested
        let type = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        
        // Search predicate will fetch data from now until a day ago for testing purposes for now.
        //let predicate = HKQuery.predicateForSamplesWithStartDate(newDate, endDate: NSDate(), options: .None)
        let predicate = HKQuery.predicateForSamplesWithStartDate(yesterday, endDate: today,options: .None)
        
        // Query to fetch steps
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: nil){ query, results, error in
            var steps: Double = 0.0
            if results?.count > 0{
                for result in results as! [HKQuantitySample]{
                    steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                }
            }
            
            completion(steps, error)
        }
        hk_store.executeQuery(query)
    }
    
    // Gets the user's date of birth
    func getBirthday()-> NSDate{
        var birth_day: NSDate?
        
        do{
            birth_day = try hk_store.dateOfBirth()
        }catch{
            // Throw some kind of error. commented out for now
            //fatalError() <-- Don't uncomment yet cause fatalError will crash the app lol
        }
        return birth_day!
    }
    
    // Get the user's gender/biological sex
    func getSex() -> HKBiologicalSexObject{
        var biological_sex: HKBiologicalSexObject?
        do{
            biological_sex = try hk_store.biologicalSex()
        }catch{
            // Error here
        }
        return biological_sex!
    }
    
    // Get the user's height
    func getHight(){
        
    }
    
    func getBloodType(app_btype: HKBloodTypeObject) -> String
    {
        var bloodType: String
        let bio_btype = app_btype.bloodType
        switch bio_btype.rawValue{
            case 0:
                bloodType = ""
            case 1:
                bloodType = "A+"
            case 2:
                bloodType = "A-"
            case 3:
                bloodType = "B+"
            case 4:
                bloodType = "B-"
            case 5:
                bloodType = "AB+"
            case 6:
                bloodType = "AB-"
            case 7:
                bloodType = "O+"
            case 8:
                bloodType = "O-"
            default:
                bloodType = ""
        }
        return bloodType
    }
    
    //need to do
    func getWeight() -> String
    {
        return HKQuantityTypeIdentifierBodyMass
    }
    
    // Get the ranges of heart rate for each day (low - high) for the past month and display in table view
    func getHeartRate(completion: ([HKSample]?, NSError?) -> ()){
        let calendar = NSCalendar.currentCalendar()
        let today = NSDate()
        let yesterday = NSDate(timeIntervalSinceNow: -86400.0)
        let components = calendar.components([.Year,.Month,.Day], fromDate: today)
        guard let startDate:NSDate = calendar.dateFromComponents(components) else { return }
        let endDate:NSDate? = calendar.dateByAddingUnit(.Day, value: 1, toDate: startDate, options: [])
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        // Create a heart rate BPM sample
        let heart_rate_type = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        let heart_rate_quantity = HKQuantity(unit: HKUnit(fromString: "count/min"),
                                           doubleValue: Double(arc4random_uniform(80) + 100))
        let heart_sample = HKQuantitySample(type: heart_rate_type,
                                           quantity: heart_rate_quantity, startDate: NSDate(), endDate: NSDate())
        var heart_rate_query:HKSampleQuery?

        
        heart_rate_query = HKSampleQuery(sampleType: heart_rate_type,
                                       predicate: predicate,
                                       limit: 25,
                                       sortDescriptors: nil)
        { (query:HKSampleQuery, results:[HKSample]?, error:NSError?) -> Void in
            
            guard error == nil else { print("error"); return }
            
            //self.printHeartRateInfo(results)
            
            completion(results, error)
            
        }
        hk_store.executeQuery(heart_rate_query!)
    }

}