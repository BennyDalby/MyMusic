//
//  MusicCollectionViewCell.swift
//  MyMusic
//
//  Created by Test on 6/22/20.
//  Copyright © 2020 BennyTest. All rights reserved.
//

import UIKit

class MusicCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var artistImage: UIImageView!
    
    @IBOutlet weak var albumImage: UIImageView!
    
    @IBOutlet weak var albumName: UILabel!
    
    @IBOutlet weak var artistName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.purple.withAlphaComponent(0.55)
    }

}
