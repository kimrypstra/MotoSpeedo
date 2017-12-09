//
//  SettingsViewController.swift
//  Speedo
//
//  Created by Kim Rypstra on 15/1/17.
//  Copyright © 2017 Kim Rypstra. All rights reserved.
//

import UIKit
import CoreLocation

class SettingsViewController: UIViewController {

    @IBOutlet weak var timeSeg: UISegmentedControl!
    @IBOutlet weak var themeSeg: UISegmentedControl!
    @IBOutlet weak var speedSeg: UISegmentedControl!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var showHideLabel: UIButton!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var accuracyStepper: UIStepper!
    @IBOutlet weak var distanceStepper: UIStepper!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var defaults: UserDefaults!
    var shouldShowTopSpeed = false
    
    enum Units: Double {
        // These constants are used to convert from m/s
        case KPH = 3.6
        case MPH = 2.23694
    }
    
    enum Time: Int {
        case ampm = 0
        case military = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaults = UserDefaults()
        loadDefaults()
    }

    func loadDefaults() {
        versionLabel.text = "version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)"
        
        if defaults.value(forKey: "theme") as? String == "dark" {
            themeSeg.selectedSegmentIndex = 0
        } else {
            themeSeg.selectedSegmentIndex = 1
        }
        
        if defaults.value(forKey: "units") as? Double == 3.6 {
            speedSeg.selectedSegmentIndex = 0
        } else {
            speedSeg.selectedSegmentIndex = 1
        }
        
        if defaults.value(forKey: "time") as? Int == 0 {
            timeSeg.selectedSegmentIndex = 0
        } else {
            timeSeg.selectedSegmentIndex = 1
        }
        
        if defaults.value(forKey: "displayTopSpeed") as? Bool == false {
            let title = NSMutableAttributedString(string: "Show Top Speed", attributes: [NSForegroundColorAttributeName : UIColor.white])
            showHideLabel.setAttributedTitle(title, for: .normal)
            shouldShowTopSpeed = false
            print("Top Speed loaded as false")
        } else {
            let title = NSMutableAttributedString(string: "Hide Top Speed", attributes: [NSForegroundColorAttributeName : UIColor.white])
            showHideLabel.setAttributedTitle(title, for: .normal)
            shouldShowTopSpeed = true
            print("Top speed loaded as true")
        }
        
        if let accuracy = defaults.value(forKey: "locAcc") as? CLLocationAccuracy {
            switch accuracy {
            case kCLLocationAccuracyThreeKilometers:
                accuracyLabel.text = "Why bother?"
                accuracyStepper.value = 0
            case kCLLocationAccuracyKilometer:
                accuracyLabel.text = "Not good"
                accuracyStepper.value = 1
            case kCLLocationAccuracyHundredMeters:
                accuracyLabel.text = "Good"
                accuracyStepper.value = 2
            case kCLLocationAccuracyNearestTenMeters:
                accuracyLabel.text = "Great"
                accuracyStepper.value = 3
            case kCLLocationAccuracyBest:
                accuracyLabel.text = "Fantastic"
                accuracyStepper.value = 4
            case kCLLocationAccuracyBestForNavigation:
                accuracyLabel.text = "Amazing (RIP Battery)"
                accuracyStepper.value = 5
            default: print("Accuracy setting out of range: \(accuracy)"); break
            }
        } else {
            defaults.set(kCLLocationAccuracyHundredMeters, forKey: "locAcc")
            accuracyLabel.text = "Accuracy: 100m"
            print("Couldn't load accuracy; set to 100m")
        }
        
        if let fuelDistance = defaults.value(forKey: "distanceBeforeFuelLight") as? Double {
            // set the stepper to this value
            distanceStepper.value = fuelDistance
            // set the label to the stepper's value
            if speedSeg.selectedSegmentIndex == 0 {
                //km
                distanceLabel.text = "Refuel distance: \(Int(distanceStepper.value / 1000))km"
            } else {
                //miles
                distanceLabel.text = "Refuel distance: \(Int((distanceStepper.value / 1000) / 1.6))mi"
            }
        } else {
            // setting hasn't been changed; set to 100km
            defaults.set(Double(100000), forKey: "distanceBeforeFuelLight")
            distanceStepper.value = 100000
            if speedSeg.selectedSegmentIndex == 0 {
                //km
                distanceLabel.text = "Refuel distance: \(Int(distanceStepper.value / 1000))km"
            } else {
                //miles
                distanceLabel.text = "Refuel distance: \(Int((distanceStepper.value / 1000) / 1.6))mi"
            }
        }
    }
    
    @IBAction func didTapResetTopSpeed(_ sender: UIButton) {
        defaults.set(0, forKey: "maxSpeed")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RESET_TOP_SPEED")))
    }

    @IBAction func didTapShowHide(_ sender: UIButton) {
        print("Show/Hide tapped")
        if shouldShowTopSpeed == true {
            defaults.setValue(false, forKey: "displayTopSpeed")
            shouldShowTopSpeed = false
            let title = NSMutableAttributedString(string: "Show Top Speed", attributes: [NSForegroundColorAttributeName : UIColor.white])
            showHideLabel.setAttributedTitle(title, for: .normal)
        } else {
            defaults.setValue(true, forKey: "displayTopSpeed")
            let title = NSMutableAttributedString(string: "Hide Top Speed", attributes: [NSForegroundColorAttributeName : UIColor.white])
            showHideLabel.setAttributedTitle(title, for: .normal)
            shouldShowTopSpeed = true
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD_DEFAULTS")))
    }
    
    @IBAction func speedUnitSeg(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0: defaults.set(Units.KPH.rawValue, forKey: "units")
            case 1: defaults.set(Units.MPH.rawValue, forKey: "units")
            default: defaults.set(Units.KPH.rawValue, forKey: "units")
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD_DEFAULTS")))
    }
    
    @IBAction func timeSeg(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0: defaults.set(Time.ampm.rawValue, forKey: "time")
            case 1: defaults.set(Time.military.rawValue, forKey: "time")
            default: defaults.set(Time.military.rawValue, forKey: "time")
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD_DEFAULTS")))
    }
    
    @IBAction func themeSeg(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: defaults.set("dark", forKey: "theme")
        case 1: defaults.set("light", forKey: "theme")
        default: defaults.set("dark", forKey: "theme")
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD_DEFAULTS")))
    }
    
    @IBAction func accuracyStepper(_ sender: UIStepper) {
        switch sender.value {
        case 0:
            accuracyLabel.text = "Why bother?"
            defaults.set(kCLLocationAccuracyThreeKilometers, forKey: "locAcc")
        case 1:
            accuracyLabel.text = "Not great"
            defaults.set(kCLLocationAccuracyKilometer, forKey: "locAcc")
        case 2:
            accuracyLabel.text = "Good"
            defaults.set(kCLLocationAccuracyHundredMeters, forKey: "locAcc")
        case 3:
            accuracyLabel.text = "Great"
            defaults.set(kCLLocationAccuracyNearestTenMeters, forKey: "locAcc")
        case 4:
            accuracyLabel.text = "Fantastic"
            defaults.set(kCLLocationAccuracyBest, forKey: "locAcc")
        case 5:
            accuracyLabel.text = "Amazing (RIP battery)"
            defaults.set(kCLLocationAccuracyBestForNavigation, forKey: "locAcc")
        default: print("Accuracy stepper out of range: \(sender.value)"); break
        }
    }
    
    
    @IBAction func fuelStepper(_ sender: UIStepper) {
        defaults.set(sender.value, forKey: "distanceBeforeFuelLight")
        if speedSeg.selectedSegmentIndex == 0 {
            //km
            distanceLabel.text = "Refuel distance: \(Int(sender.value / 1000))km"
        } else {
            //miles
            distanceLabel.text = "Refuel distance: \(Int((sender.value / 1000) / 1.6))mi"
        }
    }
    
    @IBAction func resetFuelTrip(_ sender: UIButton) {
        print("Resetting fuel trip...")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "RESET_FUEL_TRIP"), object: nil)
        defaults.set(0.0, forKey: "currentDistance")
        defaults.synchronize()
        print("Set as... \(defaults.value(forKey: "currentDistance")!)")
    }
    
    @IBAction func didTapOK(_ sender: UIButton) {
        // save settings
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD_DEFAULTS")))
        self.dismiss(animated: true, completion: nil)
        
    }

}
