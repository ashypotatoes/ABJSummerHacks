//
//  CountyAllTimeViewController.swift
//  webscraping
//
//  Created by Aarish  Brohi on 7/28/20.
//  Copyright © 2020 Aarish Brohi. All rights reserved.
//

import UIKit
import Charts
import Firebase

class CountyAllTimeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var dates = [String]()
    let allTime = UserDefaults.standard.string(forKey: "name")
    var allTimeCounty = [Double]()
    var dailyAllCounty = [Double]()
    var cnt : Int = 0
    let group = DispatchGroup()
    
     override func viewDidLoad() {
        tableView.backgroundColor = AppDelegate().uicolorFromHex(rgbValue: 0x313547)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        cnt += 1
        getFirestoreData()
        DataNumbers().getDates(){ (keys) in
            self.dates = keys
            self.tableView.reloadData()
        }
        super.viewDidLoad()
    }
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.allTimeCounty.isEmpty == true{
            return 0
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "countyLineCell", for: indexPath) as! CountyAllLineTableViewCell
            cell.selectionStyle = .none
            if self.allTimeCounty.isEmpty == true{
                return cell
            }
            cell.setLineChart(str: self.dates, values: self.allTimeCounty)
            cell.chartTitle.text = "All-Time Cases"
            cell.chartTitle.textColor = .lightText
            cell.yaxis.text = "Cases"
            cell.yaxis.transform = CGAffineTransform(rotationAngle: 3 * CGFloat.pi / 2)
            cell.yaxis.textColor = .lightText

            return cell
        }
        else{
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "countyBarCell", for: indexPath) as! CountyAllBarTableViewCell
            cell2.selectionStyle = .none
            if self.allTimeCounty.isEmpty == true{
                return cell2
            }
            cell2.setBarChart(str: self.dates, values: self.dailyAllCounty)
            cell2.chartTitle.text = "Daily Cases"
            cell2.chartTitle.textColor = .lightText
            cell2.yaxis.text = "Cases"
            cell2.yaxis.transform = CGAffineTransform(rotationAngle: 3 * CGFloat.pi / 2)
            cell2.yaxis.textColor = .lightText

            return cell2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.height;
    }
    

    func getFirestoreData(){
        self.group.enter()
        Firestore.firestore().collection("Counties").document("\(String(allTime ?? "Texas Total"))").getDocument { (document, error) in
            if let document = document {
                self.group.leave()
                self.allTimeCounty = document["Trend_Cases"] as? Array ?? []
    //               for i in dog.count-31...dog.count-1{
    //                   self.allTimeCounty.append(dog[i] as! Double)
    //               }
                
    //               countyCollection = Firestore.firestore().collection("Counties").order(by: "Cases", descending: true)
    //               citiesRef.orderBy("name", "desc").limit(3)
            for i in 0...self.allTimeCounty.count - 2{
                    let cnt = (self.allTimeCounty[i+1]-self.allTimeCounty[i])
                    if cnt < 20000{
                        self.dailyAllCounty.append(cnt)
                    }
                }
                if self.cnt == 1{
                    self.tableView.reloadData()
                }
            }
            else if let err = error{
                debugPrint("Error: \(err)")
            }
        }
    }


}
