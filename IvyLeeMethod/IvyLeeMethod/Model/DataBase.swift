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
    func getRealmData(_ dateStr:String) -> Any {
        log.debugLog("start [\(dateStr)]")
        var data = DataBase()
        
        do {
            let realm =  try Realm()
            data = realm.objects(DataBase.self).filter("date == '\(dateStr)'").first!
        } catch {
            log.errorLog("get RealmData failed.")
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
}
