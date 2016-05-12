//
//  ContactTableViewCell.swift
//  LikeableContacts
//
//  Created by Igor on 12/05/16.
//  Copyright © 2016 Igor Kislyuk. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    //MARK: - Properties
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var secondNameLabel: UILabel!
    
    @IBOutlet weak var likeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
