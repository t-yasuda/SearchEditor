//
//  SiteCollectionViewCell.swift
//  SearchEditor
//
//  Created by nttr on 2017/10/02.
//  Copyright © 2017年 nttr. All rights reserved.
//

import UIKit

protocol SiteCollectionViewCellDelegate {
    func didTapDelegate()
}

class SiteCollectionViewCell: UICollectionViewCell {

    var delegate: SiteCollectionViewCellDelegate?
    
    @IBOutlet var siteImageView: UIImageView!
    @IBOutlet var siteLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
