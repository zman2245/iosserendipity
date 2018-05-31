//
//  HotspotListController.swift
//  Serendipity
//
//  Created by Zachary Foster on 5/30/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//

import UIKit
import CoreData

class HotspotListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var hotspotTable: UITableView!
    
    // for help passing data into HotspotDetailsController
    var selectedHotspot: Hotspot?
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Hotspot.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hotspotTable.delegate = self
        self.hotspotTable.dataSource = self
        
        let service = DataService()
        service.fetchAllHotspots()
        
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedhResultController.sections?[0].numberOfObjects))")
        } catch let error  {
            print("ERROR: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is HotspotDetailsController {
            let vc = segue.destination as? HotspotDetailsController
            vc?.hotspot = self.selectedHotspot
        }
    }
    
    // MARK: - UITableView delegate and dataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HotspotCell", for: indexPath) as! HotspotCell
        if let hotspot = fetchedhResultController.object(at: indexPath) as? Hotspot {
            cell.textLabel?.text = String(format: "latitude: %f", hotspot.latitude)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = self.fetchedhResultController.object(at: indexPath)
        
        self.selectedHotspot = (object as! Hotspot)
        self.performSegue(withIdentifier: "ShowHotspotDetails", sender: self)
    }
}

extension HotspotListController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.hotspotTable.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.hotspotTable.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.hotspotTable.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        hotspotTable.beginUpdates()
    }
}

