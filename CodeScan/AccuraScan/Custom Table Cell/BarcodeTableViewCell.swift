//
//  BarcodeTableViewCell.swift
//  AccuraSDK
//
//  Created by Technozer on 23/02/21.
//  Copyright © 2021 Elite Development LLC. All rights reserved.
//

import UIKit

class BarcodeTableViewCell: UITableViewCell {

    @IBOutlet weak var lableName: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
