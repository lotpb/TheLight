//
//  ContactController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/20/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

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


class ContactController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak var noContactsLabel: UILabel!
    @IBOutlet weak private var searchBar: UISearchBar!
    
    // data
    var contacts = [CNContact]()
    var contactStore = CNContactStore()
    var contactEntry = [ContactEntry]()
    
    private var authStatus: CNAuthorizationStatus = .denied {
        didSet { // switch enabled search bar, depending contacts permission
            searchBar.isUserInteractionEnabled = authStatus == .authorized
            if authStatus == .authorized { // all search
                contacts = fetchContacts("")
                tableView.reloadData()
            }
        }
    }
    
    lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 32)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            button.setTitle("TheLight - Contacts", for: .normal)
        } else {
            button.setTitle("Contacts", for: .normal)
        }
        button.titleLabel?.font = Font.navlabel
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - SplitView Fix
        self.extendedLayoutIncludesOpaqueBars = true //fix - remove bottom bar
        
        setupTableView()
        self.navigationItem.titleView = self.titleButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = true
        noContactsLabel.isHidden = false
        noContactsLabel.text = "Retrieving contacts..."
        //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .primaryOverlay
            }
        }
        setMainNavItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestAccessToContacts { (success) in
            if success {
                self.retrieveContacts({ (success, contacts) in
                    self.tableView.isHidden = !success
                    self.noContactsLabel.isHidden = success
                    if success, contacts?.count > 0 {
                        self.contactEntry = contacts!
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
    
    func setupTableView() {
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.backgroundColor = Color.LGrayColor
        self.tableView!.estimatedRowHeight = 65
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
    }
    
    func requestAccessToContacts(_ completion: @escaping (_ success: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            self.authStatus = .authorized //added
            completion(true) // authorized previously
        case .denied, .notDetermined: // needs to ask for authorization
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (accessGranted, error) in
                completion(accessGranted)
            })
        default: // not authorized.
            completion(false)
        }
    }
    
    func retrieveContacts(_ completion: (_ success: Bool, _ contacts: [ContactEntry]?) -> Void) {
 
        do {
            let contactsFetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactOrganizationNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
 
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock: { (cnContact, error) in
                if let contact = ContactEntry(cnContact: cnContact) { self.contactEntry.append(contact) }
            })
            completion(true, contactEntry)
        } catch {
            completion(false, nil)
        }
    }
    
    func fetchContacts(_ name: String) -> [CNContact] {
        
        do {
            let request = CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)])
            if name.isEmpty { // all search
                request.predicate = nil
            } else {
                request.predicate = CNContact.predicateForContacts(matchingName: name)
            }
            
            try contactStore.enumerateContacts(with: request, usingBlock: { (contact, error) in
                self.contacts.append(contact)
            })
            
            return contacts
        } catch let error as NSError {
            NSLog("Fetch error \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    private func searchContact(_ name: String) {
        
        do {
            //let contacts = CNMutableContact()
            //contacts.givenName = "Peter"
            //contacts.familyName = "Balsamo"
            let predicate = CNContact.predicateForContacts(matchingName: name)
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey]
            let store = CNContactStore()
            
            let contacts = try store.unifiedContacts(
                matching: predicate,
                keysToFetch: keysToFetch as [CNKeyDescriptor]
            )
            
            if let firstContact = contacts.first {
                let viewController = CNContactViewController(for: firstContact)
                viewController.contactStore = store
                present(viewController, animated: true, completion: nil)
            }
            //return contacts
            
        } catch let error as NSError {
            NSLog("Fetch error \(error.localizedDescription)")
            return 
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dvc = segue.destination as? CreateContactViewController {
            dvc.type = .cnContact
        }
    }

}
//-----------------------end------------------------------
extension ContactController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        contacts = fetchContacts(searchText)
        //tableView.reloadData()
    }
}

extension ContactController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactEntry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        
        let entry = contactEntry[(indexPath as NSIndexPath).row]
        cell.configureWithContactEntry(entry)
        cell.layoutIfNeeded()
        
        return cell
    }
}

extension ContactController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //let indexPath = tableView.indexPathForSelectedRow!
        //let currentItem = tableView.cellForRow(at: indexPath)! as UITableViewCell
        self.performSegue(withIdentifier: "CreateContact", sender: self)
        
    }
}
