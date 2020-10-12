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
    @IBOutlet weak var filterPickerView: UIPickerView!
    
    // MARK: - Public properties
    var rowIndex: Int = 0
    weak var passMessageDelegate: PassObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.filterPickerView.dataSource = 
    }

    @IBAction func onOffSwitchValueChanged(_ sender: Any) {
        ProviderManager.sharedManager.providerList[rowIndex].isOn = onOffSwitch.isOn
        if !canSwitch() {
            ProviderManager.sharedManager.providerList[rowIndex].isOn = true
            onOffSwitch.isOn = !onOffSwitch.isOn
            
            let alert = UIAlertController(title: "Invalid Action", message: "At least one provider has to be on", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            passMessageDelegate?.showAlert(alert)
        }
    }
    
    private func canSwitch() -> Bool {
        // Check all items in providerList, if found one is ON -> can switch
        for provider in ProviderManager.sharedManager.providerList where provider.isOn {
                return true
            }
        // If all are off -> can't switch
        return false
    }
}
