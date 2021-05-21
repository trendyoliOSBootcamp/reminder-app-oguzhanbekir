//
//  ListViewController.swift
//  ReminderApp
//
//  Created by Oguzhan Bekir on 13.05.2021.
//

import UIKit
import CoreData

protocol ListViewUpdateDelegate {
    func reloadTableView(listItem: Item)
}

final class ListViewController: UIViewController, ListViewUpdateDelegate {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    var data: ListOfReminder?
    var delegate : ReminderUpdateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        titleLabel.text = data?.title
        titleLabel.textColor = UIColor(named: data?.color ?? "gray")
        if data?.items?.count == 0 {
            tableView.isHidden = true
        }

        // Style of tab bar
        self.navigationController?.navigationBar.barTintColor  = UIColor(named: "backgroundGray")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }

    @IBAction func newReminderButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(identifier: "AddNewReminderVC") as! AddReminderViewController
        viewController.data.append(data!)
        viewController.delegateListView = self
        present(viewController, animated: true, completion: nil)
    }
    
    func reloadTableView(listItem: Item) {
        delegate?.refreshTableView()
        data?.items?.append(ItemArray(id: listItem.id, title: listItem.title, notes: listItem.notes, flag: listItem.flag, priority: listItem.priority))
        tableView.isHidden = false
        tableView.reloadData()
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (data?.items!.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "listDetailCell") as? DetailListViewTableViewCell else { fatalError()  }
        cell.titleLabel.text = data?.items?[indexPath.row].title
        cell.priorityLabel.text! = String(repeating: "!", count: data?.items?[indexPath.row].priority ?? 0)
        cell.priorityLabel.textColor = UIColor(named: data?.color ?? "gray")
        if data?.items?[indexPath.row].flag == false {
            cell.flagImage.isHidden = true
        } else {
            cell.flagImage.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Flag action
        let archive = UIContextualAction(style: .normal,
                                         title: "Flag") { [weak self] (action, view, completionHandler) in
                                            self?.handleMarkFlag(forRowAt: indexPath)
                                            completionHandler(true)
        }
        archive.backgroundColor = .systemOrange

        // Trash action
        let trash = UIContextualAction(style: .destructive,
                                       title: "Delete") { [weak self] (action, view, completionHandler) in
                                        self?.handleMoveToTrash(forRowAt: indexPath)
                                        completionHandler(true)
        }
        trash.backgroundColor = .systemRed

        // Details action
        let unread = UIContextualAction(style: .normal,
                                       title: "Details") { [weak self] (action, view, completionHandler) in
                                        self?.handleDetails()
                                        completionHandler(true)
        }
        unread.backgroundColor = .systemGray

        let configuration = UISwipeActionsConfiguration(actions: [trash, archive, unread])

        return configuration
    }
    
    private func handleDetails() {
       
    }

    private func handleMoveToTrash(forRowAt: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReminderList")

        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    var items: [Item] = []
                        guard let pastItems = result.value(forKey: "items") as? Items else { return }
                        for element in pastItems.items {
                            if element.id != data?.items?[forRowAt.row].id {
                                items.append(Item(id: element.id!, title: element.title, notes: element.notes, flag: element.flag, priority: element.priority))
                            }
                        }
                    
                    let mRanges = Items(items: items)
                        result.setValue(mRanges, forKey: "items")
                        do {
                           try context.save()
                       } catch {
                           print(error)
                       }
                }
                delegate?.refreshTableView()
                data?.items?.remove(at: forRowAt.row)
                tableView.reloadData()
            }
        } catch {
            print("Error")
        }
    }

    private func handleMarkFlag(forRowAt: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReminderList")

        do {
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                var flag:Bool?
                for result in results as! [NSManagedObject] {
                    var items: [Item] = []

                    guard let pastItems = result.value(forKey: "items") as? Items else { return }

                    for element in pastItems.items {
                        if element.id == data?.items?[forRowAt.row].id {
                            flag =  element.flag! ? false : true
                            items.append(Item(id: element.id!, title: element.title, notes: element.notes, flag: flag, priority: element.priority))
                        } else {
                            items.append(Item(id: element.id!, title: element.title, notes: element.notes, flag: element.flag, priority: element.priority))
                        }
                    }
                    
                    let mRanges = Items(items: items)
                        result.setValue(mRanges, forKey: "items")
                        do {
                           try context.save()
                       } catch {
                           print(error)
                       }
                }
                delegate?.refreshTableView()
                
                data?.items?[forRowAt.row].flag = flag
                tableView.reloadData()
            } 
        } catch {
            print("Error")
        }
    }    
}
