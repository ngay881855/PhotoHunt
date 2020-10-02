//
//  PhotoHuntViewController.swift
//  PhotoHunt
//
//  Created by Ngay Vong on 10/2/20.
//

import UIKit

class PhotoHuntViewController: UIViewController {

    // MARK: - IBOutlets
    // MARK: - Private properties
    private var providerList: [Provider] = []
    
    private var accessDataQueue: DispatchQueue = DispatchQueue(label: "com.photohunt.accessDataQueue", attributes: .concurrent)
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadDefaultData()
        downloadData(withURL: providerList[0].url + "laptop")
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
    private func loadDefaultData() {
        let provider = Provider(name: "Splash", url: "http://www.splashbase.co/api/v1/images/search?query=", isEnable: true)
        providerList.append(provider)
    }
    
    private func downloadData(withURL urlStr: String) {
        guard let url = URL(string: urlStr) else {
            return
        }
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let item = try JSONDecoder().decode(SplashApiResponse.self, from: data)
                self.accessDataQueue.async(flags: .barrier) {
                    
                }
            } catch {
                print(error)
            }
        }
    }
}
