//
//  ContactController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/20/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Contacts

class ContactController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var searchBar: UISearchBar!
    private var contacts = [CNContact]()
    private var authStatus: CNAuthorizationStatus = .denied {
        didSet { // switch enabled search bar, depending contacts permission
            searchBar.isUserInteractionEnabled = authStatus == .authorized
            
            if authStatus == .authorized { // all search
                contacts = fetchContacts("")
                tableView.reloadData()
            }
        }
    }
    
    private let kCellID = "Cell"
    
    
    // =========================================================================
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle("TheLight Software", for: UIControlState())
        titleButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 25.0)
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(goHome))
        }
        
        checkAuthorization()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCellID)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // =========================================================================
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        contacts = fetchContacts(searchText)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath)
        let contact = contacts[indexPath.row]
        
        // get the full name
        let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "NO NAME"
        cell.textLabel?.text = fullName
        
        return cell
    }
    
    // MARK: - Button
    
    func goHome() {
        let storyboard:UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let initialViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "MasterViewController") as UIViewController
        self.present(initialViewController, animated: true)
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
    } */
    
    
    // =========================================================================
    // MARK: - IBAction
    
    @IBAction func tapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    
    // =========================================================================
    // MARK: - Helpers
    
    private func checkAuthorization() {
        // get current status
        let status = CNContactStore.authorizationStatus(for: .contacts)
        authStatus = status
        
        switch status {
        case .notDetermined: // case of first access
            CNContactStore().requestAccess(for: .contacts) { [unowned self] (granted, error) in
                if granted {
                    NSLog("Permission allowed")
                    self.authStatus = .authorized
                } else {
                    NSLog("Permission denied")
                    self.authStatus = .denied
                }
            }
        case .restricted, .denied:
            NSLog("Unauthorized")
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action: UIAlertAction) in
                let url = URL(string: UIApplicationOpenSettingsURLString)
                
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                //UIApplication.shared.openURL(url!)
                
            })
            showAlert(
                title: "Permission Denied",
                message: "You have not permission to access contacts. Please allow the access the Settings screen.",
                actions: [okAction, settingsAction])
        case .authorized:
            NSLog("Authorized")
        }
    }
    
    
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
    }
    
    private func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alert.addAction(action)
        }
        
        DispatchQueue.main.async(execute: { [unowned self] () in
            self.present(alert, animated: true, completion: nil)
            })
    }
}
