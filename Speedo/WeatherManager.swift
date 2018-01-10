//
//  WeatherManager.swift
//  Speedo
//
//  Created by Kim Rypstra on 22/8/17.
//  Copyright © 2017 Kim Rypstra. All rights reserved.
//

import UIKit

class WeatherManager: NSObject, URLSessionDelegate {
    private let key: String = "4cf7ca97f8196f27d236c05a9bc6eca6"
    private var rainRecords = [(Double, Date, Double)]()
    // Probability, Time, Intensity
    func getRainRecords() -> [(Double, Date, Double)] {
        return rainRecords
    }
    
    func willItRainToday(lattitude: String, longitude: String, completion: @escaping ([(Double, Date, Double)]) -> ()) {

        let group = DispatchGroup()
        group.enter()
        sendRequest(lattitude: lattitude, longitude: longitude) { (error, data) in
            if data != nil {
                self.checkResponseForRain(data: data!, completion: { weatherRecords in
                    if weatherRecords.count > 0 {
                        self.rainRecords = weatherRecords
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
            completion(self.rainRecords)
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
        print("Sending request to: \(urlString)")
        
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
    
    private func checkResponseForRain(data: Data, completion: ([(Double, Date, Double)]) -> ()) {
        var arrayOfRecords = [(Double, Date, Double)]()
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            //print(json)
            
            guard let hourlyStage = json["hourly"] as? [String: AnyObject] else {print("Error stage 1"); return}
            guard let dataStage = hourlyStage["data"] as? [[String: AnyObject]] else {print("Error stage 2"); return}

            for hour in dataStage {
                let time = Date(timeIntervalSince1970: Double(hour["time"] as! Int))
                let interval = time.timeIntervalSinceNow
                if interval < (13 * (60 * 60)) && interval >= -60 {
                    print("Time: \(time); Probability: \(hour["precipProbability"]!)")
                    guard let probability = hour["precipProbability"] as? Double else {break}
                    guard let intensity = hour["precipIntensity"] as? Double else {break}
                    // Probability, Time, Intensity
                    arrayOfRecords.append((probability * 100, time, intensity))
                }
            }
            
            completion(arrayOfRecords)
            
        } catch let error {
            print("Error decoding data to JSON: \(error)")
            completion(arrayOfRecords)
        }
    }
}
//-43.148410, 147.071662
