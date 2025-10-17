//
//  SearchViewController.swift
//  Netflix-Clone
//
//  Created by xrt on 2025/10/9.
//

import UIKit

class SearchViewController: UIViewController {

    private var titles: [Title] = [Title]()
    private let discoverTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "搜索"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "搜索"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.addSubview(discoverTable)
        discoverTable.delegate = self
        discoverTable.dataSource = self
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white
        fetchDiscoverMovies()
        searchController.searchResultsUpdater = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTable.frame = view.bounds
    }
    
    func fetchDiscoverMovies() {
        APICaller.shared.getDiscoverMovies { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.discoverTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

   

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
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
        return 140
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
extension SearchViewController: UISearchResultsUpdating, SearchResultsViewControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        guard let searchResultsController = searchController.searchResultsController as? SearchResultsViewController else {
            return
        }
        searchResultsController.delegate = self
        APICaller.shared.search(with: query) { result in
            switch result {
            case .success(let titles):
                DispatchQueue.main.async {
                    searchResultsController.titles = titles
                    searchResultsController.searchResultCollectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }

    }
    
    func searchResultsViewControllerDidTapItem(title: TitlePreviewViewModel) {
        DispatchQueue.main.async {[weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: title)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}