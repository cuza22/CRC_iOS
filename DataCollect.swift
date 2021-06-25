//
//  DataCollectingController.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/11.
//

import UIKit
import CoreMotion
import CoreLocation

let FREQUENCY: Double = 80
let fileCreator = FileCreator()
//let vc = ViewController()
//let positionvc = survey1ViewController()

class DataCollect : CMMotionManager,
                    CLLocationManagerDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate

//    print("selected transportation in datacollect is " + vc.selectedTransportation!)

    // Motion Data
    var motionManager = CMMotionManager()
    var sensorDataArray: [Double] = []
    let sensorHeader = "Year,Month,Day,Hour,Min,Sec,AccX,AccY,AccZ,GyroX,GyroY,GyroZ,GraX,GraY,GraZ,Pitch,Roll,Yaw\n"
    var sensorDataString : String = ""

    func startGetSensorData() -> Void {
        if motionManager.isDeviceMotionAvailable {
            sensorDataString += sensorHeader
            
            // logging sensor data
            self.motionManager.deviceMotionUpdateInterval = 1/FREQUENCY
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
                        validMotion.attitude.yaw
                    ]
                    
                    self.sensorDataString += (self.dateManager(type: "data") + self.doubleToString(data: self.sensorDataArray))
                    
//                    print("csvString: " + self.sensorDataString + "\n") // debug
                }
            }
        }
    }
    
    func endGetSensorData() -> Void {
        let sensorFileURL = fileCreator.createFileURL(transportation: ad!.selectedTransportation, sensor: "Sensor", directoryURL: (ad?.directoryURL)!)
        fileCreator.writeInFile(csvString: "Position\n" + ad!.position + "\n", fileURL: sensorFileURL) // position
        fileCreator.writeInFile(csvString: self.sensorDataString, fileURL: sensorFileURL) // data
        self.motionManager.stopDeviceMotionUpdates()
    }
    
    // Location Data
    var locationManager = CLLocationManager()
    var GPSDataArray: [Double] = []
    let GPSHeader = "Year,Month,Day,Hour,Min,Sec,Latitude,Longitude,Altitude,Speed\n"
    var GPSDataString : String = ""
        
    func startGetGPSData() -> Void {
        print("startGetGPSData\n")
        GPSDataString += GPSHeader
        locationManager.requestWhenInUseAuthorization()
        
        if (locationManager.authorizationStatus == .authorizedAlways
                || locationManager.authorizationStatus == .authorizedWhenInUse) {
            locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // highest accuracy
            self.locationManager.startUpdatingLocation()
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // logging GPS data
        guard let location = manager.location else {
            return
        }
        self.GPSDataArray = [
            location.coordinate.latitude,
            location.coordinate.longitude,
            location.altitude,
            location.speed
        ]

        self.GPSDataString += (self.dateManager(type: "data") + self.doubleToString(data: self.GPSDataArray))
//        print(self.GPSDataArray) // debug
//        print("\n")
    }

    func endGetGPSData() -> Void {
        let GPSFileURL = fileCreator.createFileURL(transportation: ad!.selectedTransportation, sensor: "GPS", directoryURL: (ad?.directoryURL)!)
        fileCreator.writeInFile(csvString: self.GPSDataString, fileURL: GPSFileURL)
        self.locationManager.stopUpdatingLocation()
    }
//
//    // Create folder and file
//    func setFolderDirectory() -> Void {
//        print("createFolder working!\n"); // debug
//
//        // create directory
//        let fileManager = FileManager()
//        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
//        directoryURL = documentsURL.appendingPathComponent("HCI Lab")
//        do {
//            try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: false, attributes: nil)
//            print("create directory worked\n")
//        } catch let error as NSError {
//            print("Error creating directory: \(error.localizedDescription)")
//        }
//    }
//    
//    func createFile(transportation: String, sensor: String) -> URL {
//        // create date string
//        let formattedDate = dateManager(type: "file")
//        
//        // create file directory
//        let fileURL = directoryURL.appendingPathComponent(formattedDate + "_" + sensor + "Data.csv")
//
//        return fileURL
//    }
//    
//    func writeInFile(csvString: String, fileURL: URL) -> Void {
//        let text = NSString(string: csvString)
//        do {
//            try text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
//            print("write worked\n")
//        } catch let e {
//            print(e.localizedDescription)
//        }
//    }
//
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

