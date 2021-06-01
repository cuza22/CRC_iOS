//
//  DataCollectingController.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/11.
//

import CoreMotion

class DataCollect {
    var motionManager = CMMotionManager()
    var sensorDataArray: [Double] = []

    // Motion Data
    func getSensorData() -> Void {
        if motionManager.isDeviceMotionAvailable {
            self.motionManager.deviceMotionUpdateInterval = 3
            self.motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
                if let validMotion = motion {
                    self.sensorDataArray.append(contentsOf: [                    validMotion.userAcceleration.x,
                        validMotion.userAcceleration.y,
                        validMotion.userAcceleration.z,
                        validMotion.rotationRate.x,
                        validMotion.rotationRate.y,
                        validMotion.rotationRate.z,
                        validMotion.gravity.x,
                        validMotion.gravity.y,
                        validMotion.gravity.z,
                        validMotion.attitude.pitch,
                        validMotion.attitude.roll,
                        validMotion.attitude.yaw])
                }
            }
        }
    }
    
    // Create File
    func createCSVFile(csvString: String) -> Void {
        print("createCSVFile working!\n"); // debug

        // create directory
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentsURL.appendingPathComponent("HCI Lab")
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false, attributes: nil)
            print("create directory worked\n")
        } catch let e {
            print(e.localizedDescription)
        }
        
        // create date string
        let formattedDate = dateManager()
        
        // append data to csv file
        let fileURL = directoryURL.appendingPathComponent(formattedDate + ".csv")
        let text = NSString(string: self.doubleToString(data: self.sensorDataArray))

        do {
            try text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
            print("write worked\n")
            print(fileURL)
        } catch let e {
            print(e.localizedDescription)
        }
    }

    func dateManager() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        let formattedDate = format.string(from: date)
        return formattedDate
    }

    func doubleToString(data: [Double]) -> String {
        let dataString = data.map({"\($0)"}).joined(separator: ",")
        return dataString
    }

}
