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
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            self.tableView.keyboardDismissMode = .onDrag
        }
    }
    
    // MARK: - Private properties
    private let cache = NSCache<NSString, CIImage>()
    private var dataSource: [Section] {
        self.accessDataQueue.sync(flags: .barrier, execute: {
            return self._dataSource
        })
    }
    
    private var _dataSource: [Section] = []
    private var accessDataQueue: DispatchQueue = DispatchQueue(label: "com.photohunt.accessDataQueue", attributes: .concurrent)
    private let operationQueue = OperationQueue()
    private var searchDispatchWorkItem: DispatchWorkItem?
    private var searchText: String?
    private var timer: Timer?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadProviderData()
        setupUI()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let configProviderViewController = segue.destination as? ConfigProviderViewController {
            configProviderViewController.delegate = self
        }
    }
    
    // MARK: - UISetup/Helpers/Actions
    private func setupUI() {
        self.tableView.tableFooterView = UIView()
    }
    
    private func loadProviderData() {
        var provider = Provider(name: Splash.name, baseUrl: Splash.baseUrl, parameters: Splash.parameters, isOn: true)
        PhotoHuntViewController.providerList.append(provider)
        provider = Provider(name: Pexels.name, baseUrl: Pexels.baseUrl, parameters: Pexels.parameters, header: Pexels.headers, isOn: true)
        PhotoHuntViewController.providerList.append(provider)
        provider = Provider(name: PixaBay.name, baseUrl: PixaBay.baseUrl, parameters: PixaBay.parameters, isOn: true)
        PhotoHuntViewController.providerList.append(provider)
    }
    
    private func downloadData(withURLRequest urlRequest: URLRequest, provider: Provider, completion: @escaping () -> Void) {
        ServiceManager.manager.request(withRequest: urlRequest) { (data, error) in
            guard let data = data as? Data else {
                if let error = error {
                    print(error)
                }
                completion()
                return
            }
            do {
                let responseObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                guard let dictionary = responseObj as? [String: Any] else { completion(); return }
                var newSection: [ImageProtocol] = []
                switch provider.name {
                case Splash.name:
                    guard let arrayItems = dictionary["images"] as? [[String: Any]], !arrayItems.isEmpty else { completion(); return }
                    arrayItems.forEach { dictionary in
                        newSection.append(SplashImageInfo(dict: dictionary))
                    }
                case Pexels.name:
                    guard let arrayItems = dictionary["photos"] as? [[String: Any]], !arrayItems.isEmpty else { completion(); return }
                    arrayItems.forEach { dictionary in
                        newSection.append(PexelsImageInfo(dict: dictionary))
                    }
                case PixaBay.name:
                    guard let arrayItems = dictionary["hits"] as? [[String: Any]], !arrayItems.isEmpty else { completion(); return }
                    arrayItems.forEach { dictionary in
                        newSection.append(PixabayImageInfo(dict: dictionary))
                    }
                default:
                    break
                }
                if newSection.count > 0 {
                    self.accessDataQueue.async(flags: .barrier, execute: {
                        print("adding images")
                        
                        let section = Section(provider: provider, dataSource: newSection)
                        self._dataSource.append(section)
                    })
                }
                completion()
            } catch {
                print(error)
                completion()
                return
            }
        }
    }
    
    private func addQueryToProviders(_ query: String) {
        for index in 0..<PhotoHuntViewController.providerList.count where PhotoHuntViewController.providerList[index].isOn {
            PhotoHuntViewController.providerList[index].addQueryToParameters(with: query)
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
        if keyword.count >= Constant.minCharactersToSearch {
            searchDispatchWorkItem?.cancel()
            searchDispatchWorkItem = DispatchWorkItem(block: {
                self.addQueryToProviders(keyword)
                self.cache.removeAllObjects()
                self._dataSource.removeAll()

                let dispatchGroup: DispatchGroup = DispatchGroup()
                for provider in PhotoHuntViewController.providerList where provider.isOn {
                    dispatchGroup.enter()
                    DispatchQueue.global().async {
                        guard let urlRequest = self.configUrlRequest(provider: provider) else { dispatchGroup.leave(); return }

                        self.downloadData(withURLRequest: urlRequest, provider: provider, completion: {
                            dispatchGroup.leave()
                        })
                    }
                }
                dispatchGroup.notify(queue: DispatchQueue.main) {
                    print("refreshing tableView")
                    self.tableView.reloadData()
                }
            })
            if let workItem = searchDispatchWorkItem {
                DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: workItem)
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
        return self.dataSource[section].provider.name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.dataSource.count
    }
}

// MARK: UITableViewDataSource
extension PhotoHuntViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataSource[section].dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoHuntTableViewCell", for: indexPath) as? PhotoHuntTableViewCell else {
            fatalError()
        }
        if let imageUrl = self.dataSource[indexPath.section].dataSource[indexPath.row].imageUrl {
            // if image is already in the cache -> use it, otherwise download
            let cacheKey = imageUrl as NSString
            if let image = cache.object(forKey: cacheKey) {
                print("caching image")
                cell.customImageView.image = UIImage(ciImage: image)
            } else {
                print("donwload image")
                cell.configureData(with: imageUrl)
                if let image = cell.customImageView.image {
                    // add it to cache after downloaded
                    if let newImage = CIImage(image: image) {
                        cache.setObject(newImage, forKey: cacheKey)
                    }
                }
            }
        } else {
            print("url nil")
        }
        
        return cell
    }
}

// MARK: UISearchBarDelegate
extension PhotoHuntViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.operationQueue.cancelAllOperations()
        if let timer = self.timer {
            timer.invalidate()
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: Constant.timerIntervalToSearch, repeats: false, block: {_ in
            self.searchData(with: searchText)
        })
        
        self.searchText = searchText
    }
}

extension PhotoHuntViewController: PassObject {
    func configChanged() {
        if let searchText = self.searchText {
            searchData(with: searchText)
        }
        
        self.tableView.reloadData()
    }
}
