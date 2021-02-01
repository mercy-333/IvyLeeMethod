//
//  DataBase.swift
//  IvyLeeMethod
//
//  Created by Mercy on 2021/01/24.
//

import Foundation
import RealmSwift

class DataBase: Object {
    @objc dynamic var date:String = "" //日付    String    yyyymmmdd    主キー
    @objc dynamic var task1:String = "" //タスク1の内容    String    〇〇する
    @objc dynamic var task2:String = "" //タスク2の内容    String    〇〇する
    @objc dynamic var task3:String = "" //タスク3の内容    String    〇〇する
    @objc dynamic var task4:String = "" //タスク4の内容    String    〇〇する
    @objc dynamic var task5:String = "" //タスク5の内容    String    〇〇する
    @objc dynamic var task6:String = "" //タスク6の内容    String    〇〇する
    @objc dynamic var taskFlg1:Bool = false //タスク1の状態フラグ    Bool    True:達成 False:未達成
    @objc dynamic var taskFlg2:Bool = false //タスク2の状態フラグ    Bool    True:達成 False:未達成
    @objc dynamic var taskFlg3:Bool = false //タスク3の状態フラグ    Bool    True:達成 False:未達成
    @objc dynamic var taskFlg4:Bool = false //タスク4の状態フラグ    Bool    True:達成 False:未達成
    @objc dynamic var taskFlg5:Bool = false //タスク5の状態フラグ    Bool    True:達成 False:未達成
    @objc dynamic var taskFlg6:Bool = false //タスク6の状態フラグ    Bool    True:達成 False:未達成
    @objc dynamic var completeFlg:Bool = false // その日のタスクを全部達成したか    Bool    True:達成 False:未達成
    
    // 主キー設定
    override class func primaryKey() -> String? {
        return "date"
    }
}

class Common {
    
    let log = Logger()
    
    init(){
        log.debugLog("DataBase initialized.")
    }
    
    /// 呼び出した時の日付の文字列を取得する
    /// - Returns: 日付の文字列 (yyyymmdd)
    func getTodayDate()->String{
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        return df.string(from: date)
    }
    
    /// 指定した日付(yyyymmdd)の前後の日付文字列を取得する
    /// - Parameters:
    ///   - currentDateStr: ベースの日付 (yyyymmdd)
    ///   - changeDayNum: 変更する日数(2:明後日 1:明日 / -1:昨日)
    /// - Returns: 変更後の日付の文字列 (yyyymmdd)
    func getSelectDate(_ currentDateStr:String, changeDayNum:Int)->String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let currentDate = df.date(from: currentDateStr)
        let modDate = Calendar.current.date(byAdding: .day, value: changeDayNum, to:currentDate!)
        let modDateStr = df.string(from: modDate!)
        
        log.debugLog("currentDate[\(currentDateStr)] modDate[\(modDateStr)]")
        return modDateStr
    }
    
    /// 指定した日付のRealmデータが存在するかを判定
    /// - Parameter dateStr: 日付 (ex)"20201231"
    /// - Returns: True(データあり) / False(データなし)
    func isRealmData(_ dateStr:String) ->Bool {
        log.debugLog("start [\(dateStr)]")
        do {
            let realmCheck = try Realm()
            let todayRealm = realmCheck.objects(DataBase.self).filter("date == '\(dateStr)'")
            if (todayRealm.count > 0) {
                log.debugLog("RealmData is exist.")
                return true
            } else {
                log.debugLog("RealmData is NOT exist.")
                return false
            }
        } catch  {
            log.errorLog("check RealmData failed.")
            return false
        }
    }
    
    /// 指定した日付のRealmファイルデータを取得
    /// - Parameter dateStr: 日付 (ex)"20201231"
    /// - Returns: Realmデータ
    func readRealmData(_ dateStr:String) -> Any {
        log.debugLog("start [\(dateStr)]")
        var data = DataBase()
        
        do {
            let realm =  try Realm()
            data = realm.objects(DataBase.self).filter("date == '\(dateStr)'").first!
        } catch {
            log.errorLog("read RealmData failed.")
        }
        return data
    }
    
    /// 指定した日付のRealmファイルデータを生成
    /// - Parameter dateStr: 日付 (ex)"20201231"
    func createRealmData(_ dateStr:String) {
        log.debugLog("start [\(dateStr)]")
        do {
            let realm = try! Realm()
            let database = DataBase()
            database.date = dateStr
            try realm.write {
                realm.add(database)
            }
        } catch {
            log.errorLog("create RealmData failed.")
        }
    }
    
    /// タスク内容をRealmデータに書き込む
    /// - Parameters:
    ///   - dateStr: 日付 (ex)"20201231"
    ///   - taskNum: タスク番号
    ///   - text: タスク内容
    func writeRealmTask(_ dateStr:String,_ taskNum:Int,_ text:String) {
        log.debugLog("start. Date[\(dateStr)],TaskNum[\(taskNum)],Text[\(text)]")
        
        if ( 8 != dateStr.utf16.count) {
            log.errorLog("invalid date.")
        } else if (taskNum < 0 || 6 < taskNum) {
            log.errorLog("invalid task number.")
        } else {
            do {
                let realm =  try Realm()
                let results = realm.objects(DataBase.self).filter("date == '\(dateStr)'").first
                try! realm.write {
                    switch taskNum {
                        case 1:
                            results?.task1 = text
                        case 2:
                            results?.task2 = text
                        case 3:
                            results?.task3 = text
                        case 4:
                            results?.task4 = text
                        case 5:
                            results?.task5 = text
                        case 6:
                            results?.task6 = text
                        default:
                            log.debugLog("[\(taskNum)] is invalid.")
                    }
                }
            } catch {
                log.errorLog("write RealmData failed.")
            }
        }
    }
    
    /// タスク状態をRealmデータに書き込む
    /// - Parameters:
    ///   - dateStr: 日付 (ex)"20201231"
    ///   - taskNum: タスク番号
    ///   - state: タスク状態
    func writeRealmTaskFlg(_ dateStr:String,_ taskNum:Int,_ state:Bool) {
        log.debugLog("start. Date[\(dateStr)],TaskNum[\(taskNum)],State[\(state)]")
        
        if ( 8 != dateStr.utf16.count) {
            log.errorLog("invalid date.")
        } else if (taskNum < 0 || 6 < taskNum) {
            log.errorLog("invalid task number.")
        } else {
            do {
                let realm =  try Realm()
                let results = realm.objects(DataBase.self).filter("date == '\(dateStr)'").first
                try! realm.write {
                    switch taskNum {
                        case 1:
                            results?.taskFlg1 = state
                        case 2:
                            results?.taskFlg2 = state
                        case 3:
                            results?.taskFlg3 = state
                        case 4:
                            results?.taskFlg4 = state
                        case 5:
                            results?.taskFlg5 = state
                        case 6:
                            results?.taskFlg6 = state
                        default:
                            log.debugLog("[\(taskNum)] is invalid.")
                    }
                }
            } catch {
                log.errorLog("write RealmData failed.")
            }
        }
    }
}
