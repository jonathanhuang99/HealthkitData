//
//  ViewController.swift
//  HealthkitData
//
//  Created by Jonathan Huang on 3/4/20.
//  Copyright © 2020 Jonathan Huang. All rights reserved.
//

import UIKit
import HealthKit


enum MyError: Error {case err}

class ViewController: UIViewController {
    
    var healthStore = HKHealthStore()
    
    @IBOutlet weak var weightUnitLabel: UILabel!
    @IBOutlet weak var heightUnitLabel: UILabel!
    
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var distanceUnitLabel: UILabel!
    @IBOutlet weak var stepsValueLabel: UILabel!
    @IBOutlet weak var stepsUnitLabel: UILabel!
    @IBOutlet weak var heightValueLabel: UILabel!
    @IBOutlet weak var weightValueLabel: UILabel!

    
    //MARK: - Reading HealthKit Data
    
    
    func updateUsersHeightLabel() {
        // Fetch user's default height unit in inches.
        let lengthFormatter = LengthFormatter()
        lengthFormatter.unitStyle = Formatter.UnitStyle.long
        
        let heightFormatterUnit = LengthFormatter.Unit.inch
        let heightUnitString = lengthFormatter.unitString(fromValue: 10, unit: heightFormatterUnit)
        let localizedHeightUnitDescriptionFormat = NSLocalizedString("Height (%@)", comment: "")
        
        self.heightUnitLabel.text = String(format: localizedHeightUnitDescriptionFormat, heightUnitString)
        
        let heightType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        
        // Query to get the user's latest height, if it exists.
        self.healthStore.aapl_mostRecentQuantitySampleOfType(heightType, predicate: nil) {mostRecentQuantity, error in
            if mostRecentQuantity == nil {
                NSLog("Either an error occured fetching the user's height information or none has been stored yet. In your app, try to handle this gracefully.")
                
                DispatchQueue.main.async {
                    self.heightValueLabel.text = NSLocalizedString("Not available", comment: "")
                }
            } else {
                // Determine the height in the required unit.
                let heightUnit = HKUnit.inch()
                let usersHeight = mostRecentQuantity!.doubleValue(for: heightUnit)
                
                // Update the user interface.
                DispatchQueue.main.async {
                    self.heightValueLabel.text = NumberFormatter.localizedString(from: usersHeight as NSNumber, number: NumberFormatter.Style.none)
                }
            }
        }
    }
    
    func updateUsersWeightLabel() {
        // Fetch the user's default weight unit in pounds.
        let massFormatter = MassFormatter()
        massFormatter.unitStyle = .long
        
        let weightFormatterUnit = MassFormatter.Unit.pound
        let weightUnitString = massFormatter.unitString(fromValue: 10, unit: weightFormatterUnit)
        let localizedWeightUnitDescriptionFormat = NSLocalizedString("Weight (%@)", comment: "")
        
        self.weightUnitLabel.text = String(format:localizedWeightUnitDescriptionFormat, weightUnitString)
        
        // Query to get the user's latest weight, if it exists.
        let weightType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        
        self.healthStore.aapl_mostRecentQuantitySampleOfType(weightType, predicate: nil) {mostRecentQuantity, error in
            if mostRecentQuantity == nil {
                NSLog("Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully.")
                
                DispatchQueue.main.async {
                    self.weightValueLabel.text = NSLocalizedString("Not available", comment: "")
                }
            } else {
                // Determine the weight in the required unit.
                let weightUnit = HKUnit.pound()
                let usersWeight = mostRecentQuantity!.doubleValue(for: weightUnit)
                
                // Update the user interface.
                DispatchQueue.main.async {
                    self.weightValueLabel.text = NumberFormatter.localizedString(from: usersWeight as NSNumber, number: .none)
                }
            }
        }
    }
    func getDistance(completion: @escaping (Double) -> Void)
    {
        let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        var interval = DateComponents()
        interval.day = 1
        let query = HKStatisticsCollectionQuery(quantityType: type,
        quantitySamplePredicate: nil,
        options: [.cumulativeSum],
        anchorDate: startOfDay,
        intervalComponents: interval)
        query.initialResultsHandler = { _, result, error in
                var resultCount = 0.0
                result!.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in

                if let sum = statistics.sumQuantity() {
                    // Get steps (they are of double type)
                    resultCount = sum.doubleValue(for: HKUnit.mile())
                } // end if

                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            }
        }
        query.statisticsUpdateHandler = {
            query, statistics, statisticsCollection, error in

            // If new statistics are available
            if let sum = statistics?.sumQuantity() {
                let resultCount = sum.doubleValue(for: HKUnit.mile())
                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            } // end if
        }
        healthStore.execute(query)
    }
    func getSteps(completion: @escaping (Double) -> Void)
    {
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        var interval = DateComponents()
        interval.day = 1
        let query = HKStatisticsCollectionQuery(quantityType: type,
        quantitySamplePredicate: nil,
        options: [.cumulativeSum],
        anchorDate: startOfDay,
        intervalComponents: interval)
        query.initialResultsHandler = { _, result, error in
                var resultCount = 0.0
                result!.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in

                if let sum = statistics.sumQuantity() {
                    // Get steps (they are of double type)
                    resultCount = sum.doubleValue(for: HKUnit.count())
                } // end if

                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            }
        }
        query.statisticsUpdateHandler = {
            query, statistics, statisticsCollection, error in

            // If new statistics are available
            if let sum = statistics?.sumQuantity() {
                let resultCount = sum.doubleValue(for: HKUnit.count())
                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            } // end if
        }
        healthStore.execute(query)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let healthKitTypes: Set = [ HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!,HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!]
        // Check for Authorization
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { (bool, error) in
            if (bool) {
                // Authorization Successful
                self.updateUsersHeightLabel()
                self.updateUsersWeightLabel()
                self.getSteps { (result) in
                    DispatchQueue.main.async {
                        let stepCount = String(Int(result))
                        self.stepsValueLabel.text = String(stepCount)
                    }
                }
                self.getDistance { (result) in
                    DispatchQueue.main.async {
                        let distanceCount = String(Double(result))
                        self.distanceValueLabel.text = String(distanceCount)
                    }
                }
            } // end if
        }
    }


}

