//
//  Log.swift
//  Logging
//
//  Created by Creatrixe on 01/04/2019.
//  Copyright © 2019 macintosh. All rights reserved.
//

import Foundation
import HockeySDK

/// Enum which maps an appropiate symbol which added as prefix for each log message
///
/// - error: Log type error
/// - info: Log type info
/// - debug: Log type debug
/// - verbose: Log type verbose
/// - warning: Log type warning
/// - severe: Log type severe
enum LogEvent: String {
    case e = "[‼️]" // error
    case i = "[ℹ️]" // info
    case d = "[💬]" // debug
    case v = "[🔬]" // verbose
    case w = "[⚠️]" // warning
    case s = "[🔥]" // severe
}


/// Wrapping Swift.print() within DEBUG flag
///
/// - Note: *print()* might cause [security vulnerabilities](https://codifiedsecurity.com/mobile-app-security-testing-checklist-ios/)
///
/// - Parameter object: The object which is to be logged
///
public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let output = items.map { "\($0)" }.joined(separator: separator)
    Swift.print("Other Print: "+output, terminator: terminator)
}

public class Log: NSObject, BITHockeyManagerDelegate {
    public static let shared = Log()
    
    private let MAX_FILE_SIZE_IN_BYTES = 1024 * 1024
    private let MAX_FILES = 5
    private let SUBDIRECTORY_NAME = "logs"

    override init() {
        super.init()
        
        BITHockeyManager.shared().configure(withIdentifier: "46030c529fc1476089e6dddb735d3d2f", delegate: self)
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
    }
    
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    public var isLoggingEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - HockeyApp methods
    public func applicationLog(for crashManager: BITCrashManager!) -> String! {
        let description = getLogFilesContent()
        deleteAllLogFiles()
        if (description.count == 0) {
            return "No crash description available."
        } else {
            return description
        }
    }
    
    /// Appends the given string to the stream.
    func write(file: URL, _ string: String) {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
//        let documentDirectoryPath = paths.first!
        let log = file
        
//        if log.fileSize > MAX_FILE_SIZE_IN_BYTES {
//            //create new file and get its handle
//
//            //also unlink oldest file if count of log files > MAX_FILES
//        }
//        try? string.write(to: file, atomically: false, encoding: String.Encoding.utf8)
        do {
            let handle = try FileHandle(forWritingTo: log)
            handle.seekToEndOfFile()
            let stringData = "\n" + string
            handle.write(stringData.data(using: .utf8)!)
            handle.closeFile()
        } catch {
            print(error.localizedDescription)
            do {
                try string.data(using: .utf8)?.write(to: log)
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func getLogFilesContent() -> String {
        var description = ""
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let writePath = NSURL(fileURLWithPath: documentDirectory).appendingPathComponent(SUBDIRECTORY_NAME)
        //get files in Log folder
        var arrFileNameInt = [Int]()
        if let allItems = try? FileManager.default.contentsOfDirectory(atPath: writePath!.path) {
            for file in allItems{
                arrFileNameInt.append(Int(file)!)
            }
            
            arrFileNameInt = arrFileNameInt.sorted(by: { (first, second) -> Bool in
                first < second
            })
            
            for file in arrFileNameInt{
                let path = writePath?.appendingPathComponent(String(file))
                description += try! String(contentsOf: path!, encoding: .utf8)
            }
        }
        
        return description;
    }
    
    func deleteAllLogFiles(){
        let fileManager = FileManager.default
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let writePath = NSURL(fileURLWithPath: documentDirectory).appendingPathComponent(SUBDIRECTORY_NAME)
        //get files in Log folder
        if let allItems = try? FileManager.default.contentsOfDirectory(atPath: writePath!.path) {
            for file in allItems{
                let fileToDelete = writePath!.appendingPathComponent(file)
                try? fileManager.removeItem(atPath: fileToDelete.path)
            }
        }
    }
    
    // MARK: - Logging methods
//    public static func testCrash() {
//        let error = "Crashing the app from Logging Module"
//        Log.shared.i(error)
//
////        fatalError(error)
//    }
//    
//    public static func mqttResponseReceived(response: Any) {
//        Log.shared.d(response)
//    }
//    
//    public static func controllerPresented(controller: String) {
//        Log.shared.d("View Controller Presented: \(controller)")
//    }
//    
//    public static func applicationFunctionsTriggered(function: String) {
//        Log.shared.i("Function Triggered: \(function)")
//    }
    
    func getFileToWrite() -> URL {
        let fileManager = FileManager.default
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let writePath = NSURL(fileURLWithPath: documentDirectory).appendingPathComponent(SUBDIRECTORY_NAME)
        var arrItemNamesInt = [Int]()
        var fileUrl: URL!
        //get files in Log folder
        if let allItems = try? FileManager.default.contentsOfDirectory(atPath: writePath!.path) {
            for item in allItems{
                if item.hasPrefix("."){
                    continue
                }
                
                arrItemNamesInt.append(Int(item)!)
            }
            arrItemNamesInt = arrItemNamesInt.sorted(by: { (first, second) -> Bool in
                first < second
            })
            let lastFile = arrItemNamesInt.last ?? 0
            let lastFileString = String(lastFile)
            let lastFilePath = writePath!.appendingPathComponent(lastFileString)
            if lastFilePath.fileSize >= MAX_FILE_SIZE_IN_BYTES{
                //create a new file and return path
                let newFile = lastFile + 1
                arrItemNamesInt.append(newFile)
                fileUrl = writePath!.appendingPathComponent(String(newFile))
                if arrItemNamesInt.count > MAX_FILES{
                    while (arrItemNamesInt.count > MAX_FILES) {
                        let fileToDelete = writePath!.appendingPathComponent(String(arrItemNamesInt.first!))
                        try? fileManager.removeItem(atPath: fileToDelete.path)
                        arrItemNamesInt.removeFirst()
                    }
                }
            }
            else{
                fileUrl = lastFilePath
                //write in same file
            }
//            print(allItems)
            
        }
        if arrItemNamesInt.isEmpty {
            //create 0.txt file
            arrItemNamesInt.append(0)
//            let pathh = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//            let writePathh = NSURL(fileURLWithPath: pathh).appendingPathComponent(SUBDIRECTORY_NAME)
            try? FileManager.default.createDirectory(atPath: writePath!.path, withIntermediateDirectories: true)
            let file = writePath!.appendingPathComponent(String(arrItemNamesInt.last!))
//            try? "text".write(to: file, atomically: false, encoding: String.Encoding.utf8)
            fileUrl = file
        }
        
        return fileUrl
    }
    
//    func deleteFileAtPath(path: String){
//        do {
//            try fileManager.removeItem(atPath: path)
//            arrItemNamesInt.removeFirst()
//        } catch error {
//            print(Error)
//        }
//    }
    
    /// Logs error messages on console with prefix [‼️]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public func e( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(LogEvent.e.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
            let filePath = getFileToWrite()
            write(file: filePath, "\(Date().toString()) \(LogEvent.i.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
        }
    }
    
    /// Logs info messages on console with prefix [ℹ️]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public func i ( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(LogEvent.i.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
            let filePath = getFileToWrite()
            write(file: filePath, "\(Date().toString()) \(LogEvent.i.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
            //recursing for testing only
//            Log.shared.i(object) 
        }
    }
    
    /// Logs debug messages on console with prefix [💬]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public func d( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(LogEvent.d.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
            let filePath = getFileToWrite()
            write(file: filePath, "\(Date().toString()) \(LogEvent.i.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
        }
    }
    
    /// Logs messages verbosely on console with prefix [🔬]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public func v( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(LogEvent.v.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
            let filePath = getFileToWrite()
            write(file: filePath, "\(Date().toString()) \(LogEvent.i.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
        }
    }
    
    /// Logs warnings verbosely on console with prefix [⚠️]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public func w( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(LogEvent.w.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
            let filePath = getFileToWrite()
            write(file: filePath, "\(Date().toString()) \(LogEvent.i.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
        }
    }
    
    /// Logs severe events on console with prefix [🔥]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public func s( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(LogEvent.s.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
            let filePath = getFileToWrite()
            write(file: filePath, "\(Date().toString()) \(LogEvent.i.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
        }
    }
    
    
    /// Extract the file name from the file path
    ///
    /// - Parameter filePath: Full file path in bundle
    /// - Returns: File Name with extension
    public func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

internal extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date)
    }
}

internal extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }
    
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}

