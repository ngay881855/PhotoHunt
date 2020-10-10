//
//  OperationQueuePhotoHuntTableViewCell.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/2/20.
//

import UIKit

class OperationQueuePhotoHuntTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var customImageView: UIImageView!
    
    // MARK: - Private properties
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.selectionStyle = .none
    }

    func configureData(with imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        customImageView.downloadImage(with: url)
    }
}
