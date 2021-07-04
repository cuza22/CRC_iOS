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
let WRITE_INTERVAL: Double = 5
let GRAVITY_CONST: Double = -9.81
let PRESSURE_CONST: Double = 10
let fileCreator = FileCreator()

@available(iOS 14.0, *)
class DataCollect : CMMotionManager,
                    CLLocationManagerDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate

    // Motion Data
    var motionManager = CMMotionManager() // gravity, linear acceleration, accelerometer, gyroscope, magnetometer
    var attitude = CMAttitude() // rotation vector, orientation
    var altimeter = CMAltimeter() // pressure, height
    var pedometer = CMPedometerEvent() // step
    var sensorDataArray: [Double] = []
    let sensorHeader = "Time,Year,Month,Day,Hour,Min,Sec,GraX,GraY,GraZ,LinearAccX,LinearAccY,LinearAccZ,GyroX,GyroY,GyroZ,Height,Proxi,MagX,MagY,MagZ,Light,Step,Pressure,RotVec_0,RotVec_1,RotVec_2,RotVec_3,RotVec_4,Orientation_0_Azimuth,Orientation_1_Pitch,Orientation_2_Roll,AccX,AccY,AccZ,Mode,Survey1\n"
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
            && isMagnetometerAvailable
            && CMAltimeter.isRelativeAltitudeAvailable()
            && CMPedometer.isPedometerEventTrackingAvailable() {
            
            self.motionManager.startDeviceMotionUpdates()
            self.motionManager.startAccelerometerUpdates()
            self.motionManager.startGyroUpdates()
            self.motionManager.startMagnetometerUpdates()
            UIDevice.current.isProximityMonitoringEnabled = true
            altimeter.startRelativeAltitudeUpdates(to: .main, withHandler: { (altiData, error) in
                if (error == nil) {
                    
                    self.sensorTimer = Timer(fire: Date(), interval: (1/FREQUENCY), repeats: true, block: { (timer) in
                        if let motion = self.motionManager.deviceMotion,
                           let acc = self.motionManager.accelerometerData,
                           let gyro = self.motionManager.gyroData,
                           let mag = self.motionManager.magnetometerData {
                            self.sensorDataArray = [
                                // Gra
                                motion.gravity.x * GRAVITY_CONST,
                                motion.gravity.y * GRAVITY_CONST,
                                motion.gravity.z * GRAVITY_CONST,
                                // LinearAcc
                                motion.userAcceleration.x * GRAVITY_CONST,
                                motion.userAcceleration.y * GRAVITY_CONST,
                                motion.userAcceleration.z * GRAVITY_CONST,
                                // Gyro
                                gyro.rotationRate.x,
                                gyro.rotationRate.y,
                                gyro.rotationRate.z,
                                // Height
                                altiData!.relativeAltitude.doubleValue,
                                // Proxi
                                self.getProximity(),
                                // Mag
                                mag.magneticField.x,
                                mag.magneticField.y,
                                mag.magneticField.z,
                                // Light
                                0,
                                // Step
                                0,
                                // Pressure
                                altiData!.pressure.doubleValue * PRESSURE_CONST,
                                // RotVec
                                motion.attitude.quaternion.w,
                                motion.attitude.quaternion.x,
                                motion.attitude.quaternion.y,
                                motion.attitude.quaternion.z,
                                0, // RotVec_4
//                                self.attitude.quaternion.w,
//                                self.attitude.quaternion.x,
//                                self.attitude.quaternion.y,
//                                self.attitude.quaternion.z,
                                // Orientation
                                motion.attitude.yaw,
                                motion.attitude.pitch,
                                motion.attitude.roll,
//                                self.attitude.yaw,
//                                self.attitude.pitch,
//                                self.attitude.roll,
                                // Acc
                                acc.acceleration.x * GRAVITY_CONST,
                                acc.acceleration.y * GRAVITY_CONST,
                                acc.acceleration.z * GRAVITY_CONST
                            ]
                            self.sensorDataString += self.dateManager(type: "data") + self.sensorDataArray.map({"\($0)"}).joined(separator: ",")

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
            })
        }
    }
        
    // proximity
    func getProximity() -> Double {
        if UIDevice.current.proximityState {
            return 8.0
        } else {
            return 0.0
        }
    }
    
    func endGetSensorData() -> Void {
//        let sensorFileURL = fileCreator.createFileURL(transportation: ad!.selectedTransportation, sensor: "SensorData", directoryURL: (ad?.directoryURL)!)
//        fileCreator.writeInFile(csvString: self.sensorDataString, fileURL: sensorFileURL) // data
        self.motionManager.stopDeviceMotionUpdates()
        self.motionManager.stopAccelerometerUpdates()
        self.motionManager.stopGyroUpdates()
        self.motionManager.stopMagnetometerUpdates()
        self.altimeter.stopRelativeAltitudeUpdates()
        UIDevice.current.isProximityMonitoringEnabled = false
    }
    
    // Location Data
    var locationManager = CLLocationManager()
    var GPSDataArray: [Double] = []
    let GPSHeader = "Time,Year,Month,Day,Hour,Min,Sec,Latitude,Longitude,Accuracy,Altitude,Bearing,Speed,Mode,Survey1\n"
    var GPSDataString: String = ""
    var GPSTimer: Timer?
    var count_GPS = 1
    
    func startGetGPSData() -> Void {
        GPSDataString += GPSHeader
        locationManager.requestAlwaysAuthorization()
        
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
                    location.horizontalAccuracy,
                    location.altitude,
                    location.course,
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
//        let GPSFileURL = fileCreator.createFileURL(transportation: ad!.selectedTransportation, sensor: "GPSData", directoryURL: (ad?.directoryURL)!)
//        fileCreator.writeInFile(csvString: self.GPSDataString, fileURL: GPSFileURL)
        self.locationManager.stopUpdatingLocation()
    }
    
    var writeTimer: Timer?
    func writeInFile() -> Void {
        print("write in file start\n")
        // file URL
        let sensorFileURL = fileCreator.createFileURL(transportation: ad!.selectedTransportation, sensor: "SensorData", directoryURL: (ad?.directoryURL)!)
        let GPSFileURL = fileCreator.createFileURL(transportation: ad!.selectedTransportation, sensor: "GPSData", directoryURL: (ad?.directoryURL)!)
        print(GPSFileURL)
        // write once in five seconds
        self.writeTimer = Timer(fire: Date(), interval: WRITE_INTERVAL, repeats: true, block: { (timer) in
            print("write\n")
            fileCreator.writeInFile(csvString: self.sensorDataString, fileURL: sensorFileURL)
            fileCreator.writeInFile(csvString: self.GPSDataString, fileURL: GPSFileURL)
            print(self.GPSDataString)
        })
        RunLoop.current.add(self.writeTimer!, forMode: .default)
    }
    
    let startDate = Date()
    func dateManager(type: String) -> String {
        let date = Date()
        let format = DateFormatter()
        if type == "file" {
            format.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        } else if type == "data" {
            format.dateFormat = ",yyyy,MM,dd,HH,mm,ss,"
        }
        let formattedDate = String(date.timeIntervalSince(startDate)) + format.string(from: date)
        return formattedDate
    }
}

