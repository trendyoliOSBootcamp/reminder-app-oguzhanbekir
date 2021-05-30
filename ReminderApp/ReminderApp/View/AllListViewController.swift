//
//  AllListViewController.swift
//  ReminderApp
//
//  Created by Oguzhan Bekir on 16.05.2021.
//

import UIKit

final class AllListViewController: UIViewController {
    @IBOutlet private weak var mainTitleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    
    var data : [ListOfReminder]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Style of tab bar
        self.navigationController?.navigationBar.barTintColor  = UIColor(named: "backgroundGray")
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
}

extension AllListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        data!.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        data![section].title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = UIFont.systemFont(ofSize: 26)
        header?.textLabel?.textColor = UIColor(named : data![section].color!)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data![section].items!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "listAllDetailCell") as? DetailListViewTableViewCell else { fatalError()  }
        cell.titleLabel.text = data?[indexPath.section].items?[indexPath.row].title
        cell.priorityLabel.text! = String(repeating: "!", count: data?[indexPath.section].items?[indexPath.row].priority ?? 0)
        cell.priorityLabel.textColor = UIColor(named: data![indexPath.section].color ?? "gray")
        if data![indexPath.section].items?[indexPath.row].flag == false {
            cell.flagImage.isHidden = true
        } else {
            cell.flagImage.isHidden = false
        }
        return cell
    }
}
