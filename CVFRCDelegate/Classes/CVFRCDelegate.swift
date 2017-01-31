//
//  CVFRCDelegate.swift
//  Pods
//
//  Created by Jordan Zucker on 1/30/17.
//
//

import UIKit
import CoreData

public class CVFRCDelegate: NSObject, NSFetchedResultsControllerDelegate {
    
    private weak var collectionView: UICollectionView?
    
    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    public func deinitActions() {
        fetchedResultsChange = nil
        fetchedResultsQueue.cancelAllOperations()
    }
    
    deinit {
        deinitActions()
    }
    
    private var fetchedResultsQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    } ()
    
    private var fetchedResultsChange: BatchUpdate?
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(#function)
        if let _ = fetchedResultsChange {
            print("Time to bail!!!!! Reload data")
            fetchedResultsQueue.cancelAllOperations()
            DispatchQueue.main.async { [weak self] in
                self?.collectionView?.reloadData()
            }
        } else {
            fetchedResultsChange = BatchUpdate(collectionView: self.collectionView)
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("\(#function) items")
        fetchedResultsChange?.addChange(change: .object(indexPath, newIndexPath, type))
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("\(#function) sections")
        fetchedResultsChange?.addChange(change: .section(sectionIndex, type))
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(#function)
        guard let existingFetchedResultsChange = self.fetchedResultsChange else {
            print("\(#function) bail")
            return
        }
        self.fetchedResultsQueue.addOperation(existingFetchedResultsChange)
        self.fetchedResultsChange = nil
    }
    
}
