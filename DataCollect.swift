//
//  DataCollectingController.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/11.
//

import UIKit
import CoreMotion
import CoreLocation

let FREQUENCY: Double = 60
let GPS_INTERVAL: Double = 5
let fileCreator = FileCreator()

@available(iOS 14.0, *)
@available(iOS 14.0, *)
class DataCollect : CMMotionManager,
                    CLLocationManagerDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate

    // Motion Data
    var motionManager = CMMotionManager()
    var sensorDataArray: [Double] = []
    let sensorHeader = "Time,Year,Month,Day,Hour,Min,Sec,timestamp,GraX,GraY,GraZ,LinearAccX,LinearAccY,LinearAccZ,GyroX,GyroY,GyroZ,MagX,MagY,MagZ,Orientation_0_Azimuth,RotVec_0,RotVec_1,RotVec_2,RotVec_3,Orientation_1_Pitch,Orientation_2_Roll,AccX,AccY,AccZ,Mode,Survey1\n"
    var sensorDataString : String = ""
    var sensorTimer: Timer?
    var count_sensor = 1
    
    func startGetSensorData() -> Void {
        sensorDataString += sensorHeader // add header
        
        // set frequency
        self.motionManager.deviceMotionUpdateInterval = 1/FREQUENCY
        self.motionManager.accelerometerUpdateInterval = 1/FREQUENCY
        self.motionManager.gyroUpdateInterval = 1/FREQUENCY
        self.motionManager.magnetometerUpdateInterval = 1/FREQUENCY
        
        if motionManager.isDeviceMotionAvailable
            && isAccelerometerAvailable
            && isGyroAvailable
            && isMagnetometerAvailable {

            self.motionManager.startAccelerometerUpdates()
            self.motionManager.startGyroUpdates()
            self.motionManager.startMagnetometerUpdates()
            self.motionManager.startDeviceMotionUpdates()

            self.sensorTimer = Timer(fire: Date(), interval: (1/FREQUENCY), repeats: true, block: { (timer) in
                if let motion = self.motionManager.deviceMotion,
                   let acc = self.motionManager.accelerometerData,
                   let gyro = self.motionManager.gyroData,
                   let mag = self.motionManager.magnetometerData {
                    self.sensorDataArray = [
                        motion.timestamp,
                        // Gra
                        motion.gravity.x,
                        motion.gravity.y,
                        motion.gravity.z,
                        // LinearAcc
                        motion.userAcceleration.x,
                        motion.userAcceleration.y,
                        motion.userAcceleration.z,
                        // ????
//                        motion.rotationRate.x,
//                        motion.rotationRate.y,
//                        motion.rotationRate.z,
                        // Gyro
                        gyro.rotationRate.x,
                        gyro.rotationRate.y,
                        gyro.rotationRate.z,
                        // Mag
                        mag.magneticField.x,
                        mag.magneticField.y,
                        mag.magneticField.z,
                        
                        // RotVec
                        motion.attitude.quaternion.w,
                        motion.attitude.quaternion.x,
                        motion.attitude.quaternion.y,
                        motion.attitude.quaternion.z,
                        // Orientation
                        motion.attitude.yaw,
                        motion.attitude.pitch,
                        motion.attitude.roll,
                        // Acc
                        acc.acceleration.x,
                        acc.acceleration.y,
                        acc.acceleration.z
                    ]

                    self.sensorDataString += self.dateManager(type: "data") + self.sensorDataArray.map({"\($0)"}).joined(separator: ",")
//                    self.sensorDataString += self.sensorDataArray.map({"\($0)"}).joined(separator: ",")

                    // add Mode and Survey1 "only once"
                    if (self.count_sensor > 0) {
                        let modeAndSurvey: String =  "," + self.ad!.selectedTransportation + "," + self.ad!.position
                        self.sensorDataString += modeAndSurvey
                        self.count_sensor -= 1
                    }
                    self.sensorDataString += "\n"
                }
            })
            RunLoop.current.add(self.sensorTimer!, forMode: .default)
        }
    }
    
    func endGetSensorData() -> Void {
        let sensorFileURL = fileCreator.createFileURL(transportation: ad!.selectedTransportation, sensor: "SensorData", directoryURL: (ad?.directoryURL)!)
        fileCreator.writeInFile(csvString: self.sensorDataString, fileURL: sensorFileURL) // data
        self.motionManager.stopDeviceMotionUpdates()
    }
    
    // Location Data
    var locationManager = CLLocationManager()
    var GPSDataArray: [Double] = []
    let GPSHeader = "Time,Year,Month,Day,Hour,Min,Sec,Latitude,Longitude,Altitude,Speed,Mode,Survey1\n"
    var GPSDataString: String = ""
    var GPSTimer: Timer?
    var count_GPS = 1
    
    func startGetGPSData() -> Void {
        GPSDataString += GPSHeader
        locationManager.requestWhenInUseAuthorization()
        
        // check GPS authorization
        if (locationManager.authorizationStatus == .authorizedAlways
                || locationManager.authorizationStatus == .authorizedWhenInUse) {
            locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // highest accuracy
            self.locationManager.startUpdatingLocation()
        }
        
        self.GPSTimer = Timer(fire: Date(), interval: GPS_INTERVAL, repeats: true, block: { (timer) in
            if let location = self.locationManager.location {
                self.GPSDataArray = [
                    location.coordinate.latitude,
                    location.coordinate.longitude,
                    location.altitude,
                    location.speed
                ]
                
                self.GPSDataString += self.dateManager(type: "data") + self.GPSDataArray.map({"\($0)"}).joined(separator: ",")
                // add Mode and Survey1 "only once"
                if (self.count_GPS > 0) {
                    let modeAndSurvey: String =  "," + self.ad!.selectedTransportation + "," + self.ad!.position
                    self.GPSDataString += modeAndSurvey
                    self.count_GPS -= 1
                }
                self.GPSDataString += "\n"
            }
        })
        RunLoop.current.add(self.GPSTimer!, forMode: .default)
    }

    func endGetGPSData() -> Void {
        let GPSFileURL = fileCreator.createFileURL(transportation: ad!.selectedTransportation, sensor: "GPSData", directoryURL: (ad?.directoryURL)!)
        fileCreator.writeInFile(csvString: self.GPSDataString, fileURL: GPSFileURL)
        self.locationManager.stopUpdatingLocation()
    }
    
    let startDate = Date()
    func dateManager(type: String) -> String {
        let date = Date()
        let format = DateFormatter()
        if type == "file" {
            format.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        } else if type == "data" {
            format.dateFormat = String(date.timeIntervalSince(startDate)) + "yyyy,MM,dd,HH,mm,ss,"
        }
        let formattedDate = format.string(from: date)
        return formattedDate
    }
}

