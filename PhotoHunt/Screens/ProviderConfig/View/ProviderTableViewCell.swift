//
//  ProviderTableViewCell.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/3/20.
//

import UIKit

class ProviderTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!
    
    // MARK: - Public properties
    var rowIndex: Int = 0
    var passMessageDelegate: PassMessage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onOffSwitchValueChanged(_ sender: Any) {
        PhotoHuntViewController.providerList[rowIndex].isOn = onOffSwitch.isOn
        if !canSwitch() {
            PhotoHuntViewController.providerList[rowIndex].isOn = true
            onOffSwitch.isOn = !onOffSwitch.isOn
            
            let alert = UIAlertController(title: "Invalid Action", message: "At least one provider has to be on", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            passMessageDelegate?.showAlert(alert)
        }
    }
    
    private func canSwitch() -> Bool {
        // Check all items in providerList, if found one is ON -> can switch
        for provider in PhotoHuntViewController.providerList where provider.isOn {
                return true
            }
        // If all are off -> can't switch
        return false
    }
}
