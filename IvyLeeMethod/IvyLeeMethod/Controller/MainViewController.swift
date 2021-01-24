//
//  MainViewController.swift
//  IvyLeeMethod
//
//  Created by Mercy on 2021/01/24.
//

import UIKit
import GoogleMobileAds
import RealmSwift
import CalculateCalendarLogic

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {
    
    @IBOutlet weak var prevDay: UIButton!
    @IBOutlet weak var nextDay: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var taskTable: UITableView!
    
    let log = Logger()
    let db = Common()

    /// 現在の日付
    var currentDate = ""
    
    /// 現在のタスク内容
    var currentTask = [String]()
    
    /// 現在のタスク状態
    var currentTaskFlg = [Bool]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debugLog("#############################")
        log.debugLog("##### APPLICATION START #####")
        log.debugLog("#############################")
        
        currentDate = db.getTodayDate()
        dateLabel.text = currentDate
        
        // Realmインスタンス生成
        if (db.isRealmData(currentDate)) {
            // 現在日付のRealmデータが存在している場合はデータを取得
            let todayRealmData:DataBase = db.getRealmData(currentDate) as! DataBase
            
            setCurrentData(todayRealmData)
            
            /*
            for i in 0..<todayRealmData.missionInfoList.count {
                missionList.insert(todayRealmData.missionInfoList[i].title, at: self.missionList.endIndex)
                isCheckList.insert(todayRealmData.missionInfoList[i].isCheck, at: isCheckList.endIndex)
            }
            realmCount = todayRealmData.missionInfoList.count
             */
        } else {
            // Realmデータ生成
            db.createRealmData(currentDate)
        }
        
    }
    
    /// TableViewの行数 6行固定
    /// セル生成時に呼び出される
    /// - Parameters:
    ///   - tableView: <#tableView description#>
    ///   - section: <#section description#>
    /// - Returns: 行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    /// セル生成
    /// - Parameters:
    ///   - tableView: <#tableView description#>
    ///   - indexPath: <#indexPath description#>
    /// - Returns: セルインスタンス
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルの取得(再利用)
        let cell = taskTable.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath)
        
        // ミッション内容をカスタムセルの Label(tag2)に設定
        let cellLabel = cell.viewWithTag(2) as! UILabel
        cellLabel.text = missionList[indexPath.row]
        
        // カスタムセルのボタン(tag1)をunCkeckMarkに設定
        if (cell.viewWithTag(1) as? UIButton) != nil {
            let cellButton = cell.viewWithTag(1) as! UIButton

            // true/falseで画像切り替え
            if (isCheckList[indexPath.row] == true) {
                cellButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            } else {
                cellButton.setImage(UIImage(systemName: "circle"), for: .normal)
            }
                
            // カスタムセルのボタンをタップした時にcallするメソッドを設定
            // * チェック/アンチェックを切り替える
            cellButton.addTarget(self, action: #selector(checkButton(_:)), for: .touchUpInside)

        } else {
            log.errorLog("cell.viewWithTag(1) is nil.")
        }
        return cell
    }
    
    /// Realmデータを現在の情報に設定
    /// + currentDate
    /// +
    /// - Parameter data: <#data description#>
    func setCurrentData(_ realmData:DataBase) {
        
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
}
