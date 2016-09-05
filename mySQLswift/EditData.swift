//
//  EditController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/4/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse

class EditData: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView?
    
    @IBOutlet weak var first: UITextField!
    @IBOutlet weak var last: UITextField!
    @IBOutlet weak var company: UITextField!
    @IBOutlet weak var profileImageView: UIImageView?
    
    var activeImage: UIImageView?
    
    var datePickerView : UIDatePicker = UIDatePicker()
    var pickerView : UIPickerView = UIPickerView()
    private var pickOption = ["Call", "Follow", "Looks Good", "Future", "Bought", "Dead", "Cancel", "Sold"]
    private var pickRate = ["A", "B", "C", "D", "F"]
    private var pickContract = ["A & S Home Improvement", "Islandwide Gutters", "Ashland Home Improvement", "John Kat Windows", "Jose Rosa", "Peter Balsamo"]
    
    var date : UITextField!
    var address : UITextField!
    var city : UITextField!
    var state : UITextField!
    var zip : UITextField!
    var aptDate : UITextField!
    var phone : UITextField!
    var salesman : UITextField!
    var jobName : UITextField!
    var adName : UITextField!
    var amount : UITextField!
    var email : UITextField!
    var spouse : UITextField!
    var callback : UITextField!
    var start : UITextField! //cust
    var complete : UITextField! //cust
    var comment : UITextView!
    
    var formController : String?
    var status : String?
    var objectId : String?
    var custNo : String?
    var leadNo : String?
    var time : String?

    var rate : String? //cust
    var saleNo : String?
    var jobNo : String?
    var adNo : String?
    
    var photo : String?
    var photo1 : String?
    var photo2 : String?
    
    var frm11 : String?
    var frm12 : String?
    var frm13 : String?
    var frm14 : String?
    var frm15 : String?
    var frm16 : String?
    var frm17 : String?
    var frm18 : String?
    var frm19 : String?
    var frm20 : String?
    var frm21 : String?
    var frm22 : String?
    var frm23 : String?
    var frm24 : String?
    var frm25 : String?
    var frm26 : String?
    var frm27 : String?
    var frm28 : String?
    var frm29 : String?
    var frm30 : NSString?
    var frm31 : String? //start
    var frm32 : String? //completion
    
    var defaults = UserDefaults.standard
    var simpleStepper : UIStepper!
    var lookupItem : String?
    var pasteBoard = UIPasteboard.general
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearFormData()
        
        let titleButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        titleButton.setTitle(String(format: "%@ %@", self.status!, self.formController!), for: UIControlState())
        titleButton.titleLabel?.font = Font.navlabel
        titleButton.titleLabel?.textAlignment = NSTextAlignment.center
        titleButton.setTitleColor(.white, for: UIControlState())
        self.navigationItem.titleView = titleButton
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.estimatedRowHeight = 44
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.backgroundColor = .white
        self.tableView!.tableFooterView = UIView(frame: .zero)
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: (#selector(EditData.updatePicker)), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil)
        //self.pickerView.backgroundColor = .whiteColor()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(EditData.updateData))
        let buttons:NSArray = [saveButton]
        self.navigationItem.rightBarButtonItems = buttons as? [UIBarButtonItem]
        
        if (status == "New") {
            self.frm30 = "1"
        }
        
        if (status == "Edit") {
            parseLookup()
        }
        profileImageView?.image = UIImage(named:"profile-rabbit-toy")
        profileImageView?.layer.cornerRadius = (profileImageView?.frame.size.width)!/2
        profileImageView?.layer.borderColor = UIColor.lightGray.cgColor
        profileImageView?.layer.borderWidth = 0.5
        profileImageView?.layer.masksToBounds = true
        profileImageView?.isUserInteractionEnabled = true
        profileImageView?.contentMode = .scaleAspectFill
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        passFieldData()
        loadFormData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = Color.DGrayColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         NotificationCenter.default.removeObserver(self)
        //navigationController?.hidesBarsOnSwipe = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.formController == "Customer") {
            return 17
        } else {
            return 15
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath as NSIndexPath).row == 14 {
            return 100
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
    
        let textframe: UITextField?
        let textviewframe: UITextView?
        let aptframe: UITextField?
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: (Date()) as Date)
        
        aptframe = UITextField(frame:CGRect(x: 220, y: 7, width: 80, height: 30))
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            textframe = UITextField(frame:CGRect(x: 118, y: 7, width: 250, height: 30))
            textviewframe = UITextView(frame:CGRect(x: 118, y: 7, width: 250, height: 85))
            activeImage = UIImageView(frame:CGRect(x: 118, y: 10, width: 18, height: 22))
            textframe!.font = Font.Edittitle
            aptframe!.font = Font.Edittitle
            textviewframe!.font = Font.Edittitle

        } else {
            
            textframe = UITextField(frame:CGRect(x: 118, y: 7, width: 205, height: 30))
            textviewframe = UITextView(frame:CGRect(x: 118, y: 7, width: 240, height: 85))
            activeImage = UIImageView(frame:CGRect(x: 118, y: 10, width: 18, height: 22))
            textframe!.font = Font.Edittitle
            aptframe!.font = Font.Edittitle
            textviewframe!.font = Font.Edittitle
        }
        
        textframe!.autocorrectionType = UITextAutocorrectionType.no
        textframe!.clearButtonMode = .whileEditing
        textframe!.autocapitalizationType = UITextAutocapitalizationType.words
        textframe!.textColor = .black
        
        self.comment?.autocorrectionType = UITextAutocorrectionType.default
        self.callback?.clearButtonMode = .never
        self.zip?.keyboardType = UIKeyboardType.decimalPad
        
        if (formController == "Leads" || formController == "Customer") {
            self.amount?.keyboardType = UIKeyboardType.decimalPad
        }
        if (formController == "Customer") {
            self.callback?.keyboardType = UIKeyboardType.decimalPad
        }
        if (formController == "Vendor") {
            self.last?.keyboardType = UIKeyboardType.URL
            self.salesman?.keyboardType = UIKeyboardType.numbersAndPunctuation
            self.jobName?.keyboardType = UIKeyboardType.numbersAndPunctuation
            self.adName?.keyboardType = UIKeyboardType.numbersAndPunctuation
        }
        if (formController == "Employee") {
            self.salesman?.keyboardType = UIKeyboardType.numbersAndPunctuation
            self.jobName?.keyboardType = UIKeyboardType.numbersAndPunctuation
            self.adName?.keyboardType = UIKeyboardType.numbersAndPunctuation
        }
        self.email?.keyboardType = UIKeyboardType.emailAddress
        self.phone?.keyboardType = UIKeyboardType.numbersAndPunctuation
        
        self.email?.returnKeyType = UIReturnKeyType.next
        
        if ((indexPath as NSIndexPath).row == 0) {
            
            let theSwitch = UISwitch(frame:CGRect.zero)
            self.activeImage?.contentMode = .scaleAspectFill
            
            if self.frm30 == "1" {
                theSwitch.isOn = true
                self.activeImage!.image = UIImage(named:"iosStar.png")
                cell.textLabel!.text = "Active"
            } else {
                theSwitch.isOn = false
                self.activeImage!.image = UIImage(named:"iosStarNA.png")
                cell.textLabel!.text = "Inactive"
            }
            theSwitch.onTintColor = UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha: 1.0)
            theSwitch.tintColor = .lightGray
            theSwitch.addTarget(self, action: #selector(EditData.changeSwitch), for: .valueChanged)

            cell.addSubview(theSwitch)
            cell.accessoryView = theSwitch
            cell.contentView.addSubview(activeImage!)
            
        } else if ((indexPath as NSIndexPath).row == 1) {
            
            self.date = textframe
            self.date!.tag = 0
            
            if self.frm18 == nil {
                self.date!.text = ""
            } else {
                self.date!.text = self.frm18
            }
            
            if (self.formController == "Leads" || self.formController == "Customer") {
                if (self.status == "New") {
                    self.date?.text = dateString
                }
                self.date?.inputView = datePickerView
                datePickerView.datePickerMode = UIDatePickerMode.date
                datePickerView.addTarget(self, action: #selector(EditData.handleDatePicker), for: UIControlEvents.valueChanged)
            }
            
            if (self.formController == "Vendor") {
                self.date?.placeholder = "Profession"
                cell.textLabel!.text = "Profession"
                
            } else if (self.formController == "Employee") {
                self.date!.placeholder = "Title"
                cell.textLabel!.text = "Title"
                
            } else {
                self.date?.placeholder = "Date"
                cell.textLabel!.text = "Date"
            }
            
            cell.contentView.addSubview(self.date!)
            
        } else if ((indexPath as NSIndexPath).row == 2) {
            
            self.address = textframe
            if self.frm14 == nil {
                self.address!.text = ""
            } else {
                self.address!.text = self.frm14
            }
            self.address!.placeholder = "Address"
            cell.textLabel!.text = "Address"
            cell.contentView.addSubview(self.address!)
            
        } else if ((indexPath as NSIndexPath).row == 3) {
            
            self.city = textframe
            if self.frm15 == nil {
                self.city!.text = ""
            } else {
                self.city!.text = self.frm15
            }
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            self.city!.placeholder = "City"
            cell.textLabel!.text = "City"
            cell.contentView.addSubview(self.city!)
            
        } else if ((indexPath as NSIndexPath).row == 4) {
            
            self.state = textframe
            if self.frm16 == nil {
                self.state!.text = ""
            } else {
                self.state!.text = self.frm16
            }
            self.state!.placeholder = "State"
            cell.textLabel!.text = "State"
            cell.contentView.addSubview(self.state!)
            
            self.zip = aptframe
            self.zip!.placeholder = "Zip"
                if self.frm17 == nil {
                    self.zip!.text = ""
                } else {
                    self.zip!.text = self.frm17
                }
            
            cell.contentView.addSubview(self.zip!)
            
        } else if ((indexPath as NSIndexPath).row == 5) {
            
            self.aptDate = textframe
            if self.frm19 == nil {
                self.aptDate!.text = ""
            } else {
                self.aptDate!.text = self.frm19
            }
            if (self.formController == "Customer") {
                self.aptDate!.placeholder = "Rate"
                cell.textLabel!.text = "Rate"
                self.aptDate?.inputView = self.pickerView
                
            } else if (self.formController == "Vendor") {
                self.aptDate!.placeholder = "Assistant"
                cell.textLabel!.text = "Assistant"
                
            } else if (self.formController == "Employee") {
                self.aptDate!.placeholder = "Middle"
                cell.textLabel!.text = "Middle"
                
            } else { //leads
                if (self.status == "New") {
                    self.aptDate?.text = dateString
                }
                self.aptDate!.tag = 4
                self.aptDate!.placeholder = "Apt Date"
                cell.textLabel!.text = "Apt Date"
                self.aptDate!.inputView = datePickerView
                datePickerView.datePickerMode = UIDatePickerMode.date
                datePickerView.addTarget(self, action: #selector(EditData.handleDatePicker), for: UIControlEvents.valueChanged)
            }
            
            cell.contentView.addSubview(self.aptDate!)
            
        } else if ((indexPath as NSIndexPath).row == 6) {
            
            self.phone = textframe
            self.phone!.placeholder = "Phone"
            if (self.frm20 == nil) {
                self.phone!.text = defaults.string(forKey: "areacodeKey")
            } else {
                self.phone!.text = self.frm20
            }
            cell.textLabel!.text = "Phone"
            cell.contentView.addSubview(self.phone!)
            
        } else if ((indexPath as NSIndexPath).row == 7) {
            
            self.salesman = textframe
            self.salesman!.adjustsFontSizeToFitWidth = true
            
            if self.frm21 == nil {
                self.salesman!.text = ""
            } else {
                self.salesman!.text = self.frm21
            }
 
            if (self.formController == "Vendor") {
                self.salesman!.placeholder = "Phone 1"
                cell.textLabel!.text = "Phone 1"
                
            } else if (self.formController == "Employee") {
                self.salesman!.placeholder = "Work Phone"
                cell.textLabel!.text = "Work Phone"
                
            } else {
                self.salesman!.placeholder = "Salesman"
                cell.textLabel!.text = "Salesman"
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            
            cell.contentView.addSubview(self.salesman!)
            
        } else if ((indexPath as NSIndexPath).row == 8) {
            
            self.jobName = textframe
            if self.frm22 == nil {
                self.jobName!.text = ""
            } else {
                self.jobName!.text = self.frm22
            }
            
            if (self.formController == "Vendor") {
                self.jobName!.placeholder = "Phone 2"
                cell.textLabel!.text = "Phone 2"
                
            } else if (self.formController == "Employee") {
                self.jobName!.placeholder = "Cell Phone"
                cell.textLabel!.text = "Cell Phone"
            } else {
                self.jobName!.placeholder = "Job"
                cell.textLabel!.text = "Job"
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            
            cell.contentView.addSubview(self.jobName!)
            
        } else if ((indexPath as NSIndexPath).row == 9) {
            self.adName = textframe
            self.adName!.placeholder = "Advertiser"
            if self.frm23 == nil {
                self.adName!.text = ""
            } else {
                self.adName!.text = self.frm23
            }
            
            if ((self.formController == "Leads") || (self.formController == "Customer")) {
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            }
            if (self.formController == "Vendor") {
                self.adName!.placeholder = "Phone 3"
                cell.textLabel!.text = "phone 3"
                
            } else if (self.formController == "Employee") {
                self.adName!.placeholder = "Social Security"
                cell.textLabel!.text = "Social Sec"
                
            } else if (self.formController == "Customer") {
                self.adName!.placeholder = "Product"
                cell.textLabel!.text = "Product"
                
            } else {
                cell.textLabel!.text = "Advertiser"
            }
            
            cell.contentView.addSubview(self.adName!)
            
        } else if((indexPath as NSIndexPath).row == 10) {
            
            self.amount = textframe
            
            if ((self.formController == "Leads") || (self.formController == "Customer")) {
                if (self.status == "New") {
                    let simpleStepper = UIStepper(frame:CGRect.zero)
                    simpleStepper.tag = 10
                    simpleStepper.value = 0 //Double(self.amount.text!)!
                    simpleStepper.minimumValue = 0
                    simpleStepper.maximumValue = 10000
                    simpleStepper.stepValue = 100
                    simpleStepper.tintColor = .gray
                    cell.accessoryView = simpleStepper
                    simpleStepper.addTarget(self, action: #selector(EditData.stepperValueDidChange), for: UIControlEvents.valueChanged)
                }
            }
            
            self.amount!.placeholder = "Amount"
                if self.frm24 == nil {
                    self.amount!.text = ""
                } else {
                    self.amount!.text = self.frm24
                }
            cell.textLabel!.text = "Amount"
            
            if ((self.formController == "Vendor") || (self.formController == "Employee")) {
                self.amount!.placeholder = "Department"
                cell.textLabel!.text = "Department"
            }
            
            cell.contentView.addSubview(self.amount!)
            
        } else if ((indexPath as NSIndexPath).row == 11) {
            
            self.email = textframe
            self.email!.placeholder = "Email"
            if self.frm25 == nil {
                self.email!.text = ""
            } else {
                let myString = self.frm25
                self.email!.text = myString!.removeWhiteSpace() //extension
            }
            cell.textLabel!.text = "Email"
            cell.contentView.addSubview(self.email!)
            
        } else if((indexPath as NSIndexPath).row == 12) {
            self.spouse = textframe
            self.spouse!.placeholder = "Spouse"
            
            if self.frm26 == nil {
                self.spouse!.text = ""
            } else {
                self.spouse!.text = self.frm26
            }
            
            if (formController == "Vendor") {
                self.spouse!.placeholder = "Office"
                cell.textLabel!.text = "Office"
            } else if (formController == "Employee") {
                self.spouse!.placeholder = "Country"
                cell.textLabel!.text = "Country"
            } else {
                cell.textLabel!.text = "Spouse"
            }
            
            cell.contentView.addSubview(self.spouse!)
            
        } else if ((indexPath as NSIndexPath).row == 13) {
            self.callback = textframe

                if self.frm27 == nil {
                    self.callback!.text = ""
                } else {
                    self.callback!.text = self.frm27
                }
            
            if (self.formController == "Customer") {
                self.callback!.placeholder = "Quan"
                cell.textLabel!.text = "# Windows"
             
                let simpleStepper = UIStepper(frame:CGRect.zero)
                simpleStepper.tag = 13
                if (self.status == "Edit") {
                    simpleStepper.value = Double(self.callback.text!)!
                } else {
                    simpleStepper.value = 0
                }
                
                simpleStepper.stepValue = 1
                simpleStepper.tintColor = .gray
                cell.accessoryView = simpleStepper
                simpleStepper.addTarget(self, action: #selector(EditData.stepperValueDidChange), for: UIControlEvents.valueChanged)
            }
            else if (self.formController == "Vendor") {
                self.callback!.isHidden = true //Field
                self.callback!.placeholder = ""
                cell.textLabel!.text = ""
            }
            else if (self.formController == "Employee") {
                self.callback!.placeholder = "Manager"
                cell.textLabel!.text = "Manager"
            }
            else {
                self.callback!.placeholder = "Call Back"
                cell.textLabel!.text = "Call Back"
                self.callback?.inputView = self.pickerView
            }
            
            cell.contentView.addSubview(self.callback!)
            
        } else if ((indexPath as NSIndexPath).row == 14) {
            self.comment = textviewframe
            if self.frm28 == nil {
                self.comment!.text = ""
            } else {
                self.comment!.text = self.frm28
            }
            cell.textLabel!.text = "Comments"
            cell.contentView.addSubview(self.comment!)
            
        } else if((indexPath as NSIndexPath).row == 15) {
            self.start = textframe
            //self.start!.tag = 15
            self.start!.placeholder = "Start Date"
            if self.frm31 == nil {
                self.start!.text = ""
            } else {
                self.start!.text = self.frm31
            }
            self.start!.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(EditData.handleDatePicker), for: UIControlEvents.valueChanged)
            cell.textLabel!.text = "Start Date"
            cell.contentView.addSubview(self.start!)
            
        } else if((indexPath as NSIndexPath).row == 16) {
            self.complete = textframe
            //self.complete!.tag = 16
            self.complete!.placeholder = "Completion Date"
            
            if self.frm32 == nil {
            self.complete!.text = ""
            } else {
            self.complete!.text = self.frm32
            }
            self.complete!.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(EditData.handleDatePicker), for: UIControlEvents.valueChanged)
            cell.textLabel!.text = "End Date"
            cell.contentView.addSubview(self.complete!)
            }
        
        return cell
    }
    
    // MARK: - Table Header/Footer
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    
    // MARK: - Content Menu
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) -> Bool {
        
        if (action == #selector(NSObject.copy)) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
        
        let cell = tableView.cellForRow(at: indexPath)
        pasteBoard.string = cell!.textLabel?.text
    }
    
    
    // MARK: - Switch
    
    func changeSwitch(_ sender: UISwitch) {
        
        if (sender.isOn) {
            self.frm30 = "1"
        } else {
            self.frm30 = "0"
        }
        self.tableView!.reloadData()
    }
    
    
    // MARK: - StepperValueChanged
    
    func stepperValueDidChange(_ sender: UIStepper) {
        
        if (sender.tag == 13) {
            self.callback?.text = "\(Int(sender.value))"
        } else if (sender.tag == 10) {
            self.amount?.text = "\(Int(sender.value))"
        }
    }
    
    
    // MARK: - TextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - PickView
    
    func updatePicker(){
        self.pickerView.reloadAllComponents()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if callback.isFirstResponder {
            return pickOption.count
        } else if aptDate.isFirstResponder {
            return pickRate.count
        } else if company.isFirstResponder {
            return pickContract.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if callback.isFirstResponder {
            return "\(pickOption[row])"
        } else if aptDate.isFirstResponder {
            return "\(pickRate[row])"
        } else if company.isFirstResponder {
            return "\(pickContract[row])"
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if callback.isFirstResponder {
            self.callback.text = pickOption[row]
        } else if aptDate.isFirstResponder {
            self.aptDate.text = pickRate[row]
        } else if company.isFirstResponder {
            self.company.text = pickContract[row]
        }
    }
    
    
    // MARK: - Datepicker
    
    func handleDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if date.isFirstResponder {
            self.date?.text = dateFormatter.string(from: sender.date)
        } else if aptDate.isFirstResponder {
            self.aptDate?.text = dateFormatter.string(from: sender.date)
        } else if start.isFirstResponder {
            self.start?.text = dateFormatter.string(from: sender.date)
        } else if complete.isFirstResponder {
            self.complete?.text = dateFormatter.string(from: sender.date)
        }
    }
    
    
    // MARK: - FieldData Header
    
    func passFieldData() {
        
        self.first.font = Font.Edittitle
        self.last.font = Font.Edittitle
        self.company.font = Font.Edittitle
        
        if (self.formController == "Leads" || self.formController == "Customer") {
            self.last.borderStyle = UITextBorderStyle.roundedRect
            self.last.layer.borderColor = UIColor(red:151/255.0, green:193/255.0, blue:252/255.0, alpha: 1.0).cgColor
            self.last.layer.borderWidth = 2.0
            self.last.layer.cornerRadius = 7.0
        }
        
        if (self.formController == "Vendor" || self.formController == "Employee") {
            self.first.borderStyle = UITextBorderStyle.roundedRect
            self.first.layer.borderColor = UIColor(red:151/255.0, green:193/255.0, blue:252/255.0, alpha: 1.0).cgColor
            self.first.layer.borderWidth = 2.0
            self.first.layer.cornerRadius = 7.0
        }
        
        if self.frm11 != nil {
            let myString1 = self.frm11
            self.first.text = myString1!.removeWhiteSpace()
        } else {
            self.first.text = ""
        }
        
        if self.frm12 != nil {
            let myString2 = self.frm12
            self.last.text = myString2!.removeWhiteSpace()
        } else {
            self.last.text = ""
        }
        
        if self.frm13 != nil {
            let myString3 = self.frm13
            self.company.text = myString3!.removeWhiteSpace()
        } else {
            self.company.text = ""
        }
        
        if (formController == "Customer") {
            
            if (self.status == "New") {
                self.company?.isHidden = true
            } else {
                self.company.placeholder = "Contractor"
                self.company?.inputView = self.pickerView
            }
        } else if (self.formController == "Vendor") {
            self.first.placeholder = "Company"
            self.last.placeholder = "Webpage"
            self.company.placeholder = "Manager"
            
        } else if (formController == "Employee") {
            self.first.placeholder = "First"
            self.last.placeholder = "Last"
            self.company.placeholder = "Subcontractor"
            
        } else {
            self.company.isHidden = true
        }
        
    }
    
    // MARK: - Parse
    
    func parseLookup() {
        
        if (self.formController == "Leads") {
            
            let query = PFQuery(className:"Advertising")
            query.whereKey("AdNo", equalTo:self.frm23!)
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    self.adName!.text = object!.object(forKey: "Advertiser") as? String
                }
            }
        } else if (self.formController == "Customer") {
            
            let query = PFQuery(className:"Product")
            query.whereKey("ProductNo", equalTo:self.frm23!)
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    self.adName!.text = object!.object(forKey: "Products") as? String
                }
            }
        }
        
        if (self.formController == "Leads" || self.formController == "Customer") {
            
            let query = PFQuery(className:"Job")
            query.whereKey("JobNo", equalTo:self.frm22!)
            query.cachePolicy = PFCachePolicy.cacheThenNetwork
            query.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    self.jobName!.text = object!.object(forKey: "Description") as? String
                }
            }
            
            let query1 = PFQuery(className:"Salesman")
            query1.whereKey("SalesNo", equalTo:self.frm21!)
            query1.cachePolicy = PFCachePolicy.cacheThenNetwork
            query1.getFirstObjectInBackground {(object: PFObject?, error: Error?) -> Void in
                if error == nil {
                    self.salesman!.text = object!.object(forKey: "Salesman") as? String
                }
            }
        } 
    }
    
    
    // MARK: - Load Form Data
    
    func loadFormData() {
        
        if (self.first.text == "") {
            self.first.text = defaults.string(forKey: "first")
        }
        if (self.last.text == "") {
            self.last.text = defaults.string(forKey: "last")
        }
        if (self.company.text == "") {
            self.company.text = defaults.string(forKey: "company")
        }
    }
    
    // MARK: Clear Form Data
    
    func clearFormData() {
        
            self.defaults.removeObject(forKey: "first")
            self.defaults.removeObject(forKey: "last")
            self.defaults.removeObject(forKey: "company")
    }
    
    // MARK: Save Form Data
    
    func saveFormData() {
        
        if (self.first.text != "") {
            self.defaults.set(self.first.text, forKey: "first")
        }
        if (self.last.text != "") {
            self.defaults.set(self.last.text, forKey: "last")
        }
        if (self.company.text != "") {
            self.defaults.set(self.company.text, forKey: "company")
        }
    }
    
    
    // MARK: - Move Keyboard
    // FIXME:
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(true, moveValue: 100)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(false, moveValue: 100)
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    
    // MARK: - Segues
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if ((indexPath as NSIndexPath).row == 3) {
            lookupItem = "City"
            self.performSegue(withIdentifier: "lookupDataSegue", sender: self)
        }
        if ((indexPath as NSIndexPath).row == 7) {
            lookupItem = "Salesman"
            self.performSegue(withIdentifier: "lookupDataSegue", sender: self)
        }
        if ((indexPath as NSIndexPath).row == 8) {
            lookupItem = "Job"
            self.performSegue(withIdentifier: "lookupDataSegue", sender: self)
        }
        if ((indexPath as NSIndexPath).row == 9) {
            if (self.formController == "Customer") {
                lookupItem = "Product"
            } else {
                lookupItem = "Advertiser"
            }
            self.performSegue(withIdentifier: "lookupDataSegue", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "lookupDataSegue" {
            saveFormData()
            let controller = segue.destination as? LookupData
            controller!.delegate = self
            controller!.lookupItem = lookupItem
        }
    }
    
    // MARK: - Update Data
    
    func updateData() {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        
        if (self.formController == "Leads") {
    
            let myActive : NSNumber = numberFormatter.number(from: (self.frm30 as? String)!)!
            
            var Lead = self.leadNo
            if Lead == nil { Lead = "" }
            let myLead = numberFormatter.number(from: Lead! as String)
            
            var Amount = self.amount.text
            if Amount == nil { Amount = "" }
            let myAmount = numberFormatter.number(from: Amount!)
            
            var Zip = self.zip.text
            if Zip == nil { Zip = "" }
            let myZip = numberFormatter.number(from: Zip!)
            
            var Sale = self.saleNo
            if Sale == nil { Sale = "" }
            let mySale = numberFormatter.number(from: Sale! as String)
            
            var Job = self.jobNo
            if Job == nil { Job = "" }
            let myJob = numberFormatter.number(from: Job! as String)
            
            var Ad = self.adNo
            if Ad == nil { Ad = "" }
            let myAd = numberFormatter.number(from: Ad! as String)

            if (self.status == "Edit") { //Edit Lead
                
                let query = PFQuery(className:"Leads")
                query.whereKey("objectId", equalTo:self.objectId!)
                query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) -> Void in
                    if error == nil {
                        updateblog!.setObject(myLead ?? NSNumber(value:-1), forKey:"LeadNo")
                        updateblog!.setObject(myActive ?? NSNumber(value:-1), forKey:"Active")
                        updateblog!.setObject(self.date.text ?? NSNull(), forKey:"Date")
                        updateblog!.setObject(self.first.text ?? NSNull(), forKey:"First")
                        updateblog!.setObject(self.last.text ?? NSNull(), forKey:"LastName")
                        updateblog!.setObject(self.address.text ?? NSNull(), forKey:"Address")
                        updateblog!.setObject(self.city.text ?? NSNull(), forKey:"City")
                        updateblog!.setObject(self.state.text ?? NSNull(), forKey:"State")
                        updateblog!.setObject(myZip ?? NSNumber(value:-1), forKey:"Zip")
                        updateblog!.setObject(self.phone.text ?? NSNull(), forKey:"Phone")
                        updateblog!.setObject(self.aptDate.text ?? NSNull(), forKey:"AptDate")
                        updateblog!.setObject(self.email.text ?? NSNull(), forKey:"Email")
                        updateblog!.setObject(myAmount ?? NSNumber(value:-1), forKey:"Amount")
                        updateblog!.setObject(self.spouse.text ?? NSNull(), forKey:"Spouse")
                        updateblog!.setObject(self.callback.text ?? NSNull(), forKey:"CallBack")
                        updateblog!.setObject(mySale ?? NSNumber(value:-1), forKey:"SalesNo")
                        updateblog!.setObject(myJob ?? NSNumber(value:-1), forKey:"JobNo")
                        updateblog!.setObject(myAd ?? NSNumber(value:-1), forKey:"AdNo")
                        updateblog!.setObject(self.comment.text ?? NSNull(), forKey:"Coments")
                        //updateblog!.setObject(self.photo.text ?? NSNull(), forKey:"Photo")
                        updateblog!.saveEventually()

                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                        
                    } else {
                        
                        self.simpleAlert(title: "Upload Failure", message: "Failure updating the data")
                    }
                }
                
            } else { //Save Lead
                
                let saveblog:PFObject = PFObject(className:"Leads")
                saveblog.setObject(self.leadNo ?? NSNumber(value:-1), forKey:"LeadNo")
                saveblog.setObject(myActive ?? NSNumber(value:1), forKey:"Active")
                saveblog.setObject(self.date.text ?? NSNull(), forKey:"Date")
                saveblog.setObject(self.first.text ?? NSNull(), forKey:"First")
                saveblog.setObject(self.last.text ?? NSNull(), forKey:"LastName")
                saveblog.setObject(self.address.text ?? NSNull(), forKey:"Address")
                saveblog.setObject(self.city.text ?? NSNull(), forKey:"City")
                saveblog.setObject(self.state.text ?? NSNull(), forKey:"State")
                saveblog.setObject(myZip ?? NSNumber(value:-1), forKey:"Zip")
                saveblog.setObject(self.phone.text ?? NSNull(), forKey:"Phone")
                saveblog.setObject(self.aptDate.text ?? NSNull(), forKey:"AptDate")
                saveblog.setObject(self.email.text ?? NSNull(), forKey:"Email")
                saveblog.setObject(myAmount ?? NSNumber(value:0), forKey:"Amount")
                saveblog.setObject(self.spouse.text ?? NSNull(), forKey:"Spouse")
                saveblog.setObject(self.callback.text ?? NSNull(), forKey:"CallBack")
                saveblog.setObject(mySale ?? NSNumber(value:-1), forKey:"SalesNo")
                saveblog.setObject(myJob ?? NSNumber(value:-1), forKey:"JobNo")
                saveblog.setObject(myAd ?? NSNumber(value:-1), forKey:"AdNo")
                saveblog.setObject(self.comment.text ?? NSNull(), forKey:"Coments")
                saveblog.setObject(self.photo ?? NSNull(), forKey:"Photo")
                //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                saveblog.saveInBackground { (success: Bool, error: Error?) -> Void in
                    if success == true {

                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                        
                    } else {
                        self.simpleAlert(title: "Upload Failure", message: "Failure updating the data")
                    }
                }
            }
        } else if (self.formController == "Customer") {
            
            let myActive : NSNumber = numberFormatter.number(from: self.frm30! as String)!
            
            var Cust = self.custNo
            if Cust == nil { Cust = "" }
            let myCust = numberFormatter.number(from: Cust! as String)
            
            var Lead = self.leadNo
            if Lead == nil { Lead = "" }
            let myLead = numberFormatter.number(from: Lead! as String)
            
            var Amount = (self.amount.text)
            if Amount == nil { Amount = "" }
            let myAmount =  numberFormatter.number(from: Amount!)
            
            var Zip = self.zip.text
            if Zip == nil { Zip = "" }
            let myZip = numberFormatter.number(from: Zip!)
            
            var Sale = self.saleNo
            if Sale == nil { Sale = "" }
            let mySale = numberFormatter.number(from: Sale! as String)
            
            var Job = self.jobNo
            if Job == nil { Job = "" }
            let myJob = numberFormatter.number(from: Job! as String)
            
            var Ad = self.adNo
            if Ad == nil { Ad = "" }
            let myAd = numberFormatter.number(from: Ad! as String)
            
            var Quan = self.callback.text
            if Quan == nil { Quan = "" }
            let myQuan = numberFormatter.number(from: Quan! as String)
            
            if (self.status == "Edit") { //Edit Customer
                
                let query = PFQuery(className:"Customer")
                query.whereKey("objectId", equalTo:self.objectId!)
                query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) -> Void in
                    if error == nil {
                        updateblog!.setObject(myCust ?? NSNumber(value:-1), forKey:"CustNo")
                        updateblog!.setObject(myLead ?? NSNumber(value:-1), forKey:"LeadNo")
                        updateblog!.setObject(myActive ?? NSNumber(value:1), forKey:"Active")
                        updateblog!.setObject(self.date.text ?? NSNull(), forKey:"Date")
                        updateblog!.setObject(self.first.text ?? NSNull(), forKey:"First")
                        updateblog!.setObject(self.last.text ?? NSNull(), forKey:"LastName")
                        updateblog!.setObject(self.address.text ?? NSNull(), forKey:"Address")
                        updateblog!.setObject(self.city.text ?? NSNull(), forKey:"City")
                        updateblog!.setObject(self.state.text ?? NSNull(), forKey:"State")
                        updateblog!.setObject(myZip ?? NSNumber(value:-1), forKey:"Zip")
                        updateblog!.setObject(self.phone.text ?? NSNull(), forKey:"Phone")
                        updateblog!.setObject(myQuan ?? NSNumber(value:-1), forKey:"Quan")
                        updateblog!.setObject(self.email.text ?? NSNull(), forKey:"Email")
                        updateblog!.setObject(myAmount ?? NSNumber(value:-1), forKey:"Amount")
                        updateblog!.setObject(self.spouse.text ?? NSNull(), forKey:"Spouse")
                        updateblog!.setObject(self.aptDate.text ?? NSNull(), forKey:"Rate")
                        updateblog!.setObject(mySale ?? NSNumber(value:-1), forKey:"SalesNo")
                        updateblog!.setObject(myJob ?? NSNumber(value:-1), forKey:"JobNo")
                        updateblog!.setObject(myAd ?? NSNumber(value:-1), forKey:"ProductNo")
                        updateblog!.setObject(self.start.text ?? NSNull(), forKey:"Start")
                        updateblog!.setObject(self.complete.text ?? NSNull(), forKey:"Completion")
                        updateblog!.setObject(self.comment.text ?? NSNull(), forKey:"Comments")
                        updateblog!.setObject(self.company.text ?? NSNull(), forKey:"Contractor")
                        updateblog!.setObject(self.photo ?? NSNull(), forKey:"Photo")
                        updateblog!.setObject(self.photo1 ?? NSNull(), forKey:"Photo1")
                        updateblog!.setObject(self.photo2 ?? NSNull(), forKey:"Photo2")
                        updateblog!.setObject(self.time ?? NSNull(), forKey:"Time")
                        updateblog!.saveEventually()

                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                        
                    } else {
                        
                        self.simpleAlert(title: "Upload Failure", message: "Failure updating the data")
                    }
                }
            } else { //Save Customer
                
                let saveblog:PFObject = PFObject(className:"Customer")
                saveblog.setObject(myCust ?? NSNumber(value:-1), forKey:"CustNo")
                saveblog.setObject(myLead ?? NSNumber(value:-1), forKey:"LeadNo")
                saveblog.setObject(myActive ?? NSNumber(value:1), forKey:"Active")
                saveblog.setObject(self.date.text ?? NSNull(), forKey:"Date")
                saveblog.setObject(self.first.text ?? NSNull(), forKey:"First")
                saveblog.setObject(self.last.text ?? NSNull(), forKey:"LastName")
                saveblog.setObject(self.company.text ?? NSNull(), forKey:"Contractor")
                saveblog.setObject(self.address.text ?? NSNull(), forKey:"Address")
                saveblog.setObject(self.city.text ?? NSNull(), forKey:"City")
                saveblog.setObject(self.state.text ?? NSNull(), forKey:"State")
                saveblog.setObject(myZip ?? NSNumber(value:-1), forKey:"Zip")
                saveblog.setObject(self.phone.text ?? NSNull(), forKey:"Phone")
                saveblog.setObject(self.aptDate.text ?? NSNull(), forKey:"Rate")
                saveblog.setObject(mySale ?? NSNumber(value:-1), forKey:"SalesNo")
                saveblog.setObject(myJob ?? NSNumber(value:-1), forKey:"JobNo")
                saveblog.setObject(myAd ?? NSNumber(value:-1), forKey:"ProductNo")
                saveblog.setObject(myAmount ?? NSNumber(value:0), forKey:"Amount")
                saveblog.setObject(myQuan ?? NSNumber(value:-1), forKey:"Quan")
                saveblog.setObject(self.email.text ?? NSNull(), forKey:"Email")
                saveblog.setObject(self.spouse.text ?? NSNull(), forKey:"Spouse")
                saveblog.setObject(self.callback.text ?? NSNull(), forKey:"CallBack")
                saveblog.setObject(self.start.text ?? NSNull(), forKey:"Start")
                saveblog.setObject(self.complete.text ?? NSNull(), forKey:"Completion")
                saveblog.setObject(self.comment.text ?? NSNull(), forKey:"Comment")
                saveblog.setObject(NSNull(), forKey:"Photo")
                //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                saveblog.saveInBackground { (success: Bool, error: Error?) -> Void in
                    if success == true {
 
                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                    } else {
                        self.simpleAlert(title: "Upload Failure", message: "Failure updating the data")
                    }
                }
            }
        } else  if (self.formController == "Vendor") {
            
            var Active = (self.frm30)
            if Active == nil { Active = "0" }
            let myActive =  numberFormatter.number(from: Active! as String)
            
            var Lead = (self.leadNo)
            if Lead == nil { Lead = "-1" }
            let myLead =  numberFormatter.number(from: Lead! as String)
            
            if (self.status == "Edit") { //Edit Vendor
                
                let query = PFQuery(className:"Vendors")
                query.whereKey("objectId", equalTo:self.objectId!)
                query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) -> Void in
                    if error == nil {
                        updateblog!.setObject(myLead!, forKey:"VendorNo")
                        updateblog!.setObject(myActive!, forKey:"Active")
                        updateblog!.setObject(self.first.text ?? NSNull(), forKey:"Vendor")
                        updateblog!.setObject(self.address.text ?? NSNull(), forKey:"Address")
                        updateblog!.setObject(self.city.text ?? NSNull(), forKey:"City")
                        updateblog!.setObject(self.state.text ?? NSNull(), forKey:"State")
                        updateblog!.setObject(self.zip.text ?? NSNull(), forKey:"Zip")
                        updateblog!.setObject(self.phone.text ?? NSNull(), forKey:"Phone")
                        updateblog!.setObject(self.salesman.text ?? NSNull(), forKey:"Phone1")
                        updateblog!.setObject(self.jobName.text ?? NSNull(), forKey:"Phone2")
                        updateblog!.setObject(self.adName.text ?? NSNull(), forKey:"Phone3")
                        updateblog!.setObject(self.email.text ?? NSNull(), forKey:"Email")
                        updateblog!.setObject(self.last.text ?? NSNull(), forKey:"WebPage")
                        updateblog!.setObject(self.amount.text ?? NSNull(), forKey:"Department")
                        updateblog!.setObject(self.spouse.text ?? NSNull(), forKey:"Office")
                        updateblog!.setObject(self.company.text ?? NSNull(), forKey:"Manager")
                        updateblog!.setObject(self.date.text ?? NSNull(), forKey:"Profession")
                        updateblog!.setObject(self.aptDate.text ?? NSNull(), forKey:"Assistant")
                        updateblog!.setObject(self.comment.text ?? NSNull(), forKey:"Comments")
                        updateblog!.saveEventually()

                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                        
                    } else {
                        
                        self.simpleAlert(title: "Upload Failure", message: "Failure updating the data")
                    }
                }
            } else { //Save Vendor
                
                let saveVend:PFObject = PFObject(className:"Vendors")
                saveVend.setObject(myLead!, forKey:"VendorNo")
                saveVend.setObject(myActive!, forKey:"Active")
                saveVend.setObject(self.first.text ?? NSNull(), forKey:"Vendor")
                saveVend.setObject(self.address.text ?? NSNull(), forKey:"Address")
                saveVend.setObject(self.city.text ?? NSNull(), forKey:"City")
                saveVend.setObject(self.state.text ?? NSNull(), forKey:"State")
                saveVend.setObject(self.zip.text ?? NSNumber(value:-1), forKey:"Zip")
                saveVend.setObject(self.phone.text ?? NSNull(), forKey:"Phone")
                saveVend.setObject(self.salesman.text ?? NSNull(), forKey:"Phone1")
                saveVend.setObject(self.jobName.text ?? NSNull(), forKey:"Phone2")
                saveVend.setObject(self.adName.text ?? NSNull(), forKey:"Phone3")
                saveVend.setObject(self.email.text ?? NSNull(), forKey:"Email")
                saveVend.setObject(self.last.text ?? NSNull(), forKey:"WebPage")
                saveVend.setObject(self.amount.text ?? NSNull(), forKey:"Department")
                saveVend.setObject(self.spouse.text ?? NSNull(), forKey:"Office")
                saveVend.setObject(self.company.text ?? NSNull(), forKey:"Manager")
                saveVend.setObject(self.date.text ?? NSNull(), forKey:"Profession")
                saveVend.setObject(self.aptDate.text ?? NSNull(), forKey:"Assistant")
                saveVend.setObject(self.comment.text ?? NSNull(), forKey:"Comments")
                //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                saveVend.saveInBackground { (success: Bool, error: Error?) -> Void in
                    if success == true {

                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                    } else {
                        
                        self.simpleAlert(title: "Upload Failure", message: "Failure updating the data")
                    }
                }
            }
        } else if (self.formController == "Employee") {
            
            var Active = (self.frm30)
            if Active == nil { Active = "0" }
            let myActive =  numberFormatter.number(from: Active! as String)
            
            var Lead = (self.leadNo)
            if Lead == nil { Lead = "-1" }
            let myLead =  numberFormatter.number(from: Lead!)
            
            if (self.status == "Edit") { //Edit Employee
                
                let query = PFQuery(className:"Employee")
                query.whereKey("objectId", equalTo:self.objectId!)
                query.getFirstObjectInBackground {(updateblog: PFObject?, error: Error?) -> Void in
                    if error == nil {
                        updateblog!.setObject(myLead!, forKey:"EmployeeNo")
                        updateblog!.setObject(myActive!, forKey:"Active")
                        updateblog!.setObject(self.company.text ?? NSNull(), forKey:"Company")
                        updateblog!.setObject(self.address.text ?? NSNull(), forKey:"Address")
                        updateblog!.setObject(self.city.text ?? NSNull(), forKey:"City")
                        updateblog!.setObject(self.state.text ?? NSNull(), forKey:"State")
                        updateblog!.setObject(self.zip.text ?? NSNull(), forKey:"Zip")
                        updateblog!.setObject(self.phone.text ?? NSNull(), forKey:"HomePhone")
                        updateblog!.setObject(self.salesman.text ?? NSNull(), forKey:"WorkPhone")
                        updateblog!.setObject(self.jobName.text ?? NSNull(), forKey:"CellPhone")
                        updateblog!.setObject(self.adName.text ?? NSNull(), forKey:"SS")
                        updateblog!.setObject(self.email.text ?? NSNull(), forKey:"Email")
                        updateblog!.setObject(self.last.text ?? NSNull(), forKey:"Last")
                        updateblog!.setObject(self.amount.text ?? NSNull(), forKey:"Department")
                        updateblog!.setObject(self.spouse.text ?? NSNull(), forKey:"Country")
                        updateblog!.setObject(self.first.text ?? NSNull(), forKey:"First")
                        updateblog!.setObject(self.callback.text ?? NSNull(), forKey:"Manager")
                        updateblog!.setObject(self.date.text ?? NSNull(), forKey:"Title")
                        updateblog!.setObject(self.aptDate.text ?? NSNull(), forKey:"Middle")
                        updateblog!.setObject(self.comment.text ?? NSNull(), forKey:"Comments")
                        updateblog!.saveEventually()

                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                        
                    } else {
                        
                        self.simpleAlert(title: "Upload Failure", message: "Failure updating the data")
                    }
                }
            } else { //Save Employee
                
                let saveblog:PFObject = PFObject(className:"Employee")
                saveblog.setObject(NSNumber(value:-1), forKey:"EmployeeNo")
                saveblog.setObject(NSNumber(value:1), forKey:"Active")
                saveblog.setObject(self.company.text ?? NSNull(), forKey:"Company")
                saveblog.setObject(self.address.text ?? NSNull(), forKey:"Address")
                saveblog.setObject(self.city.text ?? NSNull(), forKey:"City")
                saveblog.setObject(self.state.text ?? NSNull(), forKey:"State")
                saveblog.setObject(self.zip.text ?? NSNull(), forKey:"Zip")
                saveblog.setObject(self.phone.text ?? NSNull(), forKey:"HomePhone")
                saveblog.setObject(self.salesman.text ?? NSNull(), forKey:"WorkPhone")
                saveblog.setObject(self.jobName.text ?? NSNull(), forKey:"CellPhone")
                saveblog.setObject(self.adName.text ?? NSNull(), forKey:"SS")
                saveblog.setObject(self.date.text ?? NSNull(), forKey:"Country")
                saveblog.setObject(self.email.text ?? NSNull(), forKey:"Email")
                saveblog.setObject(self.last.text ?? NSNull(), forKey:"Last")
                saveblog.setObject(self.amount.text ?? NSNull(), forKey:"Department")
                saveblog.setObject(self.aptDate.text ?? NSNull(), forKey:"Middle")
                saveblog.setObject(self.first.text ?? NSNull(), forKey:"First")
                saveblog.setObject(self.callback.text ?? NSNull(), forKey:"Manager")
                saveblog.setObject(self.spouse.text ?? NSNull(), forKey:"Title")
                saveblog.setObject(self.comment.text ?? NSNull(), forKey:"Comments")
                //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                saveblog.saveInBackground { (success: Bool, error: Error?) -> Void in
                    if success == true {

                        self.simpleAlert(title: "Upload Complete", message: "Successfully updated the data")
                        
                    } else {
                        
                        self.simpleAlert(title: "Upload Failure", message: "Failure updating the data")
                    }
                }
            }
        }
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeId")
            self.show(vc!, sender: self)
        }
    }
}

extension EditData: LookupDataDelegate {
    func cityFromController(_ passedData: NSString) {
        self.city.text = passedData as String
    }
    func stateFromController(_ passedData: NSString) {
        self.state.text = passedData as String
    }
    func zipFromController(_ passedData: NSString) {
        self.zip.text = passedData as String
    }
    func salesFromController(_ passedData: NSString) {
        self.saleNo = passedData as String
    }
    func salesNameFromController(_ passedData: NSString) {
        self.salesman.text = passedData as String
    }
    func jobFromController(_ passedData: NSString) {
        self.jobNo = passedData as String
    }
    func jobNameFromController(_ passedData: NSString) {
        self.jobName.text = passedData as String
    }
    func productFromController(_ passedData: NSString) {
        self.adNo = passedData as String
    }
    func productNameFromController(_ passedData: NSString) {
        self.adName.text = passedData as String
    }
}