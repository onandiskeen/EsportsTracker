//
//  SearchResultCell.swift
//  EsportsTracker
//
//  Created by Onandi Skeen on 11/18/23.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    var task: URLSessionDataTask?

    
    @IBOutlet weak var teamLogo: UIImageView!
    
    @IBOutlet weak var teamName: UILabel!
    
    @IBOutlet weak var gameName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
