//
//  SettingsViewController.swift
//  Speedo
//
//  Created by Kim Rypstra on 15/1/17.
//  Copyright © 2017 Kim Rypstra. All rights reserved.
//

import UIKit
import CoreLocation

class SettingsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var timeSeg: UISegmentedControl!
    @IBOutlet weak var speedSeg: UISegmentedControl!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var fuelTripSwitch: UISwitch!
    @IBOutlet weak var showTopSpeedSwitch: UISwitch!
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var accuracyStepper: UIStepper!
    @IBOutlet weak var distanceStepper: UIStepper!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var iconScrollView: UIScrollView!
    @IBOutlet weak var iconStackView: UIStackView!
    
    var defaults: UserDefaults!
    var shouldShowTopSpeed = false
    var iconImages: [String: UIImage] = [
        "BaseIcon" : UIImage(named: "BaseIcon Curved")!,
        "BMW" : UIImage(named: "BMW Curved")!,
        "Dark" : UIImage(named: "Dark Curved")!,
        "Ducati" : UIImage(named: "Ducati Curved")!,
        "HD" : UIImage(named: "HD Curved")!,
        "Honda" : UIImage(named: "Honda Curved")!,
        "Kawasaki" : UIImage(named: "Kawasaki Curved")!,
        "KTM" : UIImage(named: "KTM Curved")!,
        "Yamaha" : UIImage(named: "Yamaha Curved")!,
    ]
    
    
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
        iconScrollView.delegate = self 
        loadDefaults()
        populateImagesInStackView(completion: {
            setScrollViewToCurrentIcon()
        })
        
    }
    
    func populateImagesInStackView(completion: () -> ()) {
        print("Populating images...")
        for (index, view) in iconStackView.arrangedSubviews.enumerated() {
            print("Image \(index)")
            guard let image = view.subviews.first as? UIImageView else {
                print("This isn't an image...")
                return
            }
            image.image = iconImages[Array(iconImages.keys)[index]]
            if index == iconImages.count - 1 {
                completion()
            }
        }
    
    }
    
    func setScrollViewToCurrentIcon() {
        guard let currentName = UIApplication.shared.alternateIconName else {
            //No alternate icon set
            guard let index = Array(iconImages.keys).index(of: "BaseIcon") else {
                print("Error getting index of icon")
                return
            }
            iconScrollView.setContentOffset(CGPoint(x: CGFloat(index) * iconScrollView.frame.width, y: 0), animated: false)
            return
        }
        guard let index = Array(iconImages.keys).index(of: currentName) else {
            print("Error getting index of icon")
            return
        }
        iconScrollView.setContentOffset(CGPoint(x: CGFloat(index) * iconScrollView.frame.width, y: 0), animated: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / iconScrollView.frame.width)
        print("Selected \(Array(iconImages.keys)[page])")
    }
    
    func loadDefaults() {
        versionLabel.text = "version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)"
        
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
            showTopSpeedSwitch.isOn = false
            print("Top Speed loaded as false")
        } else {
            showTopSpeedSwitch.isOn = true
            print("Top speed loaded as true")
        }
        
        if defaults.value(forKey: "shouldDoFuelTrip") as? Bool == false {
            fuelTripSwitch.isOn = false
        } else {
            fuelTripSwitch.isOn = true
        }
        
        if let accuracy = defaults.value(forKey: "locAcc") as? CLLocationAccuracy {
            switch accuracy {
            case kCLLocationAccuracyThreeKilometers:
                accuracyLabel.text = "Accuracy: Why bother?"
                accuracyStepper.value = 0
            case kCLLocationAccuracyKilometer:
                accuracyLabel.text = "Accuracy: Not great"
                accuracyStepper.value = 1
            case kCLLocationAccuracyHundredMeters:
                accuracyLabel.text = "Accuracy: Good"
                accuracyStepper.value = 2
            case kCLLocationAccuracyNearestTenMeters:
                accuracyLabel.text = "Accuracy: Great"
                accuracyStepper.value = 3
            case kCLLocationAccuracyBest:
                accuracyLabel.text = "Accuracy: Fantastic"
                accuracyStepper.value = 4
            case kCLLocationAccuracyBestForNavigation:
                accuracyLabel.text = "Accuracy: Amazing (RIP Battery)"
                accuracyStepper.value = 5
            default: print("Accuracy setting out of range: \(accuracy)"); break
            }
        } else {
            defaults.set(kCLLocationAccuracyNearestTenMeters, forKey: "locAcc")
            accuracyLabel.text = "Accuracy: Great"
            print("Couldn't load accuracy; set to 10m")
        }
        
        if let fuelDistance = defaults.value(forKey: "distanceBeforeFuelLight") as? Double {
            // set the stepper to this value
            distanceStepper.value = fuelDistance
            // set the label to the stepper's value
            if speedSeg.selectedSegmentIndex == 0 {
                //km
                distanceLabel.text = "Trip distance: \(Int(distanceStepper.value / 1000))km"
            } else {
                //miles
                distanceLabel.text = "Trip distance: \(Int((distanceStepper.value / 1000) / 1.6))mi"
            }
        } else {
            // setting hasn't been changed; set to 100km
            defaults.set(Double(100000), forKey: "distanceBeforeFuelLight")
            distanceStepper.value = 100000
            if speedSeg.selectedSegmentIndex == 0 {
                //km
                distanceLabel.text = "Trip distance: \(Int(distanceStepper.value / 1000))km"
            } else {
                //miles
                distanceLabel.text = "Trip distance: \(Int((distanceStepper.value / 1000) / 1.6))mi"
            }
        }
    }
    
    @IBAction func showTopSpeedSwitch(_ sender: UISwitch) {
        print("Show/Hide tapped")
        if sender.isOn {
            defaults.setValue(true, forKey: "displayTopSpeed")
        } else {
            defaults.setValue(false, forKey: "displayTopSpeed")
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD_DEFAULTS")))
    }
    
    @IBAction func fuelTripSwitch(_ sender: UISwitch) {
        if sender.isOn {
            defaults.setValue(true, forKey: "shouldDoFuelTrip")
        } else {
            defaults.setValue(0, forKey: "currentDistance")
            defaults.setValue(false, forKey: "shouldDoFuelTrip")
        }
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
    
    
    @IBAction func accuracyStepper(_ sender: UIStepper) {
        switch sender.value {
        case 0:
            accuracyLabel.text = "Accuracy: Why bother?"
            defaults.set(kCLLocationAccuracyThreeKilometers, forKey: "locAcc")
        case 1:
            accuracyLabel.text = "Accuracy: Not great"
            defaults.set(kCLLocationAccuracyKilometer, forKey: "locAcc")
        case 2:
            accuracyLabel.text = "Accuracy: Good"
            defaults.set(kCLLocationAccuracyHundredMeters, forKey: "locAcc")
        case 3:
            accuracyLabel.text = "Accuracy: Great"
            defaults.set(kCLLocationAccuracyNearestTenMeters, forKey: "locAcc")
        case 4:
            accuracyLabel.text = "Accuracy: Fantastic"
            defaults.set(kCLLocationAccuracyBest, forKey: "locAcc")
        case 5:
            accuracyLabel.text = "Accuracy: Amazing (RIP battery)"
            defaults.set(kCLLocationAccuracyBestForNavigation, forKey: "locAcc")
        default: print("Accuracy stepper out of range: \(sender.value)"); break
        }
    }
    
    
    @IBAction func fuelStepper(_ sender: UIStepper) {
        defaults.set(sender.value, forKey: "distanceBeforeFuelLight")
        if speedSeg.selectedSegmentIndex == 0 {
            //km
            distanceLabel.text = "Trip distance: \(Int(sender.value / 1000))km"
        } else {
            //miles
            distanceLabel.text = "Trip distance: \(Int((sender.value / 1000) / 1.6))mi"
        }
    }
    
    @IBAction func didTapOK(_ sender: UIButton) {
        // save settings
        // Set the new icon
        let page = Int(iconScrollView.contentOffset.x / iconScrollView.frame.width)
        let iconName = Array(iconImages.keys)[page]
        if iconName != "BaseIcon" {
            UIApplication.shared.setAlternateIconName(Array(iconImages.keys)[page]) { (error) in
                if error != nil {
                    print("Error setting icon: \(error?.localizedDescription ?? "Unknown Error")")
                }
            }
        } else {
            UIApplication.shared.setAlternateIconName(nil, completionHandler: nil)
        }
        
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "RELOAD_DEFAULTS")))
        self.dismiss(animated: true, completion: nil)
        
    }

}
