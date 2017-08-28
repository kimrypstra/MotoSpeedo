//
//  WeatherViewController.swift
//  Speedo
//
//  Created by Kim Rypstra on 28/8/17.
//  Copyright © 2017 Kim Rypstra. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var weatherRecords = [(Double, Date, Double)]()
    var weatherFormatter = DateFormatter()
    // Probability, Time, Intensity
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherFormatter.locale = Locale(identifier: "en_US_POSIX")
        weatherFormatter.dateFormat = "ha"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        cell.textLabel?.text = "\(weatherFormatter.string(from: (weatherRecords[indexPath.row].1)).lowercased()) - \(Int(weatherRecords[indexPath.row].0 * 100))%"
        print(cell.textLabel)
        return cell
    }

    @IBAction func poweredByDarkSkyButton(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://darksky.net/poweredby/")!, options: [:], completionHandler: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
