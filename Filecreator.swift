//
//  FileManager.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/06/25.
//

import Foundation

class FileCreator {
    let fileManager = FileManager()
    var directoryURL : URL!

    // Creates folder
    func setFolderDirectory() -> Void {
        // create directory
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        directoryURL = documentsURL.appendingPathComponent("HCI Lab")
        do {
            try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }
    
    // Creates file
    func createFileURL(transportation: String, sensor: String) -> URL {
        // create date string
        let formattedDate = dateManager(type: "file")
        // create file directory
        let fileURL = directoryURL.appendingPathComponent(formattedDate + "_" + sensor + "Data.csv")

        return fileURL
    }
    
    // Writes in file
    func writeInFile(csvString: String, fileURL: URL) -> Void {
        let text = NSString(string: csvString)
        do {
            try text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            print("write worked\n")
        } catch let e {
            print(e.localizedDescription)
        }
    }

    func dateManager(type: String) -> String {
        let date = Date()
        let format = DateFormatter()
        if type == "file" {
            format.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        } else if type == "data" {
            format.dateFormat = "yyyy,MM,dd,HH,mm,ss,"
        }
        let formattedDate = format.string(from: date)
        return formattedDate
    }

}
