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
        fetchedResultsChange = BatchUpdate(collectionView: self.collectionView)
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        fetchedResultsChange?.addChange(change: .object(indexPath, newIndexPath, type))
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        fetchedResultsChange?.addChange(change: .section(sectionIndex, type))
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let existingFetchedResultsChange = self.fetchedResultsChange else {
            return
        }
        self.fetchedResultsQueue.addOperation(existingFetchedResultsChange)
        self.fetchedResultsChange = nil
    }
    
}
