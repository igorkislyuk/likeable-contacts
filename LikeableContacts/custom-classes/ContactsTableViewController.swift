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
    
    override func viewDidAppear(_ animated: Bool) {
        //self.clearContacts()
        retreiveFromStore()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.isEmpty ? 0 : contacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ContactCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ContactTableViewCell

        let contact = contacts[indexPath.row]
        
        cell.firstNameLabel.text = contact.birthName
        cell.secondNameLabel.text = contact.middleName
        cell.likeLabel.text = contact.likes == nil ? "No likes" : String(describing: contact.likes!)

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: -Contacts
    
    func fetchContacts() {
        AppDelegate.getAppDelegate().requestForAccess {
            (accessGranted) -> Void in
            if accessGranted {
                let keys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName)]
                do {
                    let predicate: NSPredicate = CNContact.predicateForContactsInContainer(withIdentifier: CNContactStore().defaultContainerIdentifier())
                    let contacts = try CNContactStore().unifiedContacts(matching: predicate, keysToFetch: keys)
                    
                    self.clearContacts()
                    
                    let context = AppDelegate.getAppDelegate().managedObjectContext
                    
                    for contact in contacts {
                        let likeableContact = NSEntityDescription.insertNewObject(forEntityName: "LikeableContact", into: context) as! LikeableContact
                        likeableContact.birthName = contact.givenName
                        likeableContact.middleName = contact.middleName
                        likeableContact.likes = 0
                        
                        do {
                            try context.save()
                        } catch {
                            print(error)
                        }
                        
                    }
                    
                                        
                    DispatchQueue.main.async(execute: { () -> Void in
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
            context.delete(lc)
        }
        
        do {
            try context.save()
        } catch {
            print("\(error)")
        }
    }
    
    func retreiveFromStore() {
        let context = AppDelegate.getAppDelegate().managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LikeableContact")
        do {
            contacts = try context.fetch(fetchRequest) as! [LikeableContact]
        } catch {
            print(error)
        }
    }
    
    func updateValueInStore(_ hashValue: Int, increment: Int) -> LikeableContact? {
        for contact in contacts {
            if contact.hashValue == hashValue && contact.likes != nil {
                contact.likes = NSNumber(value: contact.likes!.int32Value + increment as Int32)
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
    
    func getIndexPathBy(_ button: UIButton) -> IndexPath {
        let buttonPosition = button.convert(CGPoint.zero, to: self.tableView)
        return self.tableView.indexPathForRow(at: buttonPosition)!
    }
    
    func updateContactBy(_ button: UIButton, increment: Int) {
        let indexPath = getIndexPathBy(button)
        let cell = tableView.cellForRow(at: indexPath) as! ContactTableViewCell
        
        var hashString = ""
        if let firstName = cell.firstNameLabel.text {
            hashString.append(firstName)
        }
        if let secondName = cell.secondNameLabel.text {
            hashString.append(secondName)
        }
        //updateValue
        let updatedValue = updateValueInStore(hashString.hashValue, increment: increment)
        
        //reloadData
        let likes = Int((updatedValue?.likes)!)
        cell.likeLabel.text = String(likes)

    }
    
    func getCounterCoordinates(_ button: UIButton) -> CGRect{
        let cell = tableView.cellForRow(at: getIndexPathBy(button)) as! ContactTableViewCell
        return cell.likeLabel.frame
    }
    
    func makeAnAnimation(_ button: UIButton, color: UIColor) {
        let viewForAnimation =  UIView(frame: button.bounds)
        viewForAnimation.layer.cornerRadius = viewForAnimation.bounds.height / 2
        viewForAnimation.backgroundColor = color
        viewForAnimation.alpha = 0.5
        button.addSubview(viewForAnimation)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            var transform = viewForAnimation.transform
            let dx = self.getCounterCoordinates(button).midX - button.frame.midX
            transform = transform.translatedBy(x: dx, y: 0)
            transform = transform.scaledBy(x: 0.1, y: 0.1)
            viewForAnimation.transform = transform
            }, completion: {
                result -> Void in
                viewForAnimation.removeFromSuperview()
        })
        
    }
    
    //MARK: - Actions
    
    @IBAction func actionLikeButtonPressed(_ sender: UIButton) {
        updateContactBy(sender, increment: 1)
        
        //animation
        makeAnAnimation(sender, color: .red)
    }
    
    @IBAction func actionDislikeButtonPressed(_ sender: UIButton) {
        updateContactBy(sender, increment: -1)
        
        //animation
        makeAnAnimation(sender, color: .blue)
    }
    
    @IBAction func actionUpdateContacts() {
        fetchContacts()
    }
    


}
