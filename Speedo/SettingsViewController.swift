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
    
    let defaults = UserDefaults()
    var shouldShowTopSpeed = false
    
    enum Units: Double {
        case KPH = 3.6
        case MPH = 2.23694
    }
    
    enum Time: Int {
        case ampm = 0
        case military = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                accuracyLabel.text = "Accuracy: 3km"
                accuracyStepper.value = 0
            case kCLLocationAccuracyKilometer:
                accuracyLabel.text = "Accuracy: 1km"
                accuracyStepper.value = 1
            case kCLLocationAccuracyHundredMeters:
                accuracyLabel.text = "Accuracy: 100m"
                accuracyStepper.value = 2
            case kCLLocationAccuracyNearestTenMeters:
                accuracyLabel.text = "Accuracy: 10m"
                accuracyStepper.value = 3
            case kCLLocationAccuracyBest:
                accuracyLabel.text = "Best"
                accuracyStepper.value = 4
            case kCLLocationAccuracyBestForNavigation:
                accuracyLabel.text = "Best for Navigation"
                accuracyStepper.value = 5
            default: print("Accuracy setting out of range: \(accuracy)"); break
            }
        } else {
            defaults.set(kCLLocationAccuracyHundredMeters, forKey: "locAcc")
            accuracyLabel.text = "Accuracy: 100m"
            print("Couldn't load accuracy; set to 100m")
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
        // CHANGE_THEME 
        /*
        let alert = UIAlertController(title: "Not complete", message: "This feature is not yet complete", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        */
        
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
            accuracyLabel.text = "Accuracy: 3km"
            defaults.set(kCLLocationAccuracyThreeKilometers, forKey: "locAcc")
        case 1:
            accuracyLabel.text = "Accuracy: 1km"
            defaults.set(kCLLocationAccuracyKilometer, forKey: "locAcc")
        case 2:
            accuracyLabel.text = "Accuracy: 100m"
            defaults.set(kCLLocationAccuracyHundredMeters, forKey: "locAcc")
        case 3:
            accuracyLabel.text = "Accuracy: 10m"
            defaults.set(kCLLocationAccuracyNearestTenMeters, forKey: "locAcc")
        case 4:
            accuracyLabel.text = "Best"
            defaults.set(kCLLocationAccuracyBest, forKey: "locAcc")
        case 5:
            accuracyLabel.text = "Best for Navigation"
            defaults.set(kCLLocationAccuracyBestForNavigation, forKey: "locAcc")
        default: print("Accuracy stepper out of range: \(sender.value)"); break
        }
    }
    
    
    @IBAction func didTapOK(_ sender: UIButton) {
        // save settings 
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD_DEFAULTS")))
        self.dismiss(animated: true, completion: nil)
        
    }

}
