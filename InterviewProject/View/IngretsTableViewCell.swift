//
//  IngretsTableViewCell.swift
//  CockTailProject
//
//  Created by Ruoming Gao on 4/18/23.
//  Copyright © 2023 Ruoming Gao. All rights reserved.
//

import UIKit

class IngretsTableViewCell: UITableViewCell {

    @IBOutlet weak var IngretsLabel: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
