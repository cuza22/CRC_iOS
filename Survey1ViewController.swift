//
//  Survey1.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/07.
//

import UIKit

class survey1ViewController: UIViewController {
    
    let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

    // 완료 Button
    @IBAction func onClick1(_ sender: Any) {
        let DataCollectingView = mainStoryBoard.instantiateViewController(identifier: "Data Collecting")
        // get index
        if index != nil {
            _ = chosenIndex?(self.index!)
            
            // change view
            DataCollectingView.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            DataCollectingView.modalPresentationStyle = .overFullScreen
            self.present(DataCollectingView, animated: true)
        }
            }

    // Radio Buttons
    @IBOutlet var radioButtons: [UIButton]!

    var index: Int?
    var chosenIndex: ((Int) -> (Int))?
    
    @IBAction func radioButtonSelect(_ sender: UIButton) {
        if (index != nil || !sender.isSelected) {
            for index in radioButtons.indices {
                radioButtons[index].isSelected = false
            }
        sender.isSelected = true
        index = radioButtons.firstIndex(of: sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // create file
    let data = DataCollect()
    
}
