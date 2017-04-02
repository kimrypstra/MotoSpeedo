//
//  ViewController.swift
//  Speedo
//
//  Created by Kim Rypstra on 15/1/17.
//  Copyright © 2017 Kim Rypstra. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, URLSessionDelegate {
    
    @IBInspectable var bgColour: UIColor = UIColor.black
    @IBInspectable var interfaceColour: UIColor = UIColor.white
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    var maxSpeed: Double = 0
    
    let locMan = CLLocationManager()
    let formatter = DateFormatter()
    var timer = Timer()
    
    var units: SettingsViewController.Units?
    var UOM: String?
    var timeMode: SettingsViewController.Time?
    
    var triedSpeedLimit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDefaults()
    }
    
    func loadDefaults() {
        let defaults = UserDefaults()
        if let factor: Double = defaults.value(forKey: "units") as? Double {
            units = SettingsViewController.Units(rawValue: factor)
        } else {
            units = SettingsViewController.Units.KPH
        }
        
        switch units! {
            case .KPH: UOM = "kph"
            case .MPH: UOM = "mph"
        }
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let time = defaults.value(forKey: "time") as? Int {
            if time == 0 {
                formatter.dateFormat = "h:mm"
            } else {
                formatter.dateFormat = "HH:mm"
            }
        } else {
            formatter.dateFormat = "hh:mm"
        }
        
        if let theme = defaults.value(forKey: "theme") as? String {
            switch theme {
                case "light":
                    bgColour = .white
                    interfaceColour = .black
                case "dark":
                    bgColour = .black
                    interfaceColour = .white
                default:
                    bgColour = .black
                    interfaceColour = .white
            }
        }
        
        if let shouldShowTopSpeed = defaults.value(forKey: "displayTopSpeed") as? Bool {
            if shouldShowTopSpeed {
                maxSpeedLabel.isHidden = false
                // load the top speed from defaults
            } else {
                maxSpeedLabel.isHidden = true
            }
        }
        
        clockTick()
        updateSpeed()
        setTheme()
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.clockTick), userInfo: nil, repeats: true)
    }
    
    func setTheme() {
        if clockLabel != nil && speedLabel != nil && settingsButton != nil {
            self.view.backgroundColor = bgColour
            clockLabel.textColor = interfaceColour
            speedLabel.textColor = interfaceColour
            settingsButton.tintColor = interfaceColour
            maxSpeedLabel.textColor = interfaceColour
        }
    }
    
    func clockTick() {
        if clockLabel != nil {
            let date = Date()
            clockLabel.text = formatter.string(from: date)
        }
    }
    /*
    func getSpeedLimit(location: String) {
        print("Trying to get speed limit...")
        var baseURL = "http://api.disordersoftware.com/speed/slr.php"
        baseURL.append("?location=\(location)")
        print("URL String: \(baseURL)")
        guard let url = URL(string: baseURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) else {
            print("URL Error")
            return
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        var dataTask = URLSessionDataTask()
        var req = URLRequest(url: url)
        
        dataTask = session.dataTask(with: req, completionHandler: { (data, response, error) in
            if error == nil {
                print("Recived: \(data)")
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject] {
                        print(json)
                    } else {
                        print("Error casting JSON as Dictionary")
                    }
                    
                } catch let error {
                    let string = String(data: data!, encoding: String.Encoding.utf8)
                    print("Error decoding data to JSON: \(error.localizedDescription). JSON String:\(string)")
                }
                
            } else {
                fatalError("URL Request Error: \(error)")
            }
        })
        
        dataTask.resume()

    }
    */
    
    override func viewDidAppear(_ animated: Bool) {
        locMan.delegate = self
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            print("Requesting authorization...")
            locMan.requestWhenInUseAuthorization()
        } else {
            print("Authorized. Starting location services...")
            locMan.desiredAccuracy = kCLLocationAccuracyBest
            locMan.startUpdatingLocation()
        }
    }
    
    func updateSpeed() {
        if let speed = locMan.location?.speed {
            let speedInt = Int(ceil(speed * units!.rawValue))
            if speed > maxSpeed {
                saveMaxSpeed(speed: speed)
            }
            if speedLabel != nil {
                speedLabel.text = "\(speedInt)"
            }
            /*
            if !triedSpeedLimit {
                let location = "\(locMan.location!.coordinate.latitude)|\(locMan.location!.coordinate.longitude)"
                getSpeedLimit(location: location)
                triedSpeedLimit = true
            }
            */
            
        }
    }
 
    
    func resetSpeed() {
        maxSpeed = 0
        if maxSpeedLabel != nil {
            maxSpeedLabel.text = ""
        }
    }
    
    @IBAction func didTapSettings(_ sender: UIButton) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetSpeed), name: Notification.Name(rawValue: "RESET_TOP_SPEED"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadDefaults), name: Notification.Name(rawValue: "RELOAD_DEFAULTS"), object: nil)
        self.performSegue(withIdentifier: "showSettings", sender: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("Authorization changed to 'In use'")
            locMan.desiredAccuracy = kCLLocationAccuracyBest
            locMan.startUpdatingLocation()
        } else {
            print("Authorization revoked")
            locMan.stopUpdatingLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateSpeed()
    }
    
    func saveMaxSpeed(speed: Double) {
        maxSpeed = speed
        if maxSpeedLabel != nil {
            maxSpeedLabel.text = "\(Int(ceil(maxSpeed * units!.rawValue)))\(UOM!)"
        }
        
        let defaults = UserDefaults()
        defaults.setValue(speed, forKey: "maxSpeed")
    }
}

