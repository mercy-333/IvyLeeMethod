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
    

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    let log = Logger()
    let db  = Common()
    
    var currentDate: String = "" /// 現在の日付
    var currentTask: Array<String> = ["","","","","",""] /// 現在のタスク内容
    var currentTaskFlg: Array<Bool> = [false,false,false,false,false,false] /// 現在のタスク状態
    
    override func viewDidLoad() {
        log.debugLog("#####################")
        log.debugLog("# APPLICATION START #")
        log.debugLog("#####################")
        
        super.viewDidLoad()
        loadAdmob()
        
        taskTable.delegate = self
        taskTable.dataSource = self
        taskTable.rowHeight = UITableView.automaticDimension
        taskTable.estimatedRowHeight = 10000
        
        // 当日日付を設定
        currentDate = db.getTodayDate()
        dateLabel.text = currentDate
        
        loadData()
    }
    
    /// TableViewセル数  7~10個目はダミー
    /// - Returns: 行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
        
        // 7個目以降のセルはダミーなので非表示
        if (indexPath.row >= 6) {
            cell.viewWithTag(1)?.isHidden = true
            cell.viewWithTag(2)?.isHidden = true
            cell.viewWithTag(3)?.isHidden = true
            return cell
        } else {
            cell.viewWithTag(1)?.isHidden = false
            cell.viewWithTag(2)?.isHidden = false
            cell.viewWithTag(3)?.isHidden = false
        }
        
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
        cButton.addTarget(self, action: #selector(checkButton(_:)), for: .touchUpInside)
        
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
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(doneButtonTapped))
        toolBar.items = [spacer, doneButton]
        cTask.inputAccessoryView = toolBar
        
        return cell
    }
    
    // カスタムセル内のチェックボックスをタップ
    // チェックボックス画像を切り替える
    @objc func checkButton(_ sender:UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: self.taskTable)
        if let getIndexPath = self.taskTable.indexPathForRow(at:buttonPosition) {
            let taskNum = getIndexPath.row + 1
            
            // [true]->[false]
            if (currentTaskFlg[taskNum-1]) {
                sender.setImage(UIImage(systemName: "circle"), for: .normal)
                (currentTaskFlg[taskNum-1]) = false
                db.writeRealmTaskFlg(currentDate, taskNum, false)
            
            // [false]->[true]
            } else {
                sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
                (currentTaskFlg[taskNum-1]) = true
                db.writeRealmTaskFlg(currentDate, taskNum, true)
            }
        }
    }
    
    /// Doneボタン押下時の処理 TextView編集を終了する
    @objc func doneButtonTapped() {
        self.view.endEditing(true)
    }
    
    /// タスク内容の編集を開始したタイミングで呼び出す
    /// TableViewのセルのスクロール位置を4/5/6個目は上にずらす
    /// - Parameter textView:
    func textViewDidBeginEditing(_ textView: UITextView) {
        let buttonPosition = textView.convert(CGPoint(), to: self.taskTable)
        if let getIndexPath = self.taskTable.indexPathForRow(at:buttonPosition) {
            if (getIndexPath.row > 2) {
                let row = IndexPath(row:getIndexPath.row - 2, section:0)
                taskTable.scrollToRow(at: row, at: .top, animated: true)
            }
        }
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
            loadData()
        }
        // TableViewセルのスクロール位置を一番上に戻しておく
        taskTable.reloadData()
        taskTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        log.debugLog("Task editing done.")
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
    
    /// 前日ボタン
    /// currentDate"YYYYMMDD"の1日前に変更、Realmデータを読み込んで更新する
    /// - Parameter sender:
    @IBAction func prevDay(_ sender: Any) {
        currentDate = db.getSelectDate(currentDate, changeDayNum: -1)
        dateLabel.text = currentDate
        loadData()
    }
    
    /// 翌日ボタン
    /// - Parameter sender:
    @IBAction func nextDay(_ sender: Any) {
        currentDate = db.getSelectDate(currentDate, changeDayNum: 1)
        dateLabel.text = currentDate
        loadData()
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
    
    func loadAdmob() {
        let filePath = Bundle.main.path(forResource: "AdMobInfo", ofType: "plist")
        let plist = NSDictionary(contentsOfFile: filePath!)
        //bannerView.adUnitID = plist!["adUnitID_banner1"] as? String
        bannerView.adUnitID = plist!["adUnitID_TEST"] as? String
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        log.debugLog("Admob loaded.")
    }
    
}
