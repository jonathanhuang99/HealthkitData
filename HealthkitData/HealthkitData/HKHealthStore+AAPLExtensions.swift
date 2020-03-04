//
//  HKHealthStore+AAPLExtensions.swift
//  HealthkitData
//
//  Created by Jonathan Huang on 3/4/20.
//  Copyright © 2020 Jonathan Huang. All rights reserved.
//

import Foundation
import HealthKit

extension HKHealthStore {
    
    // Fetches the single most recent quantity of the specified type.
    func aapl_mostRecentQuantitySampleOfType(_ quantityType: HKQuantityType, predicate: NSPredicate?, completion: ((HKQuantity?, Error?)->Void)?) {
        let timeSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
        let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 1, sortDescriptors: [timeSortDescriptor]) {query, results, error in
            if results == nil {
                completion?(nil, error)
                
                return
            }
            
            if completion != nil {
                // If quantity isn't in the database, return nil in the completion block.
                let quantitySample = results!.first as? HKQuantitySample
                let quantity = quantitySample?.quantity
                
                completion!(quantity, error)
            }
        }
        
        self.execute(query)
    }
    
}
