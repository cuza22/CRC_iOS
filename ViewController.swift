//
//  ViewController.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/02.
//

import UIKit

var list = ["still", "walk", "bus", "metro", "manual", "power", "car"]

class ViewController: UIViewController,
                      UICollectionViewDataSource,
                      UICollectionViewDelegate { // these are called 'protocols'
    
    @IBOutlet var collectionView: UICollectionView!
    
    // DataSource 1
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    // DataSource 2
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCell else {
            return UICollectionViewCell()
        }

        let buttonText = list[indexPath.item]
        cell.update(text: buttonText)
        
        return cell
    }
    
    // size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameWidth = collectionView.frame.width
        
        return CGSize(width: frameWidth / 2 - 10, height: frameWidth / 2 - 10)
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
