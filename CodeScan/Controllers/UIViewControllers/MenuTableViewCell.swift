//
//  MenuTableViewCell.swift
//  CodeScan
//
//  Created by SSD on 07/06/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell
{


    @IBOutlet weak var lblMenu: UILabel!
    @IBOutlet weak var menuImg: UIImageView!
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    class func nib() -> UINib {
        return UINib(nibName: self.nameOfClass, bundle: nil)
    }
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }
    
}
