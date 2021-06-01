//
//  DataCollectingController.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/18.
//

import CoreMotion

class DataCollect {
    var motionManager = CMMotionManager()
    var queue = OperationQueue()
    
    func startDataCollect() -> Void {
        if motionManager.isDeviceMotionAvailable {
            getSensorData()
        }
    }
    
    func endDataCollect() -> Void {
        
    }
    
    // func createCSVFile() -> Void // creates file
    // func writeCSVFile(csvString: String) -> Void // writes on the file
    
    func createCSVFile(csvString: String) -> Void {
        print("createCSVFile working!\n");

        // create date string
        let formattedDate = dateManager()
        
        // create directory
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            print(path)
        } catch {
            print("path invalid")
        }
        
        // append data to csv file
        do {
            try csvString.write(toFile: formattedDate + "_SensorData.csv", atomically: true, encoding: .utf8)
            print("Test: " + csvString) // debug
            
        } catch {
            print("error creating file")
        }
    }

    func getSensorData() -> String {
        var sensorData: String = ""

        self.motionManager.deviceMotionUpdateInterval = 3
        self.motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in

            if (motion?.userAcceleration != nil) {
                let AccX = motion!.userAcceleration.x
                let AccY = motion!.userAcceleration.y
                let AccZ = motion!.userAcceleration.z
                
                sensorData += (self.doubleToString(data: AccX, AccY, AccZ) + ",")
//                print("acc: " + sensorData)
            }

            if (motion?.rotationRate != nil) {
                let RotVecX = motion!.rotationRate.x
                let RotVecY = motion!.rotationRate.y
                let RotVecZ = motion!.rotationRate.z

                sensorData += (self.doubleToString(data: RotVecX, RotVecY, RotVecZ) + ",")
//                print("rot: " + sensorData)
            }
            
            if (motion?.magneticField != nil) {
                let MagX = motion!.magneticField.field.x
                let MagY = motion!.magneticField.field.y
                let MagZ = motion!.magneticField.field.z
                
                sensorData += (self.doubleToString(data: MagX, MagY, MagZ) + ",")
//                print("mag: " + sensorData)

            }
//                let Orientation_1 = motion?.attitude.pitch
            
            if (motion?.gravity != nil) {
                let GraX = motion!.gravity.x
                let GraY = motion!.gravity.y
                let GraZ = motion!.gravity.z
                
                sensorData += (self.doubleToString(data: GraX, GraY, GraZ) + ",")
            }
            print("sensorData: " + sensorData + "\n") // debug
        }
        return sensorData + "\n\n"
    }

//    func stringToCSVRow(dataString: String) -> String {
//        let csvString = dataString + "\n\n"
//        return csvString
//    }
    
    func doubleToString(data: Double...) -> String {
        let dataString = data.map({"\($0)"}).joined(separator: ",")
        return dataString
    }

    func dateManager() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
}
