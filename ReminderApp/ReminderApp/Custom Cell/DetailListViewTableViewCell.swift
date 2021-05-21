//
//  DetailListViewTableViewCell.swift
//  ReminderApp
//
//  Created by Oguzhan Bekir on 16.05.2021.
//

import UIKit

class DetailListViewTableViewCell: UITableViewCell {
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
