//
//  ViewController.swift
//  Speedo
//
//  Created by Kim Rypstra on 15/1/17.
//  Copyright © 2017 Kim Rypstra. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate, URLSessionDelegate {
    
    @IBInspectable var bgColour: UIColor = UIColor.black
    @IBInspectable var interfaceColour: UIColor = UIColor.white
    
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var fuelButton: UIButton!
    @IBOutlet weak var rightStrength: UIProgressView!
    @IBOutlet weak var leftStrength: UIProgressView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var rainButton: UIButton!
    
    var player: AVAudioPlayer?
    var maxSpeed: Double = 0
    let locMan = CLLocationManager()
    let weatherMan = WeatherManager()
    var weatherHasBeenRequested = false
    let formatter = DateFormatter()
    var timer = Timer()
    var units: SettingsViewController.Units?
    var UOM: String?
    var timeMode: SettingsViewController.Time?
    var lastLocation: CLLocation?
    var currentDistance: Double = 0
    var distanceBeforeFuelLight: Double!
    
    //=======================================================================//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftStrength.transform = leftStrength.transform.rotated(by: CGFloat.pi)
        UIApplication.shared.isIdleTimerDisabled = true
        rainButton.isHidden = true
        rainLabel.isHidden = true
        loadDefaults()
    }
        
    func radToDeg(rad: Double) -> Double {
        return (180/Double.pi) * rad
    }
    
    func loadDefaults() {
        print("Loading defaults...")
        let defaults = UserDefaults()
        
        if let factor: Double = defaults.value(forKey: "units") as? Double {
            units = SettingsViewController.Units(rawValue: factor)
        } else {
            units = SettingsViewController.Units.KPH
            defaults.set(3.6, forKey: "units")
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
            defaults.set(0, forKey: "time")
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
        } else {
            defaults.set("dark", forKey: "theme")
            bgColour = .black
            interfaceColour = .white
        }
        
        if let shouldShowTopSpeed = defaults.value(forKey: "displayTopSpeed") as? Bool {
            if shouldShowTopSpeed {
                maxSpeedLabel.isHidden = false
                if maxSpeed != nil && maxSpeed > 0 {
                    maxSpeedLabel.text = "\(Int(ceil(maxSpeed * units!.rawValue)))\(UOM!)"
                }
                
            } else {
                maxSpeedLabel.isHidden = true
                defaults.set(false, forKey: "displayTopSpeed")
            }
        }
        
        if let accuracy = defaults.value(forKey: "locAcc") as? CLLocationAccuracy {
            locMan.desiredAccuracy = accuracy
        } else {
            defaults.set(kCLLocationAccuracyHundredMeters, forKey: "locAcc")
            locMan.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }
        
        if let maxDistance = defaults.value(forKey: "distanceBeforeFuelLight") as? Double {
            distanceBeforeFuelLight = maxDistance
        } else {
            print("Distance before fuel light not found - assume 100km")
            defaults.set(100000, forKey: "distanceBeforeFuelLight")
            distanceBeforeFuelLight = 100000
        }
        
        if let current = defaults.value(forKey: "currentDistance") as? Double {
            print("Current distance read as: \(current)m")
            currentDistance = current
            if currentDistance > distanceBeforeFuelLight {
                fuelButton.isHidden = false
            } else {
                fuelButton.isHidden = true
            }
        } else {
            // no need to set a default value for this one
            print("Current distance not found")
        }
        
        
//        if currentDistance > distanceBeforeFuelLight {
//            fuelButton.isHidden = false
//        } else {
//            fuelButton.isHidden = true
//        }
        

        
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
            if let accuracy = UserDefaults().value(forKey: "locAcc") as? CLLocationAccuracy {
                locMan.desiredAccuracy = accuracy
                locMan.startUpdatingLocation()
            } else {
                locMan.desiredAccuracy = kCLLocationAccuracyHundredMeters
                locMan.startUpdatingLocation()
            }
            
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
    
    @IBAction func didTapFuelButton(_ sender: UIButton) {
        var currentDist = Int(ceil(currentDistance / 1000))
        var unit = ""
        if units == SettingsViewController.Units.KPH {
            unit = "km"
        } else if units == SettingsViewController.Units.MPH {
            currentDist = Int(ceil((currentDistance / 1000) / units!.rawValue))
            unit = "mi"
        }
        let alert = UIAlertController(title: "Reset fuel mileage?", message: "You made it \(currentDist)\(unit). Do you want to reset your fuel trip?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            self.currentDistance = 0
            self.lastLocation = nil
            UserDefaults().setValue(self.currentDistance, forKey: "currentDistance")
            print("Reset. Key reads: \(UserDefaults().value(forKey: "currentDistance")!)")
            self.fuelButton.isHidden = true
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            return
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTapSettings(_ sender: UIButton) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetSpeed), name: Notification.Name(rawValue: "RESET_TOP_SPEED"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadDefaults), name: Notification.Name(rawValue: "RELOAD_DEFAULTS"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didResetFuelTrip), name: Notification.Name(rawValue: "RESET_FUEL_TRIP"), object: nil)
        self.performSegue(withIdentifier: "showSettings", sender: self)
    }
    
    func didResetFuelTrip() {
        self.lastLocation = nil
        self.currentDistance = 0
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("Authorization changed to 'In use'")
            locMan.startUpdatingLocation()
        } else {
            print("Authorization revoked")
            locMan.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !weatherHasBeenRequested {
            weatherHasBeenRequested = true
            weatherMan.willItRainToday(lattitude: String(locMan.location!.coordinate.latitude), longitude: String(locMan.location!.coordinate.longitude)) { weatherRecords in
                if weatherRecords.count > 0 {
                    self.rainButton.isHidden = false
                    let sortedRecords = weatherRecords.sorted(by: {$0.1 < $1.1})
                    print("Received \(sortedRecords.count) records")
                    let weatherFormatter = DateFormatter()
                    weatherFormatter.locale = Locale(identifier: "en_US_POSIX")
                    weatherFormatter.dateFormat = "ha"
                    let firstRain = sortedRecords.filter({$0.0 > 0}).first
                    self.rainLabel.text = weatherFormatter.string(from: (firstRain!.1)).lowercased()
                    self.rainLabel.isHidden = false
                } else {
                    print("Doesn't look like it will rain today")
                }
            }
        }

        var locationScore: Float = 0
        switch locations.first?.horizontalAccuracy as! Double {
        case -50...0: locationScore = 0
        case 0...10: locationScore = 1
        case 10...20: locationScore = 0.8
        case 20...30: locationScore = 0.6
        case 30...40: locationScore = 0.4
        case 40...50: locationScore = 0.2
        case 50...100: locationScore = 0.1
        default: locationScore = 0
        }
        leftStrength.setProgress(locationScore, animated: true)
        rightStrength.setProgress(locationScore, animated: true)
        if let speed = locations.first?.speed {
            updateSpeed(speed: speed)
        }
        
        if lastLocation != nil {
            guard let distance = locations.first?.distance(from: lastLocation!) as? Double else {
                print("No distance")
                return
            }
            currentDistance += distance
            //print("Current distance: \(currentDistance)")
            UserDefaults().setValue(currentDistance, forKey: "currentDistance")
            lastLocation = locations.first
        } else {
            lastLocation = locations.first
        }
        
        if currentDistance > distanceBeforeFuelLight {
            if fuelButton.isHidden == true {
                playSound()
                fuelButton.isHidden = false
            }
        } else {
            if fuelButton.isHidden == false {
                fuelButton.isHidden = true
            }
        }
    }
    
    func playSound() {
        guard let sound = NSDataAsset(name: "poo") else {
            print("Asset not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeWAVE)
            
            player!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func rainButton(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "toWeather":
            guard let IVC = segue.destination as? WeatherViewController else {
                print("Error segueing to weather")
                return
            }
            IVC.weatherRecords = weatherMan.getRainRecords()
        default:
            print("Segue identifier not right")
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

