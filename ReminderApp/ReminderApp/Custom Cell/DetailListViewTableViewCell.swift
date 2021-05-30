//
//  DetailListViewTableViewCell.swift
//  ReminderApp
//
//  Created by Oguzhan Bekir on 16.05.2021.
//

import UIKit

final class DetailListViewTableViewCell: UITableViewCell {
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
