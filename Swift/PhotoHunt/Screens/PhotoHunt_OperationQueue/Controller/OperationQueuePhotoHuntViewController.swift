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
    
    private var _dataSource: [Section] = []
    private var dataSource: [Section] {
        self.accessDataQueue.sync {
            return self._dataSource
        }

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
    
    private var _downloadsInProgress: [IndexPath: Operation] = [:]
    private var downloadsInProgress: [IndexPath: Operation] {
        self.accessDataQueue.sync {
            return self._downloadsInProgress
        }
    }
    
    private var accessDataQueue = DispatchQueue(label: "com.photohunt.accessDataQueue", attributes: .concurrent)
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
            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
        
        guard let url = urlComponents.url else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        if let headers = provider.header {
            urlRequest.allHTTPHeaderFields = headers
        }
        
        return urlRequest
    }
    
    private func searchData(with keyword: String) {
        if keyword.count >= Constants.minCharactersToSearch {
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

                self.operationQueue.addOperation(fetchDataOperation)
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
                    self.accessDataQueue.async(flags: .barrier) {
                        self._dataSource.append(section)
                    }
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
        cancelInvisiblePaths()
        resumeAllOperations()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        cancelInvisiblePaths()
        resumeAllOperations()
    }
    
    // MARK: - operation management
    
    func suspendAllOperations() {
        operationQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        operationQueue.isSuspended = false
    }
    
    private func cancelInvisiblePaths() {
        if let visiblePaths = tableView.indexPathsForVisibleRows {
            var allPendingPaths = Set(_downloadsInProgress.keys)
            let visiblePaths = Set(visiblePaths)
            
            allPendingPaths.subtract(visiblePaths)
            
            for indexPath in allPendingPaths {
                if let operation = _downloadsInProgress[indexPath] {
                    operation.cancel()
                }
            }
        }
    }
}

// MARK: UITableViewDataSource
extension OperationQueuePhotoHuntViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataSource[section].dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OperationQueuePhotoHuntTableViewCell", for: indexPath) as? OperationQueuePhotoHuntTableViewCell else {
            fatalError("Can not dequeue cell")
        }
        
        cell.customImageView.image = UIImage(named: "noImage80")
        cell.activityIndicator.startAnimating()
        if let imageUrl = self.dataSource[indexPath.section].dataSource[indexPath.row].imageUrl {
            // Create cacheKey as NSString
            let cacheKey = imageUrl as NSString
            // Get the filer type for this image from the section
            let filter = self.dataSource[indexPath.section].provider.imageFilterType.cIFilterType
            // Try to get the image from cache, if image is already in the cache -> use it
            if let cacheImage = self.getImageFromCache(cacheKey: cacheKey) {
                self.applyFilter(forImage: cacheImage, withFilter: filter) { image in
                    OperationQueue.main.addOperation {
                        self.cache.setObject(image, forKey: cacheKey)
                        cell.customImageView.image = image.image
                        cell.activityIndicator.stopAnimating()
                    }
                }
            } else { // Image is not in cache -> download
                let downloadImageOperation = DownloadImageOperation(url: imageUrl)
                _downloadsInProgress[indexPath] = downloadImageOperation
                operationQueue.addOperation(downloadImageOperation)

                downloadImageOperation.completionBlock = {
                    self.accessDataQueue.async(flags: .barrier) {
                        self._downloadsInProgress[indexPath] = nil
                    }
                    
                    if let image = downloadImageOperation.contentImage {
                        let filterImage = FilterImage(filterType: .normal, image: image)
                        self.applyFilter(forImage: filterImage, withFilter: filter) { filteredImage in
                            OperationQueue.main.addOperation {
                                self.cache.setObject(filteredImage, forKey: cacheKey)
                                cell.customImageView.image = filteredImage.image
                                cell.activityIndicator.stopAnimating()
                            }
                        }
                    } else {
                        cell.activityIndicator.stopAnimating()
                    }
                }
            }
        } else {
            print("url nil")
        }
        
        return cell
    }
    
    private func getImageFromCache(cacheKey: NSString) -> FilterImage? {
        guard let cacheImage = cache.object(forKey: cacheKey) else {
            return nil
        }
        return cacheImage
    }
    
    private func applyFilter(forImage inputImage: FilterImage, withFilter filter: CIFilterType, completion: @escaping (FilterImage) -> Void) {
        if inputImage.filterType != filter { // if the new filter type is different than the current filter type of the image
            // Apply new filter
            let imageFilterOperation = ImageFilterOperation(inputImage: inputImage.image, filter: filter)
            self.operationQueue.addOperation(imageFilterOperation)
            
            imageFilterOperation.completionBlock = {
                // Add new image back to the cache
                if let image = imageFilterOperation.outputImage {
                    let outputImage = FilterImage(filterType: filter, image: image)
                    completion(outputImage)
                }
            }
        } else { // otherwise just simply return it
            completion(inputImage)
        }
    }
}

// MARK: UISearchBarDelegate
extension OperationQueuePhotoHuntViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.operationQueue.cancelAllOperations()
        if let timer = self.timer {
            timer.invalidate()
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: Constants.timerIntervalToSearch, repeats: false) {_ in
            self.searchData(with: searchText)
        }
        
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
