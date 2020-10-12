//
//  OperationQueuePhotoHuntViewController.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/2/20.
//

import UIKit

class OperationQueuePhotoHuntViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            self.tableView.keyboardDismissMode = .onDrag
        }
    }
    
    // MARK: - Private properties
    private let cache = NSCache<NSString, FilterImage>()
    private var dataSource: [Section] {
        self.accessDataQueue.sync(flags: .barrier, execute: {
            return self._dataSource
        })

//        if #available(iOS 13.0, *) {
//            print("accessing tableView using operationQueue")
//            self.operationQueue.addBarrierBlock {
//                return self._dataSource
//            }
//        } else {
//            print("adding tableView using accessDataQueue")
//            self.accessDataQueue.sync {
//                return self._dataSource
//            }
//        }
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
    
    private func addQueryToProviders(_ query: String) {
        for index in 0..<ProviderManager.sharedManager.providerList.count where ProviderManager.sharedManager.providerList[index].isOn {
            ProviderManager.sharedManager.providerList[index].addQueryToParameters(with: query)
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
            self.addQueryToProviders(keyword)
            self.cache.removeAllObjects()
            self._dataSource.removeAll()
            self.tableView.reloadData()
            
            let doneOperations = BlockOperation {
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
            var added = false

            for provider in ProviderManager.sharedManager.providerList where provider.isOn {
                guard let urlRequest = self.configUrlRequest(provider: provider) else { return }

                let fetchDataOperation = FetchApisOperation(urlRequest: urlRequest, provider: provider)
                doneOperations.addDependency(fetchDataOperation)

                operationQueue.addOperation(fetchDataOperation)
                if !added {
                    added = true
                    operationQueue.addOperation(doneOperations)
                }

                fetchDataOperation.completionBlock = {
                    if fetchDataOperation.isCancelled {
                        print("canceled canceled")
                        return
                    }
                    guard let section = fetchDataOperation.section else {
                        return
                    }
                    self.accessDataQueue.async(flags: .barrier, execute: {
                        self._dataSource.append(section)
                    })
//                    if #available(iOS 13.0, *) {
//                        print("adding using operationQueue \(section.provider.name)")
//                        self.operationQueue.addBarrierBlock {
//                            self._dataSource.append(section)
//                        }
//                    } else {
//                        print("adding using accessDataQueue \(section.provider.name)")
//                        self.accessDataQueue.async(flags: .barrier, execute: {
//                            self._dataSource.append(section)
//                        })
//                    }
                }
            }
        } else {
            searchDispatchWorkItem?.cancel()
        }
    }
}

// MARK: - Extensions
// MARK: UITableViewDelegate
extension OperationQueuePhotoHuntViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dataSource[section].provider.name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.dataSource.count
    }
    
    // MARK: - UIScrollView Delegate methods
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
      if !decelerate {
        resumeAllOperations()
      }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      resumeAllOperations()
    }
    
    // MARK: - operation management
    
    func suspendAllOperations() {
      operationQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        operationQueue.isSuspended = false
    }
}

// MARK: UITableViewDataSource
extension OperationQueuePhotoHuntViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataSource[section].dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OperationQueuePhotoHuntTableViewCell", for: indexPath) as? OperationQueuePhotoHuntTableViewCell else {
            fatalError()
        }
        
        cell.customImageView.image = #imageLiteral(resourceName: "noImage80")
        cell.activityIndicator.startAnimating()
        if let imageUrl = self.dataSource[indexPath.section].dataSource[indexPath.row].imageUrl {
            // if image is already in the cache -> use it, otherwise download
            let cacheKey = imageUrl as NSString
            let filter = self.dataSource[indexPath.section].provider.imageFilterType.cIFilterType
            if let filterImage = cache.object(forKey: cacheKey) {
                print("caching")
                // If the filterType is different
                if filterImage.filterType != filter {
                    // Apply new filter
                    let imageFilterOperation = ImageFilterOperation(inputImage: filterImage.image, filter: filter)
                    operationQueue.addOperation(imageFilterOperation)
                    
                    imageFilterOperation.completionBlock = {
                        print("filtering")
                        // Add new image back to the cache
                        if let image = imageFilterOperation.outputImage {
                            let filteredImage = FilterImage(filterType: filter, image: image)
                            OperationQueue.main.addOperation {
                                self.cache.setObject(filteredImage, forKey: cacheKey)
                                cell.customImageView.image = filteredImage.image
                                cell.activityIndicator.stopAnimating()
                            }
                        }
                    }
                } else {
                    print("caching")
                    cell.customImageView.image = filterImage.image
                    cell.activityIndicator.stopAnimating()
                }
            } else {
                let downloadImageOperation = DownloadImageOperation(url: imageUrl)
                print("downloading")
                operationQueue.addOperation(downloadImageOperation)

                downloadImageOperation.completionBlock = {
                    if let image = downloadImageOperation.contentImage {
                        OperationQueue.main.addOperation {
                            print("downloaded")
                            if filter != .normal {
                                let imageFilterOperation = ImageFilterOperation(inputImage: image, filter: filter)
                                self.operationQueue.addOperation(imageFilterOperation)

                                imageFilterOperation.completionBlock = {
                                    // Add new image back to the cache
                                    if let outputImage = imageFilterOperation.outputImage {
                                        let filteredImage = FilterImage(filterType: filter, image: outputImage)
                                        OperationQueue.main.addOperation {
                                            self.cache.setObject(filteredImage, forKey: cacheKey)
                                            cell.customImageView.image = outputImage
                                            cell.activityIndicator.stopAnimating()
                                        }
                                    }
                                }
                            } else {
                                // add it to cache after downloaded
                                let filterImage = FilterImage(filterType: .normal, image: image)
                                self.cache.setObject(filterImage, forKey: cacheKey)
                                cell.customImageView.image = image
                                cell.activityIndicator.stopAnimating()
                            }
                        }
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
extension OperationQueuePhotoHuntViewController: UISearchBarDelegate {
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

// MARK: PassObject Delegate
extension OperationQueuePhotoHuntViewController: PassObject {
    func configChanged() {
        if let searchText = self.searchText {
            searchData(with: searchText)
        }
        
        self.tableView.reloadData()
    }
}
