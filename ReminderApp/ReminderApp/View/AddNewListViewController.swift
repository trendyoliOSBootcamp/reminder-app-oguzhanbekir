//
//  AddNewListViewController.swift
//  ReminderApp
//
//  Created by Oguzhan Bekir on 14.05.2021.
//

import UIKit
import CoreData

final class AddNewListViewController: UIViewController {
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var listImage: UIImageView!
    @IBOutlet private weak var addButton: UIButton!
    var items = ["blue", "brown", "red", "green", "yellow", "orange", "car.circle.fill", "cart.circle.fill", "bicycle.circle.fill", "airplane.circle.fill", "house.circle.fill", "paperplane.circle.fill"]
    
    var delegate : ReminderUpdateDelegate? 
    var data: [ListOfReminder] = []
    
    var thumbnailColor = "blue"
    var thumbNailImage = "car.circle.fill"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
    }
    

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        createData()
        delegate?.refreshTableView()
        dismiss(animated: true, completion: nil)
    }
    
    func createData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let newList = NSEntityDescription.insertNewObject(forEntityName: "ReminderList", into: context)
        newList.setValue(titleTextField.text, forKey: "title")
        newList.setValue(UUID(), forKey: "id")
        newList.setValue(thumbnailColor, forKey: "color")
        newList.setValue(thumbNailImage, forKey: "image")
        
        let books: [Item] = []
        let mRanges = Items(items: books)
        
        newList.setValue(mRanges, forKey: "items")
        
        do {
            try context.save()
        } catch  {
            print("Kaydedilemedi...")
        }
    }
}

extension AddNewListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newListCVCell", for: indexPath as IndexPath) as? AddNewListCollectionViewCell else { fatalError() }
            if indexPath.row > 5 {
                cell.circleImage.tintColor = .darkGray
                cell.circleImage.image = UIImage(systemName: items[indexPath.row])
            } else {
                cell.circleImage.tintColor = UIColor(named: items[indexPath.row])
            }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row > 5 {
            thumbNailImage = items[indexPath.row]
            listImage.image = UIImage(systemName: items[indexPath.row])
        } else {
            thumbnailColor = items[indexPath.row]
            listImage.tintColor = UIColor(named: items[indexPath.row])
        }
    }
}


extension AddNewListViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).replacingCharacters(in: range, with: string) as NSString
        if  newString != "" {
            addButton.isEnabled = true
        } else {
            addButton.isEnabled = false
        }
        return true
    }
}
