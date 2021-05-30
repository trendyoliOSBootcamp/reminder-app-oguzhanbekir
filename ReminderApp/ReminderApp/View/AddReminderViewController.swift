//
//  AddReminderViewController.swift
//  ReminderApp
//
//  Created by Oguzhan Bekir on 14.05.2021.
//

import UIKit
import CoreData

final class AddReminderViewController: UIViewController {
    @IBOutlet private weak var titleTextField: FormTextField!
    @IBOutlet private weak var notesTextView: UITextView!
    @IBOutlet private weak var flagSwitch: UISwitch!
    @IBOutlet private weak var addButton: UIButton!
    
    @IBOutlet private weak var selectListView: UIView!
    @IBOutlet private weak var listNameLabel: UILabel!
    @IBOutlet private weak var selectPriorityList: UIView!
    @IBOutlet private weak var circleImage: UIImageView!
    @IBOutlet private weak var priorityLabel: UILabel!
    
    var delegateReminder : ReminderUpdateDelegate?
    var delegateListView : ListViewUpdateDelegate?

    let pickerViewList = UIPickerView()
    let pickerViewPriority = UIPickerView()
    
    var toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100.0, height: 44.0))
    var data: [ListOfReminder] = []
    
    var pickerData = ["None", "Low", "Medium", "High"]
    var selectedListId: UUID?
    var selectedPriority = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerViewList.delegate = self
        pickerViewPriority.delegate = self
        
        let tapSelecList = UITapGestureRecognizer(target: self, action: #selector(self.selectList(_:)))
        selectListView.addGestureRecognizer(tapSelecList)
        let tapSelectPriority = UITapGestureRecognizer(target: self, action: #selector(self.selectList(_:)))
        selectPriorityList.addGestureRecognizer(tapSelectPriority)
    }
    
    @objc func selectList(_ sender: UITapGestureRecognizer? = nil) {
        if sender?.view == selectListView {
            createPickerView(pickerView: pickerViewList)
        } else {
            createPickerView(pickerView: pickerViewPriority)
        }
    }
    
    func createPickerView(pickerView: UIPickerView) {
        pickerView.backgroundColor = UIColor.white
        pickerView.setValue(UIColor.black, forKey: "textColor")
        pickerView.autoresizingMask = .flexibleWidth
        pickerView.contentMode = .center
        pickerView.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(pickerView)
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(actionDone))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpace, done], animated: false)
        self.view.addSubview(toolBar)
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        if !titleTextField.text!.isEmpty && !notesTextView.text.isEmpty && selectedListId != nil {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReminderList")

            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                     guard let id = result.value(forKey: "id") as? UUID else { return }
                        if id == selectedListId {
                            var items: [Item] = []
                            guard let pastItems = result.value(forKey: "items") as? Items else { return }
                            for element in pastItems.items {
                                items.append(Item(id: element.id!, title: element.title, notes: element.notes, flag: element.flag, priority: element.priority))
                            }

                            items.append(Item(id: UUID(), title: titleTextField.text, notes: notesTextView.text, flag: flagSwitch.isOn, priority: selectedPriority))

                            let mRanges = Items(items: items)
                            result.setValue(mRanges, forKey: "items")
                            do {
                               try context.save()
                                delegateReminder?.refreshTableView()
                                var sendItem : Item?
                                if items.count == 1 {
                                    sendItem = items[0]
                                } else {
                                    sendItem = items.last
                                }
                                delegateListView?.reloadTableView(listItem: sendItem!)
                                dismiss(animated: true, completion: nil)
                           } catch {
                               print(error)
                           }
                        }
                    }
                } 
            } catch {
                print("Error")
            }
        } else {
            showAlert(alertText: "Error", alertMessage: "Please fill all area")
        }
    }
}

//MARK: - PickerView
extension AddReminderViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    @objc func actionDone() {
        toolBar.removeFromSuperview()
        pickerViewList.removeFromSuperview()
        pickerViewPriority.removeFromSuperview()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerViewPriority {
            return pickerData.count
        } else {
            return data.count
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerViewPriority {
            return pickerData[row]
        } else if pickerView == pickerViewList {
            return data[row].title
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerViewPriority {
            selectedPriority = row
            priorityLabel.text = pickerData[row]
        } else if pickerView == pickerViewList {
            selectedListId = data[row].id
            listNameLabel.text = data[row].title
            circleImage.tintColor = UIColor(named: data[row].color ?? "yellow")
        }
    }
}
