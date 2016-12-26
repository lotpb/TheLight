//
//  ContactController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/20/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Contacts
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class ContactController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // data
    var contactStore = CNContactStore()
    private var contacts = [ContactEntry]()
    //private var contacts = [CNContact]()
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak var noContactsLabel: UILabel!
    @IBOutlet weak private var searchBar: UISearchBar!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            titleButton.setTitle("TheLight - Contacts", for: UIControlState())
        } else {
            titleButton.setTitle("Contacts", for: UIControlState())
        }
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = Color.LGrayColor
        self.tableView!.estimatedRowHeight = 65
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        
        //checkAuthorization()
        
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = true
        noContactsLabel.isHidden = false
        noContactsLabel.text = "Retrieving contacts..."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestAccessToContacts { (success) in
            if success {
                self.retrieveContacts({ (success, contacts) in
                    self.tableView.isHidden = !success
                    self.noContactsLabel.isHidden = success
                    if success && contacts?.count > 0 {
                        self.contacts = contacts!
                        self.tableView.reloadData()
                    } else {
                        self.noContactsLabel.text = "Unable to get contacts..."
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func requestAccessToContacts(_ completion: @escaping (_ success: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized: completion(true) // authorized previously
        case .denied, .notDetermined: // needs to ask for authorization
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (accessGranted, error) -> Void in
                completion(accessGranted)
            })
        default: // not authorized.
            completion(false)
        }
    }
    
    func retrieveContacts(_ completion: (_ success: Bool, _ contacts: [ContactEntry]?) -> Void) {
        var contacts = [ContactEntry]()
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactOrganizationNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                if let contact = ContactEntry(cnContact: cnContact) { contacts.append(contact) }
            })
            completion(true, contacts)
        } catch {
            completion(false, nil)
        }
    }
    /*
    private func fetchContacts(_ name: String) -> [CNContact] {
        
        let contactStore = CNContactStore()
        
        do {
            let request = CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)])
            
            if name.isEmpty { // all search
                request.predicate = nil
            } else {
                request.predicate = CNContact.predicateForContacts(matchingName: name)
            }
            
            var contacts = [CNContact]()
            try contactStore.enumerateContacts(with: request, usingBlock: { (contact, error) in
                contacts.append(contact)
            })
            
            return contacts
        } catch let error as NSError {
            NSLog("Fetch error \(error.localizedDescription)")
            return []
        }
    } */
    
    // =========================================================================
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //contacts = fetchContacts(searchText)
        tableView.reloadData()
    }
    
    // =========================================================================
    //MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        
        let entry = contacts[(indexPath as NSIndexPath).row]
        cell.configureWithContactEntry(entry)
        cell.layoutIfNeeded()

         /*
         // get the full name
         let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "NO NAME"
         cell.textLabel?.text = fullName */
        
        return cell
    }
    
    // MARK: - Segues
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "CreateContact", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "CreateContact" {
            let controller = (segue.destination as! UINavigationController).topViewController as! CreateContactViewController
            controller.type = .cnContact
            /*
            if let controller = segue.destination as? CreateContactViewController {
                controller.type = .cnContact
            } */
        }
    }
    
    // =========================================================================
    //MARK: - UITableViewDelegate
    /*
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteActionHandler = { (action: UITableViewRowAction, index: IndexPath) in
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { [unowned self] (action: UIAlertAction) in
                // set the data to be deleted
                let request = CNSaveRequest()
                let contact = self.contacts[(index as NSIndexPath).row].mutableCopy() as! CNMutableContact
                request.delete(contact)
                
                do {
                    // save
                    let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "NO NAME"
                    let store = CNContactStore()
                    try store.execute(request)
                    NSLog("\(fullName) Deleted")
                    
                    // update table
                    self.contacts.remove(at: (index as NSIndexPath).row)
                    DispatchQueue.main.async(execute: {
                        self.tableView.deleteRows(at: [index], with: .fade)
                    })
                } catch let error as NSError {
                    NSLog("Delete error \(error.localizedDescription)")
                }
                })
            
            let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.default, handler: { [unowned self] (action: UIAlertAction) in
                self.tableView.isEditing = false
                })
            
            // show alert
            self.showAlert(title: "Delete Contact", message: "OK？", actions: [okAction, cancelAction])
        }
        
        return [UITableViewRowAction(style: UITableViewRowActionStyle(), title: "Delete", handler: deleteActionHandler)]
    }
    
    
    // MARK: - IBAction
    
    @IBAction func tapped(_ sender: AnyObject) {
        view.endEditing(true)
    } */
    
    
    /*
    // fetch the contact of matching names
    private func fetchContacts(_ name: String) -> [CNContact] {
        
        let store = CNContactStore()
        
        do {
            let request = CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)])

            if name.isEmpty { // all search
                request.predicate = nil
            } else {
                request.predicate = CNContact.predicateForContacts(matchingName: name)
            }
            
            var contacts = [CNContact]()
            try store.enumerateContacts(with: request, usingBlock: { (contact, error) in
                contacts.append(contact)
            })
            
            return contacts
        } catch let error as NSError {
            NSLog("Fetch error \(error.localizedDescription)")
            return []
        }
    } */
    

} 
