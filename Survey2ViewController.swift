//
//  Survey2Controller.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/11.
//

import UIKit
import AudioToolbox

class survey2ViewController: UIViewController {
    let ad = UIApplication.shared.delegate as? AppDelegate
    let fileCreator = FileCreator()
    var isEnd: Bool = false
    
    // onClick
    @IBAction func onClick2(_ sender: Any) {
 
        if index != nil {
            _ = chosenIndex?(self.index!)
            
            // create file
            let fileURL = fileCreator.createFileURL(transportation: ad!.selectedTransportation, sensor: "Survey", directoryURL: (ad?.directoryURL)!)
            fileCreator.writeInFile(csvString: "Survey3\n" + resultArray[self.index!], fileURL: fileURL)

            // close the app by exit
            exit(1)
        }
    }
    
    // Radio Buttons
    @IBOutlet var resultButtons: [UIButton]!

    let resultArray: [String] = ["Yes", "No"]
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for _ in 0..<10 {
            AudioServicesPlaySystemSound(4095)
            AudioServicesPlaySystemSound(1234)
            if isEnd == true {
                break
            }
        }
        // end alert
        let endAlert = UIAlertController(title: "측정 완료", message: "🔔", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
            self.isEnd = true
        }
        endAlert.addAction(okAction)

        present(endAlert, animated: false, completion: nil)
    }
}
