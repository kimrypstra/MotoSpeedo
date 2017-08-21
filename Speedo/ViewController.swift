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
    
    @IBOutlet weak var rightStrength: UIProgressView!
    @IBOutlet weak var leftStrength: UIProgressView!
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
        leftStrength.transform = leftStrength.transform.rotated(by: CGFloat.pi)
        UIApplication.shared.isIdleTimerDisabled = true
        loadDefaults()
    }
        
    func radToDeg(rad: Double) -> Double {
        return (180/Double.pi) * rad
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
        
        guard let accuracy = defaults.value(forKey: "locAcc") as? CLLocationAccuracy else {
            locMan.desiredAccuracy = kCLLocationAccuracyHundredMeters
            return
        }
        locMan.desiredAccuracy = accuracy
        
        clockTick()
        updateSpeed(speed: 0)
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
            leftStrength.trackTintColor = bgColour
            rightStrength.trackTintColor = bgColour
            leftStrength.progressTintColor = interfaceColour
            rightStrength.progressTintColor = interfaceColour
        }
    }
    
    func clockTick() {
        if clockLabel != nil {
            let date = Date()
            clockLabel.text = formatter.string(from: date)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locMan.delegate = self
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            print("Requesting authorization...")
            locMan.requestWhenInUseAuthorization()
        } else {
            print("Authorized. Starting location services...")
            locMan.desiredAccuracy = UserDefaults().value(forKey: "locAcc") as! CLLocationAccuracy
            locMan.startUpdatingLocation()
        }
    }
    
    func updateSpeed(speed: Double) {
        guard speed > 0 else {
            speedLabel.text = "0"
            return 
        }
        
        let speedInt = Int(ceil(speed * units!.rawValue))
        if speed > maxSpeed {
            saveMaxSpeed(speed: speed)
        }
        if speedLabel != nil {
            speedLabel.text = "\(speedInt)"
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
        var locationScore: Float = 0
        switch locations.first?.horizontalAccuracy as! Double {
        case -50...0: locationScore = 0
        case 0...10: locationScore = 0.5
        case 11...20: locationScore = 0.4
        case 21...30: locationScore = 0.3
        case 31...40: locationScore = 0.2
        case 41...50: locationScore = 0.1
        default: locationScore = 0
        }
        leftStrength.setProgress(locationScore, animated: true)
        rightStrength.setProgress(locationScore, animated: true)
        if let speed = locations.first?.speed {
            updateSpeed(speed: speed)
        }
        
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

