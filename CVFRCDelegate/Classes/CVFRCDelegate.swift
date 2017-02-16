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
    public var itemCount: Int {
        get {
            var gettingCount: Int = 0
            let getItem = DispatchWorkItem(qos: .userInteractive, flags: []) {
                print("before sync gettingCount")
                gettingCount = self._itemCount
            }
            fetchedResultsQueue.underlyingQueue?.sync(execute: getItem)
            print("got count: \(gettingCount)")
            return gettingCount
        }
        set {
            let setItem = DispatchWorkItem(qos: .userInteractive, flags: [.barrier]) {
                print("setted count: \(newValue)")
                self._itemCount = newValue
            }
            print("start set")
            fetchedResultsQueue.underlyingQueue?.async(execute: setItem)
            print("added set")
//            print("set to: \(newValue)")
//            _itemCount = newValue
        }
    }
    private var _itemCount = 0
    
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
//        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        queue.underlyingQueue = DispatchQueue(label: "Underlying", qos: .userInteractive, attributes: [.concurrent])
        return queue
    } ()
    
    private var fetchedResultsChange: BatchUpdate?
    
//    public var numberOfSections: Int {
//        guard let sections = fetchedResultsController?.sections else {
//            fatalError("No sections in fetchedResultsController")
//        }
//        print("\(#function) sections: \(sections.count)")
//        return sections.count
//    }
    
    public func numberOfItemsIn(section: Int) -> Int {
        return itemCount
    }
    
    public func updateCount(with change: Int) {
//        _itemCount += change
        
        let setItem = DispatchWorkItem(qos: .userInteractive, flags: [.barrier]) {
            print("updated with change: \(change)")
            self._itemCount += change
        }
        print("start set")
        fetchedResultsQueue.underlyingQueue?.sync(execute: setItem)
        print("added set")
    }
    
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
            fetchedResultsChange = BatchUpdate(collectionView: self.collectionView, delegate: self)
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
//        print("before setting completion: \(existingFetchedResultsChange.debugDescription)")
//        existingFetchedResultsChange.completionBlock = {
//            print("completion block")
//            print("existingFetchedResultsChange: \(existingFetchedResultsChange.debugDescription)")
//            print("finalCountChange: \(existingFetchedResultsChange.finalCountChange)")
//            self.updateCount(with: existingFetchedResultsChange.finalCountChange)
//        }
//        print("add operation to main queue")
//        OperationQueue.main.addOperations([existingFetchedResultsChange], waitUntilFinished: true)
        self.fetchedResultsQueue.addOperation(existingFetchedResultsChange)
        print("begin operation")
//        existingFetchedResultsChange.waitUntilFinished()
        print("wait until finished")
        self.fetchedResultsChange = nil
        
        
    }
    
}
