//
//  Survey2Controller.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/11.
//

import UIKit
import DLRadioButton

class survey2ViewController: UIViewController {

    @IBAction func onClick2(_ sender: Any) {
        let endAlert = UIAlertController(title: "측정 완료", message: "앱을 종료합니다", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }
        
        endAlert.addAction(okAction)
        
        self.present(endAlert, animated: false, completion: nil)
    }
}
