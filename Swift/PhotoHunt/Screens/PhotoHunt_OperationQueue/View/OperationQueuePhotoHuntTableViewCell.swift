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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.customImageView.image = nil
    }
    
    func configureData(with imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        customImageView.downloadImage(with: url)
    }
}
