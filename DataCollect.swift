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
    let header = "AccX,AccY,AccZ,GyroX,GyroY,GyroZ,GraX,GraY,GraZ,Pitch,Roll,Yaw\n\n"

    // Motion Data
    func getSensorData() -> Void {
        if motionManager.isDeviceMotionAvailable {
            // create directory and file
            let fileURL = createFolderAndFile()
            self.writeInFile(csvString: header, fileURL: fileURL)
            
            // logging sensor data
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
                    
                    print("csvString: " + self.doubleToString(data: self.sensorDataArray) + "\n\n") // debug

                    self.writeInFile(csvString: self.doubleToString(data: self.sensorDataArray), fileURL: fileURL)
                }
            }
        }
    }
    
    // Create folder
    func createFolderAndFile() -> URL {
        print("createFolder working!\n"); // debug

        // create directory
        let fileManager = FileManager()
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryURL = documentsURL.appendingPathComponent("HCI Lab")
        do {
            try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: false, attributes: nil)
            print("create directory worked\n")
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
        
        // create date string
        let formattedDate = dateManager()
        
        // create file directory
        let fileURL = directoryURL.appendingPathComponent(formattedDate + ".csv")
        
        return fileURL
    }
    
    // Create File
    func writeInFile(csvString: String, fileURL: URL) -> Void {
//        let text = NSString(string: self.doubleToString(data: self.sensorDataArray))
        if let fileUpdater = try? FileHandle(forUpdating: fileURL) {
            fileUpdater.seekToEndOfFile()
            fileUpdater.write(csvString.data(using: .utf8)!)
            fileUpdater.closeFile()
        }
//        try text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
//        print("write worked\n")
//        } catch let e {
//            print(e.localizedDescription)
//        }
    }

    func dateManager() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        let formattedDate = format.string(from: date)
        return formattedDate
    }

    func doubleToString(data: [Double]) -> String {
        let dataString = data.map({"\($0)"}).joined(separator: ",") + "\n"
        return dataString
    }

}
