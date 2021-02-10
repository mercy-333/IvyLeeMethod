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
    
    /// StringからDate型に変換
    /// - Parameters:
    ///   - string: 変換前の文字列 (sample) "2020/12/31 12:34:56 +09:00"
    ///   - format: 変換するフォーマット (sample) "yyyy/MM/dd HH:mm:ss Z"
    /// - Returns: Date型
    func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }

    /// Date型からStringに変換
    /// - Parameters:
    ///   - string: Date情報
    ///   - format: 変換するフォーマット (sample) "yyyy/MM/dd HH:mm:ss Z"
    /// - Returns: String型
    func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
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
        do {
            let realmCheck = try Realm()
            let todayRealm = realmCheck.objects(DataBase.self).filter("date == '\(dateStr)'")
            if (todayRealm.count > 0) {
                log.debugLog("[\(dateStr)] RealmData is exist.")
                return true
            } else {
                log.debugLog("[\(dateStr)] RealmData is NOT exist.")
                return false
            }
        } catch  {
            log.errorLog("[\(dateStr)] check RealmData failed.")
            return false
        }
    }
    
    /// 指定した日付のRealmデータが初期状態であるかを判定
    /// (初期状態の日はカレンダーにマークさせたくないため)
    /// タスク内容1~6とタスク状態1~6が全て""であれば、初期状態と判定
    /// - Parameter dateStr: 日付 (ex)"20201231"
    /// - Returns: True(初期状態である) / False(初期状態ではない)
    func checkRealmDataDefault(_ dateStr:String) ->Bool {
        var dataCnt:Int = 0
        
        // Realmデータ内を全部チェック
        do {
            let realmCheck = try Realm()
            let todayRealm = realmCheck.objects(DataBase.self).filter("date == '\(dateStr)'").first
            guard let realm = todayRealm else {
                log.errorLog("[] RealmData is nil.")
                return false
            }
            
            // データがあったらカウントアップ(1以上ならデータありと判断)
            if ("" != realm.task1) {dataCnt += 1}
            if ("" != realm.task2) {dataCnt += 1}
            if ("" != realm.task3) {dataCnt += 1}
            if ("" != realm.task4) {dataCnt += 1}
            if ("" != realm.task5) {dataCnt += 1}
            if ("" != realm.task6) {dataCnt += 1}

        } catch  {
            log.errorLog("check RealmData failed.")
            return false
        }

        // 判定
        if ( 0 == dataCnt) {
            log.debugLog("[\(dateStr)] data is default.")
            return true
        } else {
            log.debugLog("[\(dateStr)] data is NOT default.")
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
                    
                    // completeFlgの判定
                    if ( true == results?.taskFlg1 &&
                         true == results?.taskFlg2 &&
                         true == results?.taskFlg3 &&
                         true == results?.taskFlg4 &&
                         true == results?.taskFlg5 &&
                         true == results?.taskFlg6 ) {
                        results?.completeFlg = true
                        log.debugLog("Task Complete!")
                    } else {
                        results?.completeFlg = false
                    }
                }
            } catch {
                log.errorLog("write RealmData failed.")
            }
        }
    }
}
