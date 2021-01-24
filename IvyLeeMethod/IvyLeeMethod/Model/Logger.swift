//
//  Logger.swift
//  IvyLeeMethod
//
//  Created by Mercy on 2021/01/24.
//

import Foundation

class Logger {
    
    /// デバッグログを出力
    /// - Parameters:
    ///   - message: 出力文字列
    ///   - function: 呼び出し元関数名
    ///   - file: 呼び出し元関数のソースファイル名
    ///   - line: 行数
    func debugLog(_ message: String = "", function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = URL(string: file)!.lastPathComponent
        print("#[DEBUG] \(fileName) #\(line) \(function): \(message)")
    }
    
    /// エラーログを出力
    /// - Parameters:
    ///   - message: 出力文字列
    ///   - function: 呼び出し元関数名
    ///   - file: 呼び出し元関数のソースファイル名
    ///   - line: 行数
    func errorLog(_ message: String = "", function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = URL(string: file)!.lastPathComponent
        print("#[ERROR] \(fileName) #\(line) \(function): \(message)")
    }
    
}
