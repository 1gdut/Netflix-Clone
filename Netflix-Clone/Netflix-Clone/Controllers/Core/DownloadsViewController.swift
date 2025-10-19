//
//  DownloadsViewController.swift
//  Netflix-Clone
//
//  Created by xrt on 2025/10/9.
//

import UIKit

class DownloadsViewController: UIViewController {
    private var titles: [TitleItem] = [TitleItem]() 

     private let downloadTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "下载"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.addSubview(downloadTable)
        downloadTable.delegate = self
        downloadTable.dataSource = self
        fetchDownloadedTitles()
        NotificationCenter.default.addObserver(forName: NSNotification.Name("downloadedTitlesUpdated"), object: nil, queue: nil) { _ in
          self.fetchDownloadedTitles()
        }
    }
    @objc func fetchDownloadedTitles() { 
        DataPersistenceManager.shared.fetchingTitlesFromDatabase { result in
            switch result {
            case .success(let titles):
                DispatchQueue.main.async { [weak self] in
                    self?.titles = titles
                    self?.downloadTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadTable.frame = view.bounds
    }

    

}
extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        let model = TitleViewModel(titleName: titles[indexPath.row].title ?? "无名称", posterURL: titles[indexPath.row].poster_path ?? "")
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataPersistenceManager.shared.deleteTitleFromDatabase(titleItem: titles[indexPath.row]) { result in
                switch result {
                case .success(()):
                    DispatchQueue.main.async { [weak self] in
                        self?.titles.remove(at: indexPath.row)
                        self?.downloadTable.deleteRows(at: [indexPath], with: .fade)
                    }
                    NotificationCenter.default.post(name: NSNotification.Name("downloadedTitlesUpdated"), object: nil)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = titles[indexPath.row]
        guard let titleName = title.title else {
            return
        }
        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                DispatchQueue.main.async {
                    let vc = TitlePreviewViewController()
                    vc.configure(with: TitlePreviewViewModel(title: titleName, youTubeView: videoElement, overview: title.overview ?? "无描述"))
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}
