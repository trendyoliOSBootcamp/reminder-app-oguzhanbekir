//
//  AddNewListViewController.swift
//  ReminderApp
//
//  Created by Oguzhan Bekir on 14.05.2021.
//

import UIKit
import CoreData


extension AddNewListViewController {
    fileprivate enum Constants {
        static  var items = ["blue", "brown", "red", "green", "yellow", "orange", "car.circle.fill", "cart.circle.fill", "bicycle.circle.fill", "airplane.circle.fill", "house.circle.fill", "paperplane.circle.fill"]
        static var thumbnailColor = "blue"
        static var thumbNailImage = "car.circle.fill"
    }
}

final class AddNewListViewController: UIViewController {
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var listImage: UIImageView!
    @IBOutlet private weak var addButton: UIButton!
    
    var delegate : ReminderUpdateDelegate? 
    var data: [ListOfReminder] = []
    
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
        newList.setValue(Constants.thumbnailColor, forKey: "color")
        newList.setValue(Constants.thumbNailImage, forKey: "image")
        
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
        return Constants.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newListCVCell", for: indexPath as IndexPath) as? AddNewListCollectionViewCell else { fatalError() }
            if indexPath.row > 5 {
                cell.circleImage.tintColor = .darkGray
                cell.circleImage.image = UIImage(systemName: Constants.items[indexPath.row])
            } else {
                cell.circleImage.tintColor = UIColor(named: Constants.items[indexPath.row])
            }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row > 5 {
            Constants.thumbNailImage = Constants.items[indexPath.row]
            listImage.image = UIImage(systemName: Constants.items[indexPath.row])
        } else {
            Constants.thumbnailColor = Constants.items[indexPath.row]
            listImage.tintColor = UIColor(named: Constants.items[indexPath.row])
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
