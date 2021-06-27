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
                      UICollectionViewDelegate {
    
    let ad = UIApplication.shared.delegate as? AppDelegate
    var selectedIndex: Int?
    
    // collection view
    @IBOutlet var collectionView: UICollectionView!
    
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
        
        let frameWidth = UIScreen.main.bounds.width
        
        return CGSize(width: frameWidth / 2, height: frameWidth / 2)
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
