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
let GRAVITY_CONST: Double = 9.81
let PRESSURE_CONST: Double = 1000
let RADIAN_TO_DEGREE_CONST: Double = 180/Double.pi
let fileCreator = FileCreator()

@available(iOS 14.0, *)
class DataCollect : CMMotionManager,
                    CLLocationManagerDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate

    // Motion Data
    var motionManager = CMMotionManager() // gravity, linear acceleration, accelerometer, gyroscope, magnetometer
//    var attitude = CMAttitude() // rotation vector, orientation
    var altimeter = CMAltimeter() // pressure, height
    var pedometer = CMPedometer() // step
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
            self.locationManager.startUpdatingHeading()
            self.startStepUpdates()
            self.startAltimeterUpdates()
            UIDevice.current.isProximityMonitoringEnabled = true

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
                        self.altimeterData?.relativeAltitude.doubleValue ?? 0,
                        // Proxi
                        UIDevice.current.proximityState ? 1 : 0,
                        // Mag
                        mag.magneticField.x,
                        mag.magneticField.y,
                        mag.magneticField.z,
                        // Light
                        -1,
                        // Step
                        self.pedometerEventType,
                        // Pressure
                        self.altimeterData?.pressure.doubleValue ?? 0 * PRESSURE_CONST,
                        // RotVec
                        motion.attitude.quaternion.x * RADIAN_TO_DEGREE_CONST,
                        motion.attitude.quaternion.y * RADIAN_TO_DEGREE_CONST,
                        motion.attitude.quaternion.z * RADIAN_TO_DEGREE_CONST,
                        motion.attitude.quaternion.w * RADIAN_TO_DEGREE_CONST,
                        0, // RotVec_4
                        // Orientation
//                        motion.attitude.rotationMatrix,
                        self.azimuth,
                        motion.attitude.pitch * RADIAN_TO_DEGREE_CONST,
                        motion.attitude.roll * RADIAN_TO_DEGREE_CONST,
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
    }
    
    var pedometerEventType: Double = 0
    func startStepUpdates() {
        self.pedometer.startEventUpdates(handler: {
            (event: CMPedometerEvent?, error: Error?) in
            if event!.type == .pause {
                self.pedometerEventType = 0
            } else {
                self.pedometerEventType = 1
            }
        })
     }

    var altimeterData: CMAltitudeData?
    func startAltimeterUpdates() {
        self.altimeter.startRelativeAltitudeUpdates(to: .main, withHandler: { (data, error) in
            self.altimeterData = data
        })
    }
    
    var azimuth: Double = 0
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        azimuth = newHeading.magneticHeading
        }
    
    func endGetSensorData() -> Void {
        self.motionManager.stopDeviceMotionUpdates()
        self.motionManager.stopAccelerometerUpdates()
        self.motionManager.stopGyroUpdates()
        self.motionManager.stopMagnetometerUpdates()
        self.locationManager.stopUpdatingHeading()
        self.altimeter.stopRelativeAltitudeUpdates()
        self.pedometer.stopEventUpdates()
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
        self.locationManager.stopUpdatingLocation()
    }
    
    var writeTimer: Timer?
    func writeInFile() -> Void {
        // file URL
        let sensorFileURL = fileCreator.createFileURL(transportation: ad!.selectedTransportation, sensor: "SensorData", directoryURL: (ad?.directoryURL)!)
        let GPSFileURL = fileCreator.createFileURL(transportation: ad!.selectedTransportation, sensor: "GPSData", directoryURL: (ad?.directoryURL)!)
        // write once in five seconds
        self.writeTimer = Timer(fire: Date(), interval: WRITE_INTERVAL, repeats: true, block: { (timer) in
            fileCreator.writeInFile(csvString: self.sensorDataString, fileURL: sensorFileURL)
            fileCreator.writeInFile(csvString: self.GPSDataString, fileURL: GPSFileURL)
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

