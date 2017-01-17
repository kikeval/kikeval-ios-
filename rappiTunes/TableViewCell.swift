//
//  TableViewCell.swift
//  rappiTunes
//
//  Created by HEART on 1/13/17.
//  Copyright © 2017 kalpani. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

   
    @IBOutlet weak var imageVIewApp: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var categoryLb: UILabel!
    @IBOutlet weak var dateLb: UILabel!
    
    override func awakeFromNib() {
        
        
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
