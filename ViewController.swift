//
//  ViewController.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/02.
//

import UIKit

var transportation = ["Still", "Walking", "Manual Wheelchair", "Power Wheelchair", "Bus", "Metro", "Car"]

class ViewController: UIViewController,
                      UICollectionViewDataSource,
                      UICollectionViewDelegate {
    let ad = UIApplication.shared.delegate as? AppDelegate
    // for selecting a transportation
//    var selectedTransportation: String?
//    var directoryURL: URL?
    
    // collection view
    @IBOutlet var collectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return transportation.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCell else {
            return UICollectionViewCell()
        }

        let buttonText = transportation[indexPath.item]
        cell.update(text: buttonText)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameWidth = collectionView.frame.width
        
        return CGSize(width: frameWidth / 2 - 10, height: frameWidth / 2 - 10)
    }

    // onclick event
    @IBAction func onClick(_ sender: UIButton) {
        // create folder
        let fileCreator = FileCreator()
        ad?.selectedTransportation = sender.titleLabel!.text!
        ad?.directoryURL = fileCreator.setFolderDirectory()
        print("selected transportation is " + (ad?.selectedTransportation)! + "\n") // debug

        
//        // take a picture
//        let imagePickerContoller = UIImagePickerController()
//        imagePickerContoller.delegate = self
//        imagePickerContoller.sourceType = .camera
//        self.present(imagePickerContoller, animated: true, completion: nil)
//
        // change view
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let survey1View = mainStoryBoard.instantiateViewController(withIdentifier: "Survey1")
        self.navigationController?.pushViewController(survey1View, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
//
//extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let image = info[.originalImage] as? UIImage {
//            UIImageWriteToSavedPhotosAlbum(image, self, #selector(savedImage), nil)
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//    
//    @objc
//    func savedImage(image: UIImage,
//                    didFinishSavingWithError error: Error?,
//                    contextInfo: UnsafeMutableRawPointer?) {
//        if let error = error {
//            print(error)
//            return
//        }
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//}

class CustomCell: UICollectionViewCell {
    @IBOutlet var cellButton: UIButton!
    
    func update(text: String) {
        cellButton.setTitle(text, for: .normal)
    }
    
}
