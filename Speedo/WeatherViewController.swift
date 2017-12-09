//
//  WeatherViewController.swift
//  Speedo
//
//  Created by Kim Rypstra on 28/8/17.
//  Copyright © 2017 Kim Rypstra. All rights reserved.
//

import UIKit
import Charts

class WeatherViewController: UIViewController {

    @IBOutlet weak var chartView: LineChartView!
    var weatherRecords = [(Double, Date, Double)]()
    // Probability, Time, Intensity
    var chartRecords = [ChartDataEntry]()
    var weatherFormatter = DateFormatter()
    
    @IBOutlet weak var probabilityLabel: UILabel!
    @IBOutlet weak var intensityLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherFormatter.locale = Locale(identifier: "en_US_POSIX")
        weatherFormatter.dateFormat = "ha"
        // Do any additional setup after loading the view.
        setUpLabels()
        setUpChart()
    }
    
    func setUpLabels() {
        let probabilities = weatherRecords.sorted(by: {$0.0 > $1.0})
        let intensity = weatherRecords.sorted(by: {$0.2 > $1.2})
        
        probabilityLabel.text = "\(Int((probabilities.first!.0)))% at \(weatherFormatter.string(from: (probabilities.first?.1)!).lowercased())"
        intensityLabel.text = "\(intensity.first!.2 * 1000)mm/h at \(weatherFormatter.string(from: intensity.first!.1).lowercased())"
        timeLabel.text = "\(weatherFormatter.string(from: (weatherRecords.filter( {$0.0 > 0}).first?.1)!).lowercased())"
        
    }
    
    
    func setUpChart() {
        chartView.backgroundColor = UIColor.clear
        
        chartView.chartDescription?.text = ""
        chartView.dragEnabled = true
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerDragEnabled = false
        chartView.legend.enabled = false
        chartView.drawBordersEnabled = false
        
        chartView.xAxis.drawGridLinesEnabled = true
        chartView.xAxis.granularity = 1
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.axisMaximum = 11
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawLabelsEnabled = true
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelRotationAngle = 45
        chartView.xAxis.labelTextColor = .white
        
        let percentages = ["", "25%", "50%", "75%", "100%"]
        chartView.rightAxis.drawLabelsEnabled = true
        chartView.rightAxis.valueFormatter = IndexAxisValueFormatter(values: percentages)
        chartView.rightAxis.labelPosition = .insideChart
        chartView.rightAxis.labelTextColor = .white
        chartView.rightAxis.drawTopYLabelEntryEnabled = true
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.rightAxis.granularity = 25
        chartView.rightAxis.axisMaximum = 100
        chartView.rightAxis.axisMinimum = -1
        
        
        chartView.leftAxis.enabled = false
        //chartView.leftAxis.drawLabelsEnabled = true
        //chartView.leftAxis.valueFormatter = IndexAxisValueFormatter(values: percentages)
        //chartView.leftAxis.labelPosition = .insideChart
        //chartView.leftAxis.labelTextColor = .white
        chartView.leftAxis.axisMaximum = 100
        chartView.leftAxis.axisMinimum = -1
        chartView.leftAxis.drawAxisLineEnabled = false
        //chartView.leftAxis.drawGridLinesEnabled = false
        
        var times: [String] = []
        print("Recieved \(weatherRecords.count) weather records")
        
        for (index, record) in weatherRecords.enumerated() {
            let time = weatherFormatter.string(from: record.1)
            times.append(time)
            
            let value = ChartDataEntry(x: Double(index), y: record.0)
            chartRecords.append(value)
        }
        
        print(times)
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: times)
        
        let line = LineChartDataSet(values: chartRecords, label: "Probability")
        line.drawCirclesEnabled = false
        line.drawFilledEnabled = true
        line.drawValuesEnabled = false
        
        line.fillColor = .white
        line.fillAlpha = 0.5
        line.lineWidth = 3
        line.colors = [UIColor.white, UIColor.clear]
        line.mode = .cubicBezier
        line.cubicIntensity = 0.02
        line.valueColors = [.white]
        
        let data = LineChartData()
        data.addDataSet(line)
        chartView.data = data
        
        
    }

    @IBAction func poweredByDarkSkyButton(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://darksky.net/poweredby/")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
