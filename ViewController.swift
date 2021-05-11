//
//  ViewController.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/02.
//

import UIKit

var list = ["Still", "Walking", "Manual Wheelchair", "Power Wheelchair", "Bus", "Metro", "Car"]

class ViewController: UIViewController,
                      UICollectionViewDataSource,
                      UICollectionViewDelegate {
    
    // collection view
    @IBOutlet var collectionView: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCell else {
            return UICollectionViewCell()
        }

        let buttonText = list[indexPath.item]
        cell.update(text: buttonText)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameWidth = collectionView.frame.width
        
        return CGSize(width: frameWidth / 2 - 10, height: frameWidth / 2 - 10)
    }

    let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    @IBAction func onClick(_ sender: Any) {
        let survey1View = mainStoryBoard.instantiateViewController(withIdentifier: "Survey1")
        
        self.navigationController?.pushViewController(survey1View, animated: true)
        
//        survey1View.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//        survey1View.modalPresentationStyle = .overFullScreen
//
//        self.present(survey1View, animated: true)
//
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

class CustomCell: UICollectionViewCell {
    @IBOutlet var cellButton: UIButton!
    
    func update(text: String) {
        cellButton.setTitle(text, for: .normal)
    }
    
}
