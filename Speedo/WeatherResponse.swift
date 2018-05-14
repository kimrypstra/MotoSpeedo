//
//  WeatherRecord.swift
//  Speedo
//
//  Created by Kim Rypstra on 13/5/18.
//  Copyright © 2018 Kim Rypstra. All rights reserved.
//

import Foundation

typealias WeatherRecord = WeatherResponse.HourlyRecords.WeatherRecord

struct WeatherResponse: Decodable {

    private var hourlyRecords: HourlyRecords
    
    func weatherRecords() -> [WeatherRecord] {
        return hourlyRecords.records
    }
    
    private enum CodingKeys: String, CodingKey {
        case hourlyRecords = "hourly"
    }
    
    struct HourlyRecords: Decodable {
        var records: [WeatherRecord]
        
        private enum CodingKeys : String, CodingKey {
            case records = "data"
        }
        
        struct WeatherRecord: Decodable, CustomStringConvertible {
            var probability: Double
            /// The time of the WeatherRecord expressed as seconds since the dawn of unix time
            var time: Double
            var intensity: Double

            /// Returns the WeatherRecord's time as a Date object
            ///
            /// - Returns: Date
            func date() -> Date {
                return Date(timeIntervalSince1970: time)
            }
            
            var description: String {
                return "Prob: \(probability); Time: \(date()); Intensity: \(intensity)"
            }
            
            private enum CodingKeys : String, CodingKey {
                case probability = "precipProbability"
                case time
                case intensity = "precipIntensity"
            }
        }
    }
}
