//
//  HomeVCViewController.swift
//  ReminderApp
//
//  Created by Oguzhan Bekir on 13.05.2021.
//

import UIKit
import CoreData

protocol ReminderUpdateDelegate: AnyObject {
    func refreshTableView()
}

final class HomeViewController: UIViewController, ReminderUpdateDelegate {
    let searchController = UISearchController(searchResultsController: ResultVC())
    
    var data: [ListOfReminder] = []
    var dataList = [String]()

    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    let mainStoryboard = UIStoryboard(name: "Main", bundle: .main)
    
    @IBOutlet weak var flaggedCountLabel: UILabel!
    @IBOutlet weak var allReminderCountLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak var allReminderView: UIView!
    @IBOutlet weak var flagReminderView: UIView!
    @IBOutlet weak var searchView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if !launchedBefore  {
            createInitialData()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
        getList()
        
        configureSearchController()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        let tapSelectList = UITapGestureRecognizer(target: self, action: #selector(self.selectList(_:)))
        allReminderView.addGestureRecognizer(tapSelectList)
        let tapSelectFlagged = UITapGestureRecognizer(target: self, action: #selector(self.selectList(_:)))
        flagReminderView.addGestureRecognizer(tapSelectFlagged)
        
    }
    
    func createInitialData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let newList = NSEntityDescription.insertNewObject(forEntityName: "ReminderList", into: context)
        newList.setValue("Shopping", forKey: "title")
        newList.setValue(UUID(), forKey: "id")
        newList.setValue("red", forKey: "color")
        newList.setValue("cart.circle.fill", forKey: "image")
        
        var books: [Item] = []
        books.append(Item(id: UUID(), title: "Elma almayı unutma!", notes: "Elma almayı unutma", flag: true, priority: 3))
        let items = Items(items: books)
        
        newList.setValue(items, forKey: "items")
        
        do {
            try context.save()
        } catch  {
            print("Kaydedilemedi...")
        }
    }
    
    @objc func selectList(_ sender: UITapGestureRecognizer? = nil) {
        if sender?.view == allReminderView {
            let viewController = mainStoryboard.instantiateViewController(identifier: "AllListVC") as! AllListViewController
            viewController.data = data
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            let viewController = mainStoryboard.instantiateViewController(identifier: "AllListVC") as! AllListViewController
            var filteredData: [ListOfReminder] = []
            data.forEach { (reminder) in
                if let flagItem = reminder.items?.filter({$0.flag == true }) {
                    if flagItem.count > 0 {
                        let reminder = ListOfReminder(id: reminder.id, title: reminder.title, color: reminder.color, image: reminder.image, items: flagItem)
                        filteredData.append(reminder)
                    }
                }
            }
            viewController.data = filteredData
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    private func getList() {
        data.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ReminderList")

        do {
           let results = try context.fetch(fetchRequest)
           if results.count > 0 {
               for result in results as! [NSManagedObject] {
                    guard let color = result.value(forKey: "color") as? String else { return }
                    guard let title = result.value(forKey: "title") as? String else { return }
                    guard let image = result.value(forKey: "image") as? String else { return }
                    guard let id = result.value(forKey: "id") as? UUID else { return }
                    guard let test = result.value(forKey: "items") as? Items else { return }
                    var itemList = [ItemArray]()

                    for element in test.items {
                        itemList.append(ItemArray(id: element.id, title: element.title, notes: element.notes, flag: element.flag, priority: element.priority))
                    }
                    data.append(ListOfReminder(id: id, title: title, color: color, image: image, items: itemList))
               }
            var reminderCount = 0
            var flagCount = 0
            for item in data {
                reminderCount += item.items!.count
                for item in item.items! {
                    if item.flag! {
                        flagCount += 1
                    }
                }
            }
            allReminderCountLabel.text = "\(reminderCount)"
            flaggedCountLabel.text = "\(flagCount)"
            self.tableView.reloadData()
           }
        } catch {
           print("Error")
        }
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    @IBAction func addListButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(identifier: "AddNewListVC") as! AddNewListViewController
        viewController.delegate = self
        viewController.data = data
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func addNewReminderButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(identifier: "AddNewReminderVC") as! AddReminderViewController
        viewController.data = data
        viewController.delegateReminder = self
        present(viewController, animated: true, completion: nil)
        
    }
    func refreshTableView() {
        getList()
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell") as? HomeTableViewCell else { fatalError()  }
        cell.mainTitleLabel.text = data[indexPath.row].title
        cell.countLabel.text = String(data[indexPath.row].items?.count ?? 0)
        cell.thumbnail.image = UIImage(systemName: data[indexPath.row].image ?? "list.bullet")
        cell.thumbnail.tintColor = UIColor(named: data[indexPath.row].color ?? "blue")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(identifier: "listVC") as! ListViewController
        viewController.data = data[indexPath.row]
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

extension HomeViewController: UISearchResultsUpdating, UISearchBarDelegate{
    func updateSearchResults(for searchController: UISearchController)  {
        guard let text = searchController.searchBar.text else { return }
        guard let vc = searchController.searchResultsController as? ResultVC else { fatalError() }
        
        var filteredData: [ListOfReminder] = []
        data.forEach { (reminder) in
            if let itemArray2 = reminder.items?.filter({$0.title?.lowercased().contains(text.lowercased()) ?? false }) {
                if itemArray2.count > 0 {
                    let reminder2 = ListOfReminder(id: reminder.id, title: reminder.title, color: reminder.color, image: reminder.image, items: itemArray2)
                    filteredData.append(reminder2)
                }
            }
        }
        vc.data = filteredData
        vc.myTableView.reloadData()
    }
}

final class ResultVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myTableView: UITableView!
    var data : [ListOfReminder]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let barHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height

        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        data?.count ?? 0
    }
    

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        data?[section].title ?? ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data?[section].items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = String(repeating: "!", count: data?[indexPath.section].items?[indexPath.row].priority ?? 0) + " " + (data?[indexPath.section].items?[indexPath.row].title)!
        return cell
    }
}
