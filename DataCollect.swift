//
//  DataCollectingController.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/11.
//

import CoreMotion
import CoreLocation

class DataCollect : CMMotionManager, CLLocationManagerDelegate {
    // Motion Data
    var motionManager = CMMotionManager()
    var sensorDataArray: [Double] = []
    let sensorHeader = "Year,Month,Day,Hour,Min,Sec,AccX,AccY,AccZ,GyroX,GyroY,GyroZ,GraX,GraY,GraZ,Pitch,Roll,Yaw\n"
    var sensorDataString : String = ""
    var fileURL: URL!

    func startGetSensorData() -> Void {
        if motionManager.isDeviceMotionAvailable {
            // get file URL
            fileURL = self.createFolderAndFile()
            // add header to sensorDataString
            sensorDataString += sensorHeader
            
            // logging sensor data
            self.motionManager.deviceMotionUpdateInterval = 1/10
            self.motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
                if let validMotion = motion {
                    self.sensorDataArray = [
                        validMotion.userAcceleration.x,
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
                        validMotion.attitude.yaw]
                    
                    self.sensorDataString += (self.dateManager(type: "data") + self.doubleToString(data: self.sensorDataArray))
                    
//                    print("csvString: " + self.sensorDataString + "\n") // debug
                }
            }
        }
    }
    
    func endGetSensorData() -> Void {
        self.writeInFile(csvString: self.sensorDataString, fileURL: fileURL)
        self.motionManager.stopDeviceMotionUpdates()
    }
    
    // Location Data
    var locationManager = CLLocationManager()
    var GPSDataArray: [Double] = []
    let GPSHeader = "Year,Month,Day,Hour,Min,Sec,Latitude,Longitude,Altitude\n"
    var GPSDataString : String = ""

    func startGetGPSData() -> Void {
        if locationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            self.locationManager.startUpdatingLocation()
            let coor = locationManager.location?.coordinate {
                self.GPSDataArray = [
                    coor.latitude,
                    coor.longitude,
                    coor.altitude,
                    // Accuracy는 따로 메소드 실행하면됨 오늘은 여기까지
                ]
                }
        }
    }

    func endGetGPSData() -> Void {
        self.writeInFile(csvString: self.sensorDataString, fileURL: fileURL)
        self.locationManager.stopUpdatingLocation()
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
        let formattedDate = dateManager(type: "file")
        
        // create file directory
        let fileURL = directoryURL.appendingPathComponent(formattedDate + ".csv")
        
        return fileURL
    }
    
    // Create File
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
    
    func doubleToString(data: [Double]) -> String {
        let dataString = data.map({"\($0)"}).joined(separator: ",") + "\n"
        return dataString
    }

}
