//
//  Survey1.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/07.
//

import UIKit

class survey1ViewController: UIViewController {
    let ad = UIApplication.shared.delegate as? AppDelegate
//    var position: String! = ""
    
    // 완료 Button
    @IBAction func onClick1(_ sender: UIButton) {
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let DataCollectingView = mainStoryBoard.instantiateViewController(identifier: "Data Collecting")
        // get index
        
        print("\n\nIndex is: " + String(index!) + "\n\n")
        if index != nil {
            _ = chosenIndex?(self.index!)
            
            // save position
            ad?.position = positionArray[self.index!]
            print("\n\n" + (ad?.position)! + "\n\n") // debug
            
            // change view
            DataCollectingView.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            DataCollectingView.modalPresentationStyle = .overFullScreen
            self.present(DataCollectingView, animated: true)
        }
            }

    // Radio Buttons
    @IBOutlet var radioButtons: [UIButton]!

    let positionArray: [String] = ["손", "가방", "주머니", "기타"]
    var index: Int?
    var chosenIndex: ((Int) -> (Int))?
    
    @IBAction func radioButtonSelect(_ sender: UIButton) {
        if (index != nil || !sender.isSelected) {
            for index in radioButtons.indices {
                radioButtons[index].isSelected = false
            }
        sender.isSelected = true
        index = radioButtons.firstIndex(of: sender)
        print("\nIndex now: ")
        print(index!)
        print("\n")// debug
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // take a picture
        let imagePickerContoller = UIImagePickerController()
        imagePickerContoller.delegate = self
        imagePickerContoller.sourceType = .camera
        self.present(imagePickerContoller, animated: true, completion: nil)
        

    }
}

extension survey1ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(savedImage), nil)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func savedImage(image: UIImage,
                    didFinishSavingWithError error: Error?,
                    contextInfo: UnsafeMutableRawPointer?) {
        if let error = error {
            print(error)
            return
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

