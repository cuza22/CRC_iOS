//
//  Survey1.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/07.
//

import UIKit
import DLRadioButton

class survey1ViewController: UIViewController {
    
    let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

    @IBAction func onClick1(_ sender: Any) {
        let DataCollectingView = mainStoryBoard.instantiateViewController(identifier: "Data Collecting")
        
        DataCollectingView.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        DataCollectingView.modalPresentationStyle = .overFullScreen
        
        self.present(DataCollectingView, animated: true)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
