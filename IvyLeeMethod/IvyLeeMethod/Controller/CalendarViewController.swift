//
//  CalendarViewController.swift
//  IvyLeeMethod
//
//  Created by Mercy on 2021/02/07.
//

import UIKit
import GoogleMobileAds
import RealmSwift
import CalculateCalendarLogic
import FSCalendar

/// カレンダー画面の制御
class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var taskTable: UITableView!
    
    let log = Logger()
    let db  = Common()
    
    var currentDate: String = "" /// 現在の日付(タップした日付)
    var currentTask: Array<String> = ["","","","","",""] /// 現在のタスク内容
    var currentTaskFlg: Array<Bool> = [false,false,false,false,false,false] /// 現在のタスク状態
    
    /*----------------------*/
    /* ViewDidLoad          */
    /*----------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debugLog("#############################")
        log.debugLog("##### Calender Screen   #####")
        log.debugLog("#############################")
        
        // デリゲートの設定
        self.taskTable.dataSource = self
        self.taskTable.delegate = self
        self.calendar.dataSource = self
        self.calendar.delegate = self
        calendarSetting()
        currentDate = db.getTodayDate()
        loadData()
    }
    
    
    /// 本画面に遷移した時に毎回呼ばれる
    /// *TableViewを再読み込みする
    /// - Parameter animated:
    override func viewWillAppear(_ animated: Bool) {
        initCurrentData()
        loadData()
        calendar.reloadData()
    }
    
    /// カレンダーにイメージを表示
    /// * completeFlg=True の時、王冠を表示
    /// - Parameters:
    ///   - calendar:
    ///   - date:
    /// - Returns: 表示画像
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let dateStr = db.stringFromDate(date: date, format: "yyyyMMdd")
        
        if (db.isRealmData(dateStr)) {
            let data:DataBase = db.readRealmData(dateStr) as! DataBase
            // 王冠を表示
            if (data.completeFlg) {
                return UIImage(systemName: "crown.fill")
            }
        }
        return nil
    }
    
    /// カレンダーにドットをつける
    /// - Parameters:
    ///   - calendar:
    ///   - date: カレンダーの月単位ページ描画時に１ヶ月分の日付が格納されて、日付の数だけこの関数が呼ばれる
    /// - Returns: ドットの数
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateStr = db.stringFromDate(date: date, format: "yyyyMMdd")
        if (db.isRealmData(dateStr)) {
            if (!db.checkRealmDataDefault(dateStr)) {
                return 1
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    /// カレンダーの日付をタップした際に呼ばれる
    /// TableViewに情報を反映する
    /// - Parameters:
    ///   - calendar:
    ///   - date:
    ///   - monthPosition:カレンダーの月(前月:0 当月:1 次月:2)
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateStr = db.stringFromDate(date: date, format: "yyyyMMdd")
        log.debugLog("tapped. \(dateStr) / current:\(currentDate)")

        // 同じ日付を連続でタップした場合TableViewを更新しない
        if (currentDate != dateStr) {
            currentDate = dateStr
            initCurrentData()
            loadData()
        } else {
            log.debugLog("don't update.")
        }
        
    }
    
    /// TableViewのセル数を設定 6個固定
    /// - Parameters:
    ///   - tableView:
    ///   - section:
    /// - Returns: セル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    /// TableViewセル高さ
    /// - Parameters:
    ///   - tableView:
    ///   - indexPath:
    /// - Returns:自動設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    /// TableViewセル生成
    /// - Returns: セルインスタンス
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルの取得(再利用)
        let cell = taskTable.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath)
        
        // [1] タスク番号をラベルに設定
        let cTaskNum = cell.viewWithTag(1) as! UILabel
        cTaskNum.text = (indexPath.row + 1).description
        
        // [2] ボタンの画像(チェック/アンチェック)を設定
        let cButton = cell.viewWithTag(2) as! UIButton
        if (currentTaskFlg[indexPath.row] == true) {
            cButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        } else {
            cButton.setImage(UIImage(systemName: "circle"), for: .normal)
        }
        
        // [3] タスク内容をTextViewに設定
        let cTask = cell.viewWithTag(3) as! UITextView
        cTask.text = currentTask[indexPath.row]
        cTask.delegate = self
        cTask.isEditable = false // 非活性
        
        return cell
    }
    
    /// タスク内容を初期化する
    func initCurrentData() {
        for i in 0..<6 {
            currentTask[i] = ""
            currentTaskFlg[i] = false
        }
    }
        
    /// 現在日付のRealmデータを取得してTableViewに反映 / 無かったら生成
    func loadData() {
        if (db.isRealmData(currentDate)) {
            setCurrentData(db.readRealmData(currentDate) as! DataBase)
        } else {
            db.createRealmData(currentDate)
        }
        taskTable.reloadData()
    }
    
    /// Realmデータを読み込み 現在情報に設定
    /// * currentDate
    /// * currentTask
    /// * currentTaskFlg
    ///
    /// - Parameter data: 読み込むRealmデータ
    func setCurrentData(_ realmData:DataBase) {
        log.debugLog("RealmData is loading.")

        currentDate = realmData.date
        
        currentTask[0] = realmData.task1
        currentTask[1] = realmData.task2
        currentTask[2] = realmData.task3
        currentTask[3] = realmData.task4
        currentTask[4] = realmData.task5
        currentTask[5] = realmData.task6

        currentTaskFlg[0] = realmData.taskFlg1
        currentTaskFlg[1] = realmData.taskFlg2
        currentTaskFlg[2] = realmData.taskFlg3
        currentTaskFlg[3] = realmData.taskFlg4
        currentTaskFlg[4] = realmData.taskFlg5
        currentTaskFlg[5] = realmData.taskFlg6
    }
    
    /// カレンダー画面の個別設定. 曜日の日本語表記など
    func calendarSetting() {
        
        // 曜日
        calendar.calendarWeekdayView.weekdayLabels[0].text = "日"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "月"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "火"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "水"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "木"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "金"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "土"
        
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor.red
        calendar.calendarWeekdayView.weekdayLabels[1].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[2].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[3].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[4].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[5].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = UIColor.blue
    }
    
}
