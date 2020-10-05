//
//  ProviderConfigViewController.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/3/20.
//

import UIKit

class ProviderConfigViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - IBOutlets
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.tableFooterView = UIView()
    }
}

// MARK: - Extensions
// MARK: UITableViewDelegate
extension ProviderConfigViewController: UITableViewDelegate {
    
}

// MARK: UITableViewDataSource
extension ProviderConfigViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        PhotoHuntViewController.providerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderTableViewCell", for: indexPath) as? ProviderTableViewCell else {
            fatalError()
        }
        
        let provider = PhotoHuntViewController.providerList[indexPath.row]
        cell.providerNameLabel.text = provider.name
        cell.onOffSwitch.isOn = provider.isOn
        cell.rowIndex = indexPath.row
        cell.passMessageDelegate = self
        
        return cell
    }
}

extension ProviderConfigViewController: PassMessage {
    func showAlert(_ alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}
