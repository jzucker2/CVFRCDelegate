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
    
    weak var collectionView: UICollectionView?
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func deinitActions() {
        fetchedResultsQueue.cancelAllOperations()
    }
    
    class BatchUpdate: Operation {
        enum Change {
            case object(IndexPath?, IndexPath?, NSFetchedResultsChangeType)
            case section(Int, NSFetchedResultsChangeType)
            
            func change(for collectionView: UICollectionView?) {
                switch self {
                case let .object(indexPath, newIndexPath, changeType):
                    switch changeType {
                    case .insert:
                        collectionView?.insertItems(at: [newIndexPath!])
                    case .update:
                        collectionView?.reloadItems(at: [indexPath!])
                    case .move:
                        collectionView?.moveItem(at: indexPath!, to: newIndexPath!)
                    case .delete:
                        collectionView?.deleteItems(at: [indexPath!])
                    }
                case let .section(sectionIndex, changeType):
                    switch changeType {
                    case .insert:
                        collectionView?.insertSections(IndexSet(integer: sectionIndex))
                    case .update:
                        collectionView?.reloadSections(IndexSet(integer: sectionIndex))
                    case .delete:
                        collectionView?.deleteSections(IndexSet(integer: sectionIndex))
                    case .move:
                        // Not something I'm worrying about right now.
                        break
                    }
                }
            }
        }
        
        private var changes = [Change]()
        weak var collectionView: UICollectionView?
        
        init(collectionView: UICollectionView?) {
            self.collectionView = collectionView
        }
        
        func addChange(change: Change) {
            changes.append(change)
        }
        
        override func main() {
            print("\(self.debugDescription) \(#function)")
            guard !self.isCancelled else { return }
            let batchUpdate = DispatchWorkItem(qos: .userInteractive, flags: []) {
                guard !self.isCancelled else { return }
                self.collectionView?.performBatchUpdates({
                    guard !self.isCancelled else { return }
                    self.changes.forEach({ (change) in
                        guard !self.isCancelled else { return }
                        change.change(for: self.collectionView)
                    })
                })
            }
            DispatchQueue.main.async(execute: batchUpdate)
        }
        
    }
    
    var fetchedResultsQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    } ()
    
    var fetchedResultsChange: BatchUpdate?
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(#function)
        fetchedResultsChange = BatchUpdate(collectionView: self.collectionView)
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print(#function)
        fetchedResultsChange?.addChange(change: .object(indexPath, newIndexPath, type))
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print(#function)
        fetchedResultsChange?.addChange(change: .section(sectionIndex, type))
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(#function)
        guard let existingFetchedResultsChange = self.fetchedResultsChange else {
            return
        }
        self.fetchedResultsQueue.addOperation(existingFetchedResultsChange)
        self.fetchedResultsChange = nil
    }
    
}
