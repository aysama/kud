//
//  tableViewCell.swift
//  kud
//
//  Created by Samagbeyi Ayoola on 29/04/2019.
//  Copyright © 2019 Me. All rights reserved.
//

import UIKit

class tableViewCell: UITableViewCell {

    @IBOutlet weak var txtLbl: UILabel!
    @IBOutlet weak var txt2Lbl: UILabel!
    @IBOutlet weak var txt3Lbl: UILabel!
    @IBOutlet weak var txt4Lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
