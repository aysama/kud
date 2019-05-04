//
//  AccountsVC.swift
//  kud
//
//  Created by Samagbeyi Ayoola on 29/04/2019.
//  Copyright © 2019 Me. All rights reserved.
//

import UIKit
import SwiftChart


class AccountsVC: UIViewController, ChartDelegate {
    
    //Mark:- Chart Outlets
    @IBOutlet weak var chartlabel: UILabel!
    @IBOutlet weak var chart: Chart!
    fileprivate var labelLeadingMarginInitialConstant: CGFloat!
    
    //Mark:- TableView & Collection Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mylabel: UILabel!
    
    //Mark:- Top Outlets
    @IBOutlet weak var thehiddenView: UIView!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var theBalance: UILabel!
    
    var selectedChart = 0
    var datasource = [AnyObject]()
    var sectioncount = [String: Int]()
    var mysectiondata = [String: [AnyObject]]()
    var sections = [String]()
    var months = [String]()
    var alltransDates = [String]()
    var allBalances = [Int]()
    var currentBalance: Int!
    var transText: String!
    var transDate: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Mark:- Deducted 40 (set as 20marginleft and 20marginright in the constraints) + 20 spacing between two cells
        let width = (view.frame.size.width - 60) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: 30)
        
        //Mark:- Set TableView Datasource and Delegate as Self
        tableView.dataSource = self
        tableView.delegate = self
        
        //Mark:- Read Data from JSON File (datasource.json)
        if let mynewdata = readJSONFromFile(fileName: "datasource") {

            do {
                self.datasource = mynewdata as! [AnyObject]
            }
            
            for i in 0...datasource.count-1 {
                self.currentBalance = datasource[0].value(forKey: "current_balance") as? Int
                self.theBalance.text = "₦" + String(self.currentBalance)
                
                let key:String = datasource[i].value(forKey: "transaction_date") as! String
                let key1:String = datasource[i].value(forKey: "transaction_month") as! String
                
                //Mark:- Create Balances & Dates Array
                let abd = datasource[i]
                let cbd = abd.value(forKey: "current_balance") as! Int
                self.allBalances.append(cbd)
                
                //Mark:- Set Section Count
                if let val = sectioncount[key] {
                    sectioncount[key] = val + 1
                } else {
                    sectioncount[key] = 1
                }
                
                //Mark:- Set Sections (Title)
                if sections.contains(key){
                    //Do Nothing
                } else {
                    sections.append(key)
                }
                
                //Mark:- Set Months Array
                if months.contains(key1){
                    //Do Nothing
                } else {
                    months.append(key1)
                }
                
                
            }
            
            //Mark:- Create Data Groups by Dates
            for i in 0...sections.count-1 {
                let sectiontitle = sections[i]
                var coldata = [AnyObject]()
                
                for i in 0...datasource.count-1 {
                    let key:String = datasource[i].value(forKey: "transaction_date") as! String
                    if key == sectiontitle {
                        coldata.append(datasource[i])
                    }
                }
                mysectiondata[sectiontitle] = coldata
            }
            
            
            print("sections:", sections)
            print("sectiondata:", mysectiondata)
        }
        
        initChart()
        hideStuff()
        
    }
    
}

//Mark:- Extension for UITableView Methods
extension AccountsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mysection = sections[section]
        //get sectiondata
        var sectiondata = [AnyObject]()
        for i in 0...datasource.count-1{
            let specdata = datasource[i]
            let key:String = datasource[i].value(forKey: "transaction_date") as! String
            
            if key == mysection {
                sectiondata.append(specdata)
            }
        }
        
        return sectiondata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! tableViewCell
        
        
        //get sectiondata
        let sectiontitle = sections[indexPath.section]
        let sectiondata = mysectiondata[sectiontitle]!
        
        // Configure the cell...
        let celldata = sectiondata[indexPath.row]
        let amt:Int = celldata.value(forKey: "transaction_amount") as! Int
        let type:String = celldata.value(forKey: "transaction_type") as! String
        let summary:String = celldata.value(forKey: "transaction_summary") as! String
        let time:String = celldata.value(forKey: "transaction_time") as! String
        let balance:Int = celldata.value(forKey: "current_balance") as! Int
        
        cell.txtLbl.text = summary
        cell.txt2Lbl.text = time
        cell.txt4Lbl.text = "₦" + String(balance)
        cell.txtLbl.textColor = .black
        cell.txt2Lbl.textColor = .lightGray
        if (type == "DR"){
            cell.txt3Lbl.text = "-₦" + String(amt)
            cell.txt3Lbl.textColor = .red
        } else {
            cell.txt3Lbl.text = "₦" + String(amt)
            cell.txt3Lbl.textColor = .black
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topVisibleIndexPath = indexPath
        let mysection = topVisibleIndexPath[0]
        let myrow = topVisibleIndexPath[1]
        let thesectiontitle = self.sections[mysection]
        let thesectiondata = self.mysectiondata[thesectiontitle]![myrow]
        print("thedata:", thesectiondata)
        let comparevalue:Int = thesectiondata.value(forKey: "current_balance") as! Int
        let theindex:Int = self.allBalances.firstIndex(of: comparevalue)!
        print("theindexstr:", theindex)
        
        DispatchQueue.main.async {
            self.didTouchChart(self.chart, indexes: [theindex], x: 100.00, left: 0)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let topVisibleIndexPath:IndexPath = self.tableView.indexPathsForVisibleRows![0]
        print("top=>", topVisibleIndexPath)
        
        let mysection = topVisibleIndexPath[0]
        let myrow = topVisibleIndexPath[1]
        let thesectiontitle = self.sections[mysection]
        let thesectiondata = self.mysectiondata[thesectiontitle]![myrow]
        print("thedata:", thesectiondata)
        let comparevalue:Int = thesectiondata.value(forKey: "current_balance") as! Int
        let theindex:Int = self.allBalances.firstIndex(of: comparevalue)!
        print("theindexstr:", theindex)
        
        DispatchQueue.main.async {
            self.didTouchChart(self.chart, indexes: [theindex], x: 100.00, left: 0)
        }
        
        checkScroll()
        
    }
    
    func checkScroll(){
        let topVisibleIndexPath:IndexPath = self.tableView.indexPathsForVisibleRows![0]
        let index:Int = topVisibleIndexPath[0]
        if (index == 0 || index == sections.count-1) {
            showStuff()
        } else {
            hideStuff()
        }
    }
    
    func hideStuff(){
        self.leftBtn.isHidden = true
        self.rightBtn.isHidden = true
        self.topLabel.isHidden = true
        self.theBalance.isHidden = false
        self.theBalance.text = "₦" + String(self.currentBalance)
    }
    
    func showStuff(){
        self.leftBtn.isHidden = false
        self.rightBtn.isHidden = false
        self.theBalance.isHidden = true
        self.topLabel.isHidden = false
        self.topLabel.text = "₦" + String(self.currentBalance)
    }
}

//Mark:- Function to Read JSON from File
extension AccountsVC {
    func readJSONFromFile(fileName: String) -> Any?
    {
        var json: Any?
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                json = try? JSONSerialization.jsonObject(with: data)
            } catch {
                // Handle error here
            }
        }
        return json
    }
}

//Mark:- Extension for Chart Functions
extension AccountsVC {
    func initChart(){
        chart.delegate = self
        chart.showYLabelsAndGrid = false
        chart.showXLabelsAndGrid = false
        // Initialize data series and labels
        let stockValues = getStockValues()
        
        var serieData: [Double] = []
        var labels: [Double] = []
        var labelsAsString: Array<String> = []
        
        // Date formatter to retrieve the month names
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        
        for (i, value) in stockValues.enumerated() {
            
            serieData.append(value["current_balance"] as! Double)
            
            // Use only one label for each month
            let month = Int(dateFormatter.string(from: value["date"] as! Date))!
            let monthAsString:String = dateFormatter.monthSymbols[month - 1]
            if (labels.count == 0 || labelsAsString.last != monthAsString) {
                labels.append(Double(i))
                labelsAsString.append(monthAsString)
            }
        }
        
        let series = ChartSeries(serieData)
        series.area = true
        
        // Configure chart layout
        
        chart.lineWidth = 1.5
        chart.gridColor = UIColor.clear
        chart.labelFont = UIFont.systemFont(ofSize: 12)
        chart.xLabels = labels
        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
            return labelsAsString[labelIndex]
        }
        chart.xLabelsTextAlignment = .center
        chart.yLabelsOnRightSide = false
        // Add some padding above the x-axis
        chart.minY = serieData.min()! - 5
        
        chart.add(series)
    }
    
    // Chart delegate
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumFractionDigits = 2
            numberFormatter.maximumFractionDigits = 2
            let textA = numberFormatter.string(from: NSNumber(value: value))
            print("myval=>", textA!)
            let intval = Int(value)
            let strval = String(intval)
            self.transText = strval
            print("A", self.transText!)
            let ab = self.getdate(amt: intval)
            print("ab:", ab)
            self.transDate = ab
            
        }
        
        mylabel.layer.borderWidth = 0.25
        mylabel.layer.cornerRadius = 20
        mylabel.layer.borderColor = UIColor.lightGray.cgColor
        mylabel.text = "\(self.transDate!) | ₦" + self.transText!
        
        DispatchQueue.main.async {
            var thesection:Int!
            var therow:Int!
            
            for i in 0...self.mysectiondata.count-1{
                let key:String = self.transDate!
                let indexzero:Int = self.sections.firstIndex(of: self.transDate!) as! Int
                thesection = indexzero
                
                let firstkey = self.sections[indexzero] as! String
                
                let indexdata = self.mysectiondata[firstkey]
                print("indexdata:",indexdata)

                for i in 0...indexdata!.count-1 {
                    let bb:String = indexdata![i].value(forKey: "transaction_date") as! String
                    if (bb == key){
                        print("b", i)
                        therow = i ?? 0
                    }
                }
            }
            
            let sec:String = self.sections[thesection]
            self.collectionViewWork(sec: sec)
            self.moveToRow(therow: therow, thesection: thesection)
        }
        
    }
    
    func getdate(amt: Int)->String{
        var returnval:String!
        for i in 0...datasource.count-1{
            let key:Int = datasource[i].value(forKey: "current_balance") as! Int
            let date:String = datasource[i].value(forKey: "transaction_date") as! String
            print("key is \(key) and amt is \(amt)")
            if key == amt {
                returnval = date
            }
        }
        return returnval ?? "N/A"
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        self.hideStuff()
        //labelLeadingMarginConstraint.constant = labelLeadingMarginInitialConstant
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
    
    
    func getStockValues() -> Array<Dictionary<String, Any>> {
        
        // Read the JSON file
        let filePath = Bundle.main.path(forResource: "AAPL", ofType: "json")!
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        let json: NSDictionary = (try! JSONSerialization.jsonObject(with: jsonData!, options: [])) as! NSDictionary
        let jsonValues = json["quotes"] as! Array<NSDictionary>
        
        // Parse data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let values = jsonValues.map { (value: NSDictionary) -> Dictionary<String, Any> in
            let date = dateFormatter.date(from: value["date"]! as! String)
            let close = (value["current_balance"]! as! NSNumber).doubleValue
            return ["date": date!, "current_balance": close]
        }
        
        return values
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        // Redraw chart on rotation
        chart.setNeedsDisplay()
    }
    
    func moveToRow(therow: Int, thesection: Int){
        let indexPath = NSIndexPath(row: therow, section: thesection)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        checkScroll()
    }
    
    func collectionViewWork(sec: String){
        if sec.contains("April"){
            let cvCell = collectionView.cellForItem(at: [0, 0]) as! collectionViewCell
            cvCell.coLabel.textColor = UIColor.black
            let cvCell1 = collectionView.cellForItem(at: [0, 1]) as! collectionViewCell
            let cvCell2 = collectionView.cellForItem(at: [0, 2]) as! collectionViewCell
            cvCell1.coLabel.textColor = UIColor.lightGray
            cvCell2.coLabel.textColor = UIColor.lightGray
        } else if sec.contains("March"){
            let cvCell = collectionView.cellForItem(at: [0, 1]) as! collectionViewCell
            cvCell.coLabel.textColor = UIColor.black
            let cvCell1 = collectionView.cellForItem(at: [0, 0]) as! collectionViewCell
            let cvCell2 = collectionView.cellForItem(at: [0, 2]) as! collectionViewCell
            cvCell1.coLabel.textColor = UIColor.lightGray
            cvCell2.coLabel.textColor = UIColor.lightGray
        } else {
            let cvCell = collectionView.cellForItem(at: [0, 2]) as! collectionViewCell
            cvCell.coLabel.textColor = UIColor.black
            let cvCell1 = collectionView.cellForItem(at: [0, 1]) as! collectionViewCell
            let cvCell2 = collectionView.cellForItem(at: [0, 0]) as! collectionViewCell
            cvCell1.coLabel.textColor = UIColor.lightGray
            cvCell2.coLabel.textColor = UIColor.lightGray
        }
    }
    
}

extension AccountsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cvCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cvcell", for: indexPath) as? collectionViewCell
        //cvCell?.layer.borderWidth = 1
        //cvCell?.layer.borderColor = UIColor.lightGray.cgColor
        cvCell?.coLabel.text = months[indexPath.row]
        cvCell?.coLabel.textColor = UIColor.lightGray
        return cvCell!
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cvCell = collectionView.cellForItem(at: indexPath) as! collectionViewCell
//        cvCell.coLabel.text = months[indexPath.row]
//        cvCell.coLabel.textColor = UIColor.black
//    }
    
}

