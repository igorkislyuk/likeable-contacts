//
//  ContactsTableViewController.swift
//  LikeableContacts
//
//  Created by Igor on 12/05/16.
//  Copyright © 2016 Igor Kislyuk. All rights reserved.
//

import UIKit
import Contacts
import CoreData

class ContactsTableViewController: UITableViewController {

    var contacts = [LikeableContact]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.clearContacts()
        retreiveFromStore()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.isEmpty ? 0 : contacts.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ContactCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ContactTableViewCell

        let contact = contacts[indexPath.row]
        
        cell.firstNameLabel.text = contact.birthName
        cell.secondNameLabel.text = contact.middleName
        cell.likeLabel.text = contact.likes == nil ? "No likes" : String(contact.likes!)

        return cell
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: -Contacts
    
    func fetchContacts() {
        AppDelegate.getAppDelegate().requestForAccess {
            (accessGranted) -> Void in
            if accessGranted {
                let keys = [CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName)]
                do {
                    let predicate: NSPredicate = CNContact.predicateForContactsInContainerWithIdentifier(CNContactStore().defaultContainerIdentifier())
                    let contacts = try CNContactStore().unifiedContactsMatchingPredicate(predicate, keysToFetch: keys)
                    
                    self.clearContacts()
                    
                    let context = AppDelegate.getAppDelegate().managedObjectContext
                    
                    for contact in contacts {
                        let likeableContact = NSEntityDescription.insertNewObjectForEntityForName("LikeableContact", inManagedObjectContext: context) as! LikeableContact
                        likeableContact.birthName = contact.givenName
                        likeableContact.middleName = contact.middleName
                        likeableContact.likes = 0
                        
                        do {
                            try context.save()
                        } catch {
                            print(error)
                        }
                        
                    }
                    
                                        
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.retreiveFromStore()
                        self.tableView.reloadData()
                    })
                    
                } catch {
                    print("Unable to fetch the contacts")
                }
                
            }
            
        }
    }
    
    func clearContacts() {
        let context = AppDelegate.getAppDelegate().managedObjectContext
        for lc in contacts {
            context.deleteObject(lc)
        }
        
        do {
            try context.save()
        } catch {
            print("\(error)")
        }
    }
    
    func retreiveFromStore() {
        let context = AppDelegate.getAppDelegate().managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "LikeableContact")
        do {
            contacts = try context.executeFetchRequest(fetchRequest) as! [LikeableContact]
        } catch {
            print(error)
        }
    }
    
    func updateValueInStore(hashValue: Int, increment: Int) -> LikeableContact? {
        for contact in contacts {
            if contact.hashValue == hashValue && contact.likes != nil {
                contact.likes = NSNumber(int: contact.likes!.intValue + increment)
                let context = AppDelegate.getAppDelegate().managedObjectContext
                do {
                    try context.save()
                } catch {
                    print(error)
                }
                return contact
            }
        }
        return nil
    }
    
    func getIndexPathBy(button: UIButton) -> NSIndexPath {
        let buttonPosition = button.convertPoint(CGPointZero, toView: self.tableView)
        return self.tableView.indexPathForRowAtPoint(buttonPosition)!
    }
    
    func updateContactBy(button: UIButton, increment: Int) {
        let indexPath = getIndexPathBy(button)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ContactTableViewCell
        
        var hashString = ""
        if let firstName = cell.firstNameLabel.text {
            hashString.appendContentsOf(firstName)
        }
        if let secondName = cell.secondNameLabel.text {
            hashString.appendContentsOf(secondName)
        }
        //updateValue
        let updatedValue = updateValueInStore(hashString.hashValue, increment: increment)
        
        //reloadData
        let likes = Int((updatedValue?.likes)!)
        cell.likeLabel.text = String(likes)

    }
    
    func getCounterCoordinates(button: UIButton) -> CGRect{
        let cell = tableView.cellForRowAtIndexPath(getIndexPathBy(button)) as! ContactTableViewCell
        return cell.likeLabel.frame
    }
    
    func makeAnAnimation(button: UIButton, color: UIColor) {
        let viewForAnimation =  UIView(frame: button.bounds)
        viewForAnimation.layer.cornerRadius = CGRectGetHeight(viewForAnimation.bounds) / 2
        viewForAnimation.backgroundColor = color
        viewForAnimation.alpha = 0.5
        button.addSubview(viewForAnimation)
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseIn, animations: {
            var transform = viewForAnimation.transform
            let dx = self.getCounterCoordinates(button).midX - button.frame.midX
            transform = CGAffineTransformTranslate(transform, dx, 0)
            transform = CGAffineTransformScale(transform, 0.1, 0.1)
            viewForAnimation.transform = transform
            }, completion: {
                result -> Void in
                viewForAnimation.removeFromSuperview()
        })
        
    }
    
    //MARK: - Actions
    
    @IBAction func actionLikeButtonPressed(sender: UIButton) {
        updateContactBy(sender, increment: 1)
        
        //animation
        makeAnAnimation(sender, color: .redColor())
    }
    
    @IBAction func actionDislikeButtonPressed(sender: UIButton) {
        updateContactBy(sender, increment: -1)
        
        //animation
        makeAnAnimation(sender, color: .blueColor())
    }
    
    @IBAction func actionUpdateContacts() {
        fetchContacts()
    }
    


}
