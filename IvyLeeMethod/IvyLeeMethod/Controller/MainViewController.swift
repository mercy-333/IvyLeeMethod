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

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate  {
    
    @IBOutlet weak var prevDay: UIButton!
    @IBOutlet weak var nextDay: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var taskTable: UITableView!
    
    let log = Logger()
    let db  = Common()
    
    var currentDate = "" /// 現在の日付
    var currentTask: Array<String> = ["","","","","",""] /// 現在のタスク内容
    var currentTaskFlg: Array<Bool> = [false,false,false,false,false,false] /// 現在のタスク状態
    
    override func viewDidLoad() {
        log.debugLog("#####################")
        log.debugLog("# APPLICATION START #")
        log.debugLog("#####################")
        super.viewDidLoad()
        taskTable.delegate = self
        taskTable.dataSource = self
        taskTable.rowHeight = UITableView.automaticDimension
        taskTable.estimatedRowHeight = 10000
        

        
        // 当日日付を設定
        currentDate = db.getTodayDate()
        dateLabel.text = currentDate
        
        // 現在日付のRealmデータを取得 / 無かったら生成
        if (db.isRealmData(currentDate)) {
            setCurrentData(db.readRealmData(currentDate) as! DataBase)
        } else {
            db.createRealmData(currentDate)
        }
    }
    
    /// TableViewセル数 6行固定
    /// - Returns: 行数
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
            
        // カスタムセルのボタンをタップした時にcallするメソッドを設定
        // * チェック/アンチェックを切り替える
        //cellButton.addTarget(self, action: #selector(checkButton(_:)), for: .touchUpInside)
        
        // [3] タスク内容をTextViewに設定
        let cTask = cell.viewWithTag(3) as! UITextView
        cTask.text = currentTask[indexPath.row]
        cTask.delegate = self
        
        // 過去のタスク内容は修正させないため、非活性にする
        if (currentDate < db.getTodayDate()) {
            cTask.isEditable = false // 非活性
        } else {
            cTask.isEditable = true  // 活性
        }
        
        // TextView編集時のキーボードに[スペース][Doneボタン]を配置
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(commitButtonTapped))
        toolBar.items = [spacer, commitButton]
        cTask.inputAccessoryView = toolBar
        
        return cell
    }
    
    /// Doneボタン押下時の処理 TextView編集を終了する
    @objc func commitButtonTapped() {
        self.view.endEditing(true)
    }
    
    /// タスク内容が更新される度に呼び出し
    /// 行幅を動的にするため TableViewの更新を実施
    /// - Parameter textView:
    func textViewDidChange(_ textView: UITextView) {
        taskTable.beginUpdates()
        taskTable.endUpdates()
    }
    
    /// タスク内容の編集が終わったタイミングで呼び出し
    /// Realmデータのタスク内容を更新する
    /// - Parameter textView:
    func textViewDidEndEditing(_ textView: UITextView) {
        
        guard let text = textView.text else {
            log.errorLog("sender.text is nil.")
            return
        }

        let buttonPosition = textView.convert(CGPoint(), to: self.taskTable)
        if let getIndexPath = self.taskTable.indexPathForRow(at:buttonPosition) {
            let taskNum = getIndexPath.row + 1
            log.debugLog("TextView updated. Task\(taskNum) [\(text)]")
            db.writeRealmTask(currentDate, taskNum, text)
        }
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
}
