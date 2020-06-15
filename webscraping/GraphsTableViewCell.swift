//
//  GraphsTableViewCell.swift
//  webscraping
//
//  Created by Aarish  Brohi on 6/12/20.
//  Copyright © 2020 Aarish Brohi. All rights reserved.
//

import UIKit
import Charts

class GraphsTableViewCell: UITableViewCell, ChartViewDelegate {
    

    @IBOutlet weak var barChart: BarChartView!
    
    @IBOutlet weak var yTitle: UILabel!
    @IBOutlet weak var TopTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func setChart(str: [String], values: [Int]) {
       var array: [BarChartDataEntry] = []
        barChart.backgroundColor = UIColor.white

       for i in 0..<values.count  {
          array.append(BarChartDataEntry(x: Double(i), y: Double(values[i])))
       }

        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: str)
        let set = BarChartDataSet(entries: array)
        set.colors = ChartColorTemplates.joyful()
        let data2 = BarChartData(dataSet: set)
        barChart.xAxis.granularity = 1
        barChart.setVisibleXRangeMaximum(10)
        barChart.moveViewToX(90)
        barChart.xAxis.labelPosition = XAxis.LabelPosition.bottomInside
        barChart.xAxis.avoidFirstLastClippingEnabled = false
        barChart.xAxis.labelFont = UIFont(name: "Verdana", size: 7.0)!
        barChart.rightAxis.enabled = false
        barChart.legend.enabled = false
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
        
        
        barChart.data?.setDrawValues(false)
        barChart.pinchZoomEnabled = true
        barChart.scaleYEnabled = true
        barChart.scaleXEnabled = true
        barChart.highlighter = nil
        
        barChart.data = data2
    }


}
