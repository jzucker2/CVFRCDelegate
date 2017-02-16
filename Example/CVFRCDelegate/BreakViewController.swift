//
//  BreakViewController.swift
//  CVFRCDelegate
//
//  Created by Jordan Zucker on 1/31/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import CoreData
import CVFRCDelegate

class BreakViewController: UIViewController, UICollectionViewDataSource {

    var collectionView: UICollectionView!
    
    weak var createTestObjectTimer: Timer? {
        willSet {
            createTestObjectTimer?.invalidate()
        }
    }
    
    func concurrentCreate() {
        DispatchQueue.concurrentPerform(iterations: 5, execute: { (count) -> Void in
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.1, execute: {
                let title = "Item \(count)"
                Sample.saveObject(title: title)
            })
        })
    }
    
    func breakButtonTapped(sender: UIBarButtonItem) {
        
        DispatchQueue.concurrentPerform(iterations: 20, execute: { (count) -> Void in
            self.concurrentCreate()
        })
    }
    
    var fetchedResultsControllerDelegate: CVFRCDelegate!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Sample> = {
        let sampleFetchRequest: NSFetchRequest<Sample> = Sample.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Sample.creationDate), ascending: true)
        sampleFetchRequest.sortDescriptors = [creationDateSortDescriptor]
        let creatingFetchedResultsController = NSFetchedResultsController(fetchRequest: sampleFetchRequest, managedObjectContext: DataController.sharedController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsControllerDelegate = CVFRCDelegate(collectionView: self.collectionView)
        creatingFetchedResultsController.delegate = self.fetchedResultsControllerDelegate
        return creatingFetchedResultsController
    }()
    
    func createObjectTimerFired(timer: Timer) {
        let now = "\(Date())"
        Sample.saveObject(title: now)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .cyan
        collectionView.register(SampleCollectionViewCell.self, forCellWithReuseIdentifier: SampleCollectionViewCell.reuseIdentifier())
        collectionView.dataSource = self
        view.addSubview(collectionView)
        navigationItem.title = "Collection View FRC"
        
        let breakButton = UIBarButtonItem(title: "Break it!", style: .done, target: self, action: #selector(breakButtonTapped(sender:)))
        navigationItem.rightBarButtonItems = [breakButton]
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
        createTestObjectTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(createObjectTimerFired(timer:)), userInfo: nil, repeats: true)
        print("\(#function) end with \(fetchedResultsController.fetchedObjects?.count)")
        fetchedResultsControllerDelegate.itemCount = fetchedResultsController.fetchedObjects!.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func removeFiveSamplesButtonPressed(sender: UIBarButtonItem) {
        DataController.sharedController.persistentContainer.performBackgroundTask { (context) in
            defer {
                if context.hasChanges {
                    do {
                        try context.save()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            
            let deleteInContext: (NSManagedObjectID) -> () = { (objectID) in
                let actualSample = context.object(with: objectID)
                context.delete(actualSample)
            }
            
            guard let fetchedResults = self.fetchedResultsController.fetchedObjects else {
                return
            }
            
            guard fetchedResults.count >= 5 else {
                self.fetchedResultsController.fetchedObjects?.forEach({ (item) in
                    deleteInContext(item.objectID)
                })
                print("finish deleting everything")
                return
            }
            
            let samplesSlice = fetchedResults[0...5]
            samplesSlice.forEach({ (sample) in
                deleteInContext(sample.objectID)
            })
        }
    }
    
    func addSamplesButtonPressed(sender: UIBarButtonItem) {
        DataController.sharedController.persistentContainer.performBackgroundTask { (context) in
            for i in 1...5 {
                let createdSample = Sample(context: context)
                createdSample.name = "Sample \(i)"
            }
            do {
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfItems = fetchedResultsControllerDelegate.numberOfItemsIn(section: section)
        print("***********************************************")
        print("experiment: \(#function) section: \(section) numberOfItems: \(numberOfItems)")
        
        
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        print("\(#function) section: \(section) numberOfItems: \(sectionInfo.numberOfObjects)")
        print("***********************************************")
//        return sectionInfo.numberOfObjects
        
        return numberOfItems
    }
    
    func configure(cell: UICollectionViewCell, indexPath: IndexPath) {
        guard let sampleCell = collectionView.dequeueReusableCell(withReuseIdentifier: SampleCollectionViewCell.reuseIdentifier(), for: indexPath) as? SampleCollectionViewCell else {
            fatalError("wrong cell! \(indexPath)")
        }
        let item = fetchedResultsController.object(at: indexPath)
        sampleCell.update(with: item.name)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SampleCollectionViewCell.reuseIdentifier(), for: indexPath) as? SampleCollectionViewCell else {
            fatalError("wrong cell! \(indexPath)")
        }
        let item = fetchedResultsController.object(at: indexPath)
        
        DataController.sharedController.viewContext.performAndWait {
            let formattedDate = DisplayDateFormatter.sharedFormatter.format(date: item.creationDate)
            let updateText = "\(item.name!)\n Date: \(formattedDate!)"
            cell.update(with: updateText)
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        print("\(#function) sections: \(sections.count)")
        return sections.count
    }

}
