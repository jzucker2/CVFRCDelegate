//
//  BatchUpdate.swift
//  Pods
//
//  Created by Jordan Zucker on 1/30/17.
//
//

import UIKit
import CoreData

internal class BatchUpdate: Operation {
    enum Change {
        case object(IndexPath?, IndexPath?, NSFetchedResultsChangeType)
        case section(Int, NSFetchedResultsChangeType)
        
        func change(for collectionView: UICollectionView?) -> Int {
            var changedCount = 0
            switch self {
            case let .object(indexPath, newIndexPath, changeType):
                switch changeType {
                case .insert:
                    print("insert")
                    changedCount += 1
                    collectionView?.insertItems(at: [newIndexPath!])
                case .update:
                    print("update")
                    collectionView?.reloadItems(at: [indexPath!])
                case .move:
                    print("move")
                    collectionView?.moveItem(at: indexPath!, to: newIndexPath!)
                case .delete:
                    print("delete")
                    changedCount -= 1
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
            print("changedCount: \(changedCount)")
            return changedCount
        }
    }
    
    private weak var delegate: CVFRCDelegate?
    private var changes = [Change]()
    private weak var collectionView: UICollectionView?
    
    init(collectionView: UICollectionView?, delegate: CVFRCDelegate) {
        self.collectionView = collectionView
        self.delegate = delegate
    }
    
    func addChange(change: Change) {
        changes.append(change)
    }
    
    var finalCountChange = 0
    
    override func main() {
        guard !self.isCancelled else { return }
        let batchUpdate = DispatchWorkItem(qos: .userInteractive, flags: []) {
            guard !self.isCancelled else { return }
            print("before batch updates")
            self.collectionView?.performBatchUpdates({
                print("begin performBatchUpdates")
                guard !self.isCancelled else { return }
                var changes = 0
                self.changes.forEach({ (change) in
                    print("a change")
                    guard !self.isCancelled else { return }
                    let changedCount = change.change(for: self.collectionView)
                    print("changedCount: \(changedCount)")
                    print("before self.finalCountChange: \(self.finalCountChange)")
                    self.finalCountChange += changedCount
                    changes += changedCount
                    print("after self.finalCountChange: \(self.finalCountChange)")
                })
                
                self.delegate?.updateCount(with: changes)
                print("end performBatchUpdates with final count: \(changes)")
            })
        }
        DispatchQueue.main.async(execute: batchUpdate)
        
//        print("main for batch update")
//        guard !self.isCancelled else { return }
//        self.collectionView?.performBatchUpdates({
//            print("begin performBatchUpdates")
//            guard !self.isCancelled else { return }
//            self.changes.forEach({ (change) in
//                print("a change")
//                guard !self.isCancelled else { return }
//                self.finalCountChange += change.change(for: self.collectionView)
//            })
//            print("end performBatchUpdates")
//        })
    }
    
}
