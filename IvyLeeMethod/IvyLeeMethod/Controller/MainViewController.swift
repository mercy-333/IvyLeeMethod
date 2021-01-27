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
    let db  = Common()
    
    var currentDate = ""          /// 現在の日付
    var currentTask = [String]()  /// 現在のタスク内容
    var currentTaskFlg = [Bool]() /// 現在のタスク状態
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debugLog("#####################")
        log.debugLog("# APPLICATION START #")
        log.debugLog("#####################")
        
        taskTable.delegate = self
        taskTable.dataSource = self
        
        currentDate = db.getTodayDate()
        dateLabel.text = currentDate
        
        // 現在日付のRealmデータを取得 / 無かったら生成
        if (db.isRealmData(currentDate)) {
            setCurrentData(db.getRealmData(currentDate) as! DataBase)
        } else {
            db.createRealmData(currentDate)
        }
    }
    
    /// TableViewの行数 6行固定
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
            
        // カスタムセルのボタンをタップした時にcallするメソッドを設定
        // * チェック/アンチェックを切り替える
        //cellButton.addTarget(self, action: #selector(checkButton(_:)), for: .touchUpInside)
        
        // [3] タスク内容をTextFieldに設定
        let cTask = cell.viewWithTag(3) as! UILabel
        cTask.text = currentTask[indexPath.row]
        
        return cell
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
        
        currentTask.insert(realmData.task1, at: currentTask.endIndex)
        currentTask.insert(realmData.task2, at: currentTask.endIndex)
        currentTask.insert(realmData.task3, at: currentTask.endIndex)
        currentTask.insert(realmData.task4, at: currentTask.endIndex)
        currentTask.insert(realmData.task5, at: currentTask.endIndex)
        currentTask.insert(realmData.task6, at: currentTask.endIndex)

        currentTaskFlg.insert(realmData.taskFlg1, at: currentTaskFlg.endIndex)
        currentTaskFlg.insert(realmData.taskFlg2, at: currentTaskFlg.endIndex)
        currentTaskFlg.insert(realmData.taskFlg3, at: currentTaskFlg.endIndex)
        currentTaskFlg.insert(realmData.taskFlg4, at: currentTaskFlg.endIndex)
        currentTaskFlg.insert(realmData.taskFlg5, at: currentTaskFlg.endIndex)
        currentTaskFlg.insert(realmData.taskFlg6, at: currentTaskFlg.endIndex)
    }
}
