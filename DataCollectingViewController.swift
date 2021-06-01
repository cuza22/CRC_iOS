//
//  DataCollectingController.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/11.
//

import UIKit
import CoreMotion

class DataCollectingViewController: UIViewController {
    // Timer
    @IBOutlet var timeLabel: UILabel!
    
    var timer : Timer?
    var timeLeft : Int = 10
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DataCollectingViewController.timerCallBack), userInfo: nil, repeats: true)
    }
    
    @objc func timerCallBack() {
        timeLeft -= 1
        timeLabel.text = String(timeLeft) + " seconds remaining..."

        
        if timeLeft == 0 {
            timer?.invalidate()
            endView()
        }
    }
    
    // View
    func endView() {
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let Survey2View = mainStoryBoard.instantiateViewController(identifier: "Survey2")
        
        Survey2View.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        Survey2View.modalPresentationStyle = .overFullScreen
        
        self.present(Survey2View, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()
        RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
        self.startDataCollect()
    }
    
    // Motion Data
    var motionManager = CMMotionManager()
    var queue = OperationQueue()
    
    func startDataCollect() -> String {
        var csvString = ""
        if motionManager.isDeviceMotionAvailable {
            csvString += getSensorData()
        }
        return csvString
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
    
    // Create File
    // func createCSVFile() -> Void // creates file
    // func writeCSVFile(csvString: String) -> Void // writes on the file

    func createCSVFile(csvString: String) -> Void {
        print("createCSVFile working!\n"); //debug

        // create directory
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentsURL.appendingPathComponent("HCI Lab")
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false, attributes: nil)
        } catch let e {
            print(e.localizedDescription)
        }
//        do {
            
//            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
//            print(path)
//        } catch {
//            print("path invalid")
//        }
        
        // create date string
        let formattedDate = dateManager()
        
        // append data to csv file
        let fileURL = directoryURL.appendingPathComponent(formattedDate + "test.txt")
        let text = NSString(string: csvString)

        do {
            try text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8.rawValue)
        } catch let e {
            print(e.localizedDescription)
        }
//        do {
//            try csvString.write(toFile: formattedDate + "_SensorData.csv", atomically: true, encoding: .utf8)
//            print("Test: " + csvString) // debug
//
//        } catch {
//            print("error creating file")
//        }
    }

    // Else
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
