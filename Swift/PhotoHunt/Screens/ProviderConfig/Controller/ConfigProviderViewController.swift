//
//  ConfigProviderViewController.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/3/20.
//

import UIKit

class ConfigProviderViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - IBOutlets
    
    // MARK: - Public properties
    weak var delegate: PassObject?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        #warning("use notification to all tabs")
        self.delegate?.configChanged()
    }
}

// MARK: - Extensions
// MARK: UITableViewDelegate
extension ConfigProviderViewController: UITableViewDelegate {
}

// MARK: UITableViewDataSource
extension ConfigProviderViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ProviderManager.sharedManager.providerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderTableViewCell", for: indexPath) as? ProviderTableViewCell else {
            fatalError("Can not dequeue cell")
        }
        
        let provider = ProviderManager.sharedManager.providerList[indexPath.row]
        cell.providerNameLabel.text = provider.name
        cell.onOffSwitch.isOn = provider.isOn
        cell.rowIndex = indexPath.row
        cell.passMessageDelegate = self
        
        return cell
    }
}

extension ConfigProviderViewController: PassObject {
    func showAlert(_ alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}
