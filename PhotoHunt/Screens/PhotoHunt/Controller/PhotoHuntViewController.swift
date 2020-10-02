//
//  PhotoHuntViewController.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/2/20.
//

import UIKit

class PhotoHuntViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private properties
    private var dataSource: DataSource {
        accessDataQueue.sync {
            return _dataSource
        }
    }
    
    private var _dataSource: DataSource = DataSource()
    private var accessDataQueue: DispatchQueue = DispatchQueue(label: "com.photohunt.accessDataQueue", attributes: .concurrent)
    private var searchDispatchWorkItem: DispatchWorkItem?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadDefaultData()
        setupUI()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - UISetup/Helpers/Actions
    private func setupUI() {
        self.tableView.tableFooterView = UIView()
    }
    
    private func loadDefaultData() {
        let provider = Provider(name: "Splash", url: "http://www.splashbase.co/api/v1/images/search?query=", isEnable: true)
        self._dataSource.providerList.append(provider)
    }
    
    private func downloadData(withURL urlStr: String) {
        let dispatchGroup: DispatchGroup = DispatchGroup()
        guard let url = URL(string: urlStr) else {
            return
        }
        dispatchGroup.enter()
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let responseData = try JSONDecoder().decode(SplashApiResponse.self, from: data)
                guard let images = responseData.images else { return }
                self.accessDataQueue.async(flags: .barrier, execute: {
                    self._dataSource.dictProviderData["Splash"] = images
                })
                dispatchGroup.leave()
            } catch {
                print(error)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.tableView.reloadData()
        }
    }
}

// MARK: - Extensions
// MARK: UITableViewDelegate
extension PhotoHuntViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.dataSource.providerList[section].name
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.dataSource.providerList.count
    }
}

// MARK: UITableViewDataSource
extension PhotoHuntViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let providerName = self.dataSource.providerList[section].name
        guard let count = self.dataSource.dictProviderData[providerName]?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoHuntTableViewCell", for: indexPath) as? PhotoHuntTableViewCell else {
            fatalError()
        }
        let providerName = self.dataSource.providerList[indexPath.section].name
        let image = self.dataSource.dictProviderData[providerName]?[indexPath.row]
        cell.configureData(with: image)
        return cell
    }
}

// MARK: UISearchBarDelegate
extension PhotoHuntViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 5 {
            searchDispatchWorkItem?.cancel()
            searchDispatchWorkItem = DispatchWorkItem(block: {
                print("searching: \(searchText)")
                self.downloadData(withURL: self.dataSource.providerList[0].url + searchText)
            })
            if let workItem = searchDispatchWorkItem {
                DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: workItem)
            }
        } else {
            searchDispatchWorkItem?.cancel()
        }
    }
}
