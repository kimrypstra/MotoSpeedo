//
//  WeatherManager.swift
//  Speedo
//
//  Created by Kim Rypstra on 22/8/17.
//  Copyright © 2017 Kim Rypstra. All rights reserved.
//

import UIKit

class WeatherManager: NSObject, URLSessionDelegate {
    fileprivate let key: String = DS_KEY
    private var rainRecords = [WeatherRecord]()
    
    func getRainRecords() -> [WeatherRecord] {
        return rainRecords
    }
    
    func willItRainToday(lattitude: String, longitude: String, completion: @escaping (WeatherRecord?) -> ()) {
        /// Requests weather information, saves records, then returns the first occurance of a record with a probability greater than or equal to 1%
        let group = DispatchGroup()
        group.enter()
        sendRequest(lattitude: lattitude, longitude: longitude) { (error, data) in
            if data != nil {
                self.checkResponseForRain(data: data!, completion: { weatherRecords in
                    guard weatherRecords != nil else {

                        return
                    }
                    if weatherRecords!.count > 0 {
                        self.rainRecords = weatherRecords!
                        group.leave()
                    } else {
                        group.leave()
                    }
                })
            } else {
                print("Error: \(error?.localizedDescription ?? "Unknown Error")")
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            guard let firstRain = self.rainRecords.filter({$0.probability >= 1}).first else {
                print("No rain probability >= 1% found")
                completion(nil)
                return
            }
            completion(firstRain)
        }
    }
    
    private func sendRequest(lattitude: String, longitude: String, completion: @escaping (Error?, Data?) -> ()) {
        let urlString = "https://api.darksky.net/forecast/\(key)/\(lattitude),\(longitude)?exclude=currently,minutely,daily,flags"

        guard let url = URL(string: urlString) else {
            print("URL Formatting Error")
            completion(nil, nil)
            return
        }
        
        // Set up the request
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        var dataTask = URLSessionDataTask()
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
        // Debug
        // print("Sending request to: \(urlString)")
        
        // Send the request
        dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                print("An error may have occurred")
            } else {
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode != 200 {
                    print("Error - server returned \(httpResponse.statusCode)")
                } else {
                    print("Received: \(data!)")
                    completion(nil, data)
                }
            }
        })
        
        dataTask.resume()
    }
    
    private func checkResponseForRain(data: Data, completion: ([WeatherRecord]?) -> ()) {
        var weatherRecords = [WeatherRecord]()
        do {
            // Decode
            let records = try JSONDecoder().decode(WeatherResponse.self, from: data)
            print(records)
            
            // Discard records out of our time range
            weatherRecords = records.weatherRecords().filter({$0.date().timeIntervalSinceNow < (13 * (60 * 60)) && $0.date().timeIntervalSinceNow >= -60})
            
            // Sort by time
            weatherRecords.sort(by: {$0.time < $1.time})
            
            // Return the sorted records
            completion(weatherRecords)
            
        } catch let error {
            print("Error decoding data to JSON: \(error)")
            completion(nil)
        }
    }
}

