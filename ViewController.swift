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
                      UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    // DataSource 1
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    // DataSource 2
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as UICollectionViewCell

        // add cell properties

        return cell
    }
    
    // size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameWidth = collectionView.frame.width
        
        return CGSize(width: frameWidth / 2 - 5, height: frameWidth / 2 - 5)
    }
    
    // vertical space
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
       return 10
    }

    // horizontal space
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
       return 10
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
