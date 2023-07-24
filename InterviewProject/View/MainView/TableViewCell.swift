//
//  TableViewCell.swift
//  interviewProject
//
//  Created by Ruoming Gao on 9/6/19.
//  Copyright © 2019 Ruoming Gao. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
//
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoryLabel: UILabel!
    var categoryLabelText: String?
    var labelString: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryLabel.text = categoryLabelText
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

