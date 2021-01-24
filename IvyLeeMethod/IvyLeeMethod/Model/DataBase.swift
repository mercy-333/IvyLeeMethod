//
//  DataBase.swift
//  IvyLeeMethod
//
//  Created by Mercy on 2021/01/24.
//

import Foundation
import RealmSwift

class DataBase: Object {
    @objc dynamic var date = "" //日付    String    yyyymmmdd    主キー
    @objc dynamic var task1 = "" //タスク1の内容    String    〇〇する
    @objc dynamic var task2 = "" //タスク2の内容    String    〇〇する
    @objc dynamic var task3 = "" //タスク3の内容    String    〇〇する
    @objc dynamic var task4 = "" //タスク4の内容    String    〇〇する
    @objc dynamic var task5 = "" //タスク5の内容    String    〇〇する
    @objc dynamic var task6 = "" //タスク6の内容    String    〇〇する
    @objc dynamic var taskFlg1 = "" //タスク1の状態フラグ    Bool    True:達成 False:未達成
    @objc dynamic var taskFlg2 = "" //タスク2の状態フラグ    Bool    True:達成 False:未達成
    @objc dynamic var taskFlg3 = "" //タスク3の状態フラグ    Bool    True:達成 False:未達成
    @objc dynamic var taskFlg4 = "" //タスク4の状態フラグ    Bool    True:達成 False:未達成
    @objc dynamic var taskFlg5 = "" //タスク5の状態フラグ    Bool    True:達成 False:未達成
    @objc dynamic var taskFlg6 = "" //タスク6の状態フラグ    Bool    True:達成 False:未達成
    @objc dynamic var completeFlg = false // その日のタスクを全部達成したか    Bool    True:達成 False:未達成
    
    // 主キー設定
    override class func primaryKey() -> String? {
        return "date"
    }
}

class Common {
    
    let Log = Logger()
    
    init(){
        Log.debugLog("DataBase initialized.")
    }
    
}
