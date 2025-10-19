//
//  DataPersistenceManager.swift
//  Netflix-Clone
//
//  Created by xrt on 2025/10/19.
//

import Foundation
import CoreData
import UIKit
enum DataPersistenceError: Error {
    case failedToSaveData
    case failedToFetchData
    case failedToDeleteData
}
class DataPersistenceManager {
    static let shared = DataPersistenceManager()
    
    func downloadTitleWith(model: Title, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let titleItem = TitleItem(context: context)
        titleItem.title = model.title
        titleItem.origin_title = model.origin_title
        titleItem.origin_name = model.origin_name
        titleItem.overview = model.overview
        titleItem.media_type = model.media_type
        titleItem.poster_path = model.poster_path
        titleItem.id = Int64(model.id)
        titleItem.release_date = model.release_date
        titleItem.vote_count = Int64(model.vote_count)
        titleItem.vote_average = model.vote_average
        do {
            try context.save()
            completion(.success(()))
        } catch let error {
            completion(.failure(DataPersistenceError.failedToSaveData))
        }
    }
    func fetchingTitlesFromDatabase(completion: @escaping (Result<[TitleItem], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TitleItem> = TitleItem.fetchRequest()
        do {
            let titles = try context.fetch(fetchRequest)
            completion(.success(titles))
        } catch let error {
            completion(.failure(DataPersistenceError.failedToFetchData))
        }
    }

    func deleteTitleFromDatabase(titleItem: TitleItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        context.delete(titleItem)
        do {
            try context.save()
            completion(.success(()))
        } catch let error {
            completion(.failure(DataPersistenceError.failedToDeleteData))
        }
    }
}
