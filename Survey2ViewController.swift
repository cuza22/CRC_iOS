//
//  Survey2Controller.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/11.
//

import UIKit
import DLRadioButton

class survey2ViewController: UIViewController {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let fileCreator = FileCreator()

    // onClick
    @IBAction func onClick2(_ sender: Any) {
 
        if index != nil {
            _ = chosenIndex?(self.index!)
            // create file
            let fileURL = fileCreator.createFileURL(transportation: ad!.selectedTransportation, sensor: "Survey", directoryURL: (ad?.directoryURL)!)
            fileCreator.writeInFile(csvString: resultArray[self.index!], fileURL: fileURL)
            
            // end
            let endAlert = UIAlertController(title: "측정 완료", message: "앱을 종료합니다", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }
            endAlert.addAction(okAction)
            self.present(endAlert, animated: false, completion: nil)
        }
    }
    
    // Radio Buttons
    @IBOutlet var resultButtons: [UIButton]!

    let resultArray: [String] = ["예", "아니오"]
    var index: Int?
    var chosenIndex: ((Int) -> (Int))?
    
    @IBAction func resultButtonSelect(_ sender: UIButton) {
        if (index != nil || !sender.isSelected) {
            for index in resultButtons.indices {
                resultButtons[index].isSelected = false
            }
        sender.isSelected = true
        index = resultButtons.firstIndex(of: sender)
        }
    }
  
            
    override func viewDidLoad() {
        super.viewDidLoad()
        print("survey2 view\n")
//        let data = DataCollect()
//        print("csvString: " + data.doubleToString(data: data.sensorDataArray) + "\n") // debug
//        data.createCSVFile(csvString: data.doubleToString(data: data.sensorDataArray))
    }
}
