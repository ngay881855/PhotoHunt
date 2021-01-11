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
    @IBOutlet weak private var filterPickerView: UIPickerView!
    
    // MARK: - Public properties
    var rowIndex: Int = 0
    weak var passMessageDelegate: PassObject?
    
    // MARK: - Private properties
    private var imageFilterTypes: [ImageFilterType] = [
        ImageFilterType(name: "Normal", cIFilterType: .normal),
        ImageFilterType(name: "Sepia Tone", cIFilterType: .sepiaFilter),
        ImageFilterType(name: "Bloom", cIFilterType: .bloomFilter),
        ImageFilterType(name: "Comic Effect", cIFilterType: .comicEffectFilter),
        ImageFilterType(name: "Chrome", cIFilterType: .chromeFilter),
        ImageFilterType(name: "Fade", cIFilterType: .fadeFilter)
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        let row = self.getRowIndexBy(cIFilterType: ProviderManager.sharedManager.providerList[self.rowIndex].imageFilterType.cIFilterType)
        self.filterPickerView.selectRow(row, inComponent: 0, animated: true)
    }

    @IBAction private func onOffSwitchValueChanged(_ sender: Any) {
        ProviderManager.sharedManager.providerList[rowIndex].isOn = onOffSwitch.isOn
        if !canSwitch() {
            ProviderManager.sharedManager.providerList[rowIndex].isOn = true
            onOffSwitch.isOn.toggle()
            
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
    
    private func getRowIndexBy(cIFilterType: CIFilterType) -> Int {
        imageFilterTypes.firstIndex { item -> Bool in
            item.cIFilterType == cIFilterType
        } ?? 0
    }
}

extension ProviderTableViewCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.imageFilterTypes.count
    }
}

extension ProviderTableViewCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.imageFilterTypes[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ProviderManager.sharedManager.providerList[rowIndex].imageFilterType = self.imageFilterTypes[row]
        print(row)
        print(self.imageFilterTypes[row])
        print(ProviderManager.sharedManager.providerList[rowIndex].imageFilterType)
    }
}
