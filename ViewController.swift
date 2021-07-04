//
//  ViewController.swift
//  CRC_iOS
//
//  Created by 우예지 on 2021/05/02.
//

import UIKit

var transportations = ["Still", "Walking", "Manual Wheelchair", "Power Wheelchair", "Bus", "Metro", "Car"]

class ViewController: UIViewController,
                      UICollectionViewDataSource,
                      UICollectionViewDelegate,
                      UICollectionViewDelegateFlowLayout {
    
    let ad = UIApplication.shared.delegate as? AppDelegate
    var selectedIndex: Int?
    
    // collection view
    @IBOutlet weak var collectionView: UICollectionView!
    
    let sectionInsects = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return transportations.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CustomCell else {
            return UICollectionViewCell()
        }

        let transportation = transportations[indexPath.item]
        let transportationIcon = UIImage(named: transportation)!
        
        cell.updateButtonIcon(icon: transportationIcon)
        cell.updateLabel(text: transportation)
        cell.setIndex(index: indexPath.item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        let frameWidth = UIScreen.main.bounds.width
        let frameWidth = collectionView.frame.width
        
        let itemsPerRow: CGFloat = 2
        let widthPadding = sectionInsects.left * (itemsPerRow + 1)
        let cellWidth = (frameWidth - widthPadding) / itemsPerRow
        
        return CGSize(width: cellWidth, height: cellWidth * 1.2)
    }

    // onclick event
    @IBAction func onClick(_ sender: UIButton) {
        // create folder
        let fileCreator = FileCreator()
        ad?.selectedTransportation = transportations[sender.tag]
        ad?.directoryURL = fileCreator.setFolderDirectory()

        // change view
        let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let survey1View = mainStoryBoard.instantiateViewController(withIdentifier: "Survey1")
        self.navigationController?.pushViewController(survey1View, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

class CustomCell: UICollectionViewCell {
    @IBOutlet var cellButton: UIButton!
    @IBOutlet var cellLabel: UILabel!
    
    func updateButtonIcon(icon: UIImage) {
        cellButton.setImage(icon, for: .normal)
    }
    
    func updateLabel(text: String) {
        cellLabel.text = text
    }
    
    func setIndex(index: Int) {
        cellButton.tag = index
    }
}
