//
//  ViewController.swift
//  CVFRCDelegate
//
//  Created by jzucker2 on 01/30/2017.
//  Copyright (c) 2017 jzucker2. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    var collectionView: UICollectionView!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Sample> = {
        let mediaForRecipeFetchRequest: NSFetchRequest<Sample> = Sample.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Sample.creationDate), ascending: true)
        mediaForRecipeFetchRequest.sortDescriptors = [creationDateSortDescriptor]
        //        let creatingFetchedResultsController = NSFetchedResultsController(fetchRequest: allRecipesFetchRequest, managedObjectContext: UIApplication.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        let creatingFetchedResultsController = NSFetchedResultsController(fetchRequest: mediaForRecipeFetchRequest, managedObjectContext: DataController.sharedController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        creatingFetchedResultsController.delegate = self
        return creatingFetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.register(SampleCollectionViewCell.self, forCellWithReuseIdentifier: SampleCollectionViewCell.reuseIdentifier())
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func configure(cell: UICollectionViewCell, indexPath: IndexPath) {
        guard let sampleCell = collectionView.dequeueReusableCell(withReuseIdentifier: SampleCollectionViewCell.reuseIdentifier(), for: indexPath) as? SampleCollectionViewCell else {
            fatalError("wrong cell! \(indexPath)")
        }
        let item = fetchedResultsController.object(at: indexPath)
        sampleCell.update(with: item)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SampleCollectionViewCell.reuseIdentifier(), for: indexPath) as? SampleCollectionViewCell else {
            fatalError("wrong cell! \(indexPath)")
        }
        let item = fetchedResultsController.object(at: indexPath)
        cell.update(with: item)
//        if indexPath == movingIndexPath {
//            cell.alpha = 0.7
//            cell.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//        } else {
//            cell.alpha = 1.0
//            cell.transform = CGAffineTransform.identity
//        }
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        
//        var view: UICollectionReusableView!
//        switch kind {
//        case UICollectionElementKindSectionHeader:
//            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MediaCollectionHeaderView.reuseIdentifier(), for: indexPath) as? MediaCollectionHeaderView else {
//                fatalError()
//            }
//            header.update(with: headerDisplayText, targetAction: (self, #selector(changeName)))
//            view = header
//        case UICollectionElementKindSectionFooter:
//            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MediaCollectionFooterView.reuseIdentifier(), for: indexPath) as? MediaCollectionFooterView else {
//                fatalError()
//            }
//            footer.update(with: addMediaTapGR)
//            #if DEBUG
//                footer.update(with: addMediaLongPressGR)
//            #endif
//            view = footer
//        default:
//            fatalError()
//        }
//        
//        return view
//    }
    
//    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        print("\(#function) sourceIndexPath: \(sourceIndexPath.debugDescription) destinationIndexPath: \(destinationIndexPath.debugDescription)")
//        updateRecipeRankings()
//        //        dataSource.moveItem(at: sourceIndexPath, to: destinationIndexPath)
//    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        return sections.count
    }

}

