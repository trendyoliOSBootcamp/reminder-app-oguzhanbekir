//
//  HomeTableViewCell.swift
//  ReminderApp
//
//  Created by Oguzhan Bekir on 13.05.2021.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
