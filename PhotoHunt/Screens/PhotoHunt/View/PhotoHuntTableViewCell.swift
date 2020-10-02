//
//  PhotoHuntTableViewCell.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/2/20.
//

import UIKit

class PhotoHuntTableViewCell: UITableViewCell {
    @IBOutlet weak var customImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.selectionStyle = .none
    }

    func configureData(with image: Image?) {
        guard let image = image, let urlString = image.smallImageURL, let url = URL(string: urlString) else { return }
        customImageView.downloadImage(with: url)
    }
}
