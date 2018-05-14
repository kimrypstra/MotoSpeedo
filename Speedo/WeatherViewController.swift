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
    var weatherRecords = [WeatherRecord]()
    var chartRecords = [ChartDataEntry]()
    var weatherFormatter = DateFormatter()
    
    @IBOutlet weak var probabilityLabel: UILabel!
    @IBOutlet weak var intensityLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherFormatter.locale = Locale(identifier: "en_US_POSIX")
        weatherFormatter.dateFormat = "ha"
        setUpLabels()
        setUpChart()
    }
    
    func setUpLabels() {
        let probabilities = weatherRecords.sorted(by: {$0.probability > $1.probability})
        let intensity = weatherRecords.sorted(by: {$0.intensity > $1.intensity})
        
        probabilityLabel.text = "\(Int((probabilities.first!.probability)))% at \(weatherFormatter.string(from: (probabilities.first?.date())!).lowercased())"
        intensityLabel.text = "\(intensity.first!.intensity * 1000)mm/h at \(weatherFormatter.string(from: intensity.first!.date()).lowercased())"
        timeLabel.text = "\(weatherFormatter.string(from: (weatherRecords.filter( {$0.probability > 0}).first?.date())!).lowercased())"
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
        chartView.xAxis.axisMaximum = 12
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
        chartView.leftAxis.axisMaximum = 100
        chartView.leftAxis.axisMinimum = -1
        chartView.leftAxis.drawAxisLineEnabled = false
        
        var times: [String] = []
        for (index, record) in weatherRecords.enumerated() {
            let time = weatherFormatter.string(from: record.date())
            times.append(time)
            let value = ChartDataEntry(x: Double(index), y: record.probability)
            chartRecords.append(value)
        }
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

}
