//
//  DataCollectingController.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/11.
//

import UIKit

class DataCollectingViewController: UIViewController {
    let data = DataCollect()

    // View
    override func viewDidLoad() {
        super.viewDidLoad()
        startTimer()
        data.startGetSensorData() // start data collecting
    }

    func endView() {
        data.endGetSensorData() // end data collecting
        
        // new view
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let Survey2View = mainStoryBoard.instantiateViewController(identifier: "Survey2")
        
        Survey2View.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        Survey2View.modalPresentationStyle = .overFullScreen
        
        self.present(Survey2View, animated: true)
    }
    
    // Timer
    @IBOutlet var timeLabel: UILabel!
    
    var timer : Timer?
    var timeLeft : Int = 10
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DataCollectingViewController.timerCallBack), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
    }
    
    @objc func timerCallBack() {
        timeLeft -= 1
        timeLabel.text = String(timeLeft) + " seconds remaining..."

        
        if timeLeft == 0 {
            timer?.invalidate()
            endView()
        }
    }
}
