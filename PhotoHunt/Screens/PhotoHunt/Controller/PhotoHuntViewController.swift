//
//  PhotoHuntViewController.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/2/20.
//

import UIKit

class PhotoHuntViewController: UIViewController {

    // MARK: - Static vars
    static var providerList: [Provider] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private properties
    private let cache = NSCache<NSString, UIImage>()
    private var dataSource: DataSource {
        accessDataQueue.sync {
            print("accessing data")
            return _dataSource
        }
    }
    
    private var _dataSource: DataSource = DataSource()
    private var accessDataQueue: DispatchQueue = DispatchQueue(label: "com.photohunt.accessDataQueue", attributes: .concurrent)
    private var searchDispatchWorkItem: DispatchWorkItem?
    private var searchText: String?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadDefaultData()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        self._dataSource.providerList.removeAll()
        for provider in PhotoHuntViewController.providerList where provider.isOn {
            self._dataSource.providerList.append(provider)
        }
        if let searchText = self.searchText {
            searchData(with: searchText)
        }
        tableView.reloadData()
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
        var provider = Provider(name: Splash.name, baseUrl: Splash.baseUrl, parameters: Splash.parameters, isOn: true)
        PhotoHuntViewController.providerList.append(provider)
        provider = Provider(name: Pexels.name, baseUrl: Pexels.baseUrl, parameters: Pexels.parameters, header: Pexels.headers, isOn: true)
        PhotoHuntViewController.providerList.append(provider)
        provider = Provider(name: PixaBay.name, baseUrl: PixaBay.baseUrl, parameters: PixaBay.parameters, isOn: true)
        PhotoHuntViewController.providerList.append(provider)
    }
    
    private func downloadData(withURLRequest urlRequest: URLRequest, provider: Provider) {
        let dispatchGroup: DispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DispatchQueue.global().async {
            ServiceManager.manager.request(withRequest: urlRequest) { (data, error) in
                guard let data = data as? Data else {
                    if let error = error {
                        print(error)
                    }
                    return
                }
                do {
                    let responseObj = try JSONDecoder().decode(ApiResponse.self, from: data)
                    self.accessDataQueue.async(flags: .barrier, execute: {
                        print("adding images")
                        if let images = responseObj.images {
                            self._dataSource.dictProviderData[provider.name] = images
                        } else if let images = responseObj.photos {
                            self._dataSource.dictProviderData[provider.name] = images
                        } else if let images = responseObj.hits {
                            self._dataSource.dictProviderData[provider.name] = images
                        }
                    })
                    
                    dispatchGroup.leave()
                    
                } catch {
                    print(error)
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            print("refreshing tableView")
            self.tableView.reloadData()
        }
    }
    
    private func addQueryToProviders(_ query: String) {
        for index in 0..<PhotoHuntViewController.providerList.count where PhotoHuntViewController.providerList[index].isOn {
            PhotoHuntViewController.providerList[index].parameters?[Constant.query] = query
        }
    }

    private func configUrlRequest(provider: Provider) -> URLRequest? {
        guard var urlComponents = URLComponents(string: provider.baseUrl) else { return nil }
        if let parameters = provider.parameters {
            urlComponents.queryItems = parameters.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }
        }
        
        guard let url = urlComponents.url else { return nil}
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        if let headers = provider.header {
            urlRequest.allHTTPHeaderFields = headers
        }
        
        return urlRequest
    }
    
    private func searchData(with keyword: String) {
        if keyword.count >= 5 {
            searchDispatchWorkItem?.cancel()
            searchDispatchWorkItem = DispatchWorkItem(block: {
                self.addQueryToProviders(keyword)
                self.cache.removeAllObjects()
                self._dataSource.dictProviderData.removeAll()
                
                for provider in PhotoHuntViewController.providerList where provider.isOn {
                    guard let urlRequest = self.configUrlRequest(provider: provider) else { return }
                    self.downloadData(withURLRequest: urlRequest, provider: provider)
                }
                
            })
            if let workItem = searchDispatchWorkItem {
                DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: workItem)
            }
        } else {
            searchDispatchWorkItem?.cancel()
        }
        
    }
}

// MARK: - Extensions
// MARK: UITableViewDelegate
extension PhotoHuntViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dataSource.providerList[section].name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
        print(providerName)
        let image = self.dataSource.dictProviderData[providerName]?[indexPath.row]
        if let newImage = image {
            var urlString = String()
            switch providerName {
            case Splash.name:
                urlString = newImage.imageURL ?? String()
            case Pexels.name:
                urlString = newImage.source?.medium ?? String()
            case PixaBay.name:
                urlString = newImage.webFormatURL ?? String()
            default:
                urlString = String()
            }
            cell.customImageView.image = nil
            // if image is already in the cache -> use it, otherwise download
            let cacheKey = urlString as NSString
            if let image = cache.object(forKey: cacheKey) {
                print(cacheKey)
                cell.customImageView.image = image
            } else {
                cell.configureData(with: urlString)
                if let image = cell.customImageView.image {
                    // add it to cache after downloaded
                    cache.setObject(image, forKey: cacheKey)
                }
            }
        }
        
        return cell
    }
}

// MARK: UISearchBarDelegate
extension PhotoHuntViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchData(with: searchText)
        self.searchText = searchText
    }
}
