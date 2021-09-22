//
//  CapturedViewWiondow.swift
//  ScrapbookMenuBar
//
//  Created by Donghan Hu on 9/20/21.
//  Copyright © 2021 Donghan Hu. All rights reserved.
//

import Cocoa

class CapturedViewWiondow: NSViewController {

    // image display item: nsimageview
    @IBOutlet weak var displayScreenshot: NSImageView!
    // memo information: title and text
    @IBOutlet weak var memoTitle: NSTextField!
    @IBOutlet weak var memoText: NSTextField!
    // labels for displaying information and meta-data
    @IBOutlet weak var applicationNameLabel: NSTextField!
    @IBOutlet weak var applicationCategoryLabel: NSTextField!
    @IBOutlet weak var metadataOneLabel: NSTextField!
    @IBOutlet weak var metadataTwoLabel: NSTextField!
    // save and delete screenshot button
    @IBOutlet weak var deleteScreenshotButton: NSButton!
    @IBOutlet weak var saveScreenshotButton: NSButton!
    // tableView item
    @IBOutlet weak var tableView: NSTableView!
    
    
    var receivedScreenshotInfor = [String : Any]()
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        tableView.delegate = self
        tableView.dataSource = self

        // all data here
        receivedScreenshotInfor = tempScreenshotInformationStruct.dataDictionary
        
        print(receivedScreenshotInfor)
        print(type(of: receivedScreenshotInfor))
        // Dictionary<String, Any>
        
        
    }
    
    @objc func checkBoxInteractionMethod(_ sender: NSButton){
        print("checkbox interaction function")
    }
    
    // end of the class: ViewController
}


extension CapturedViewWiondow: NSTableViewDataSource {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    
    let tempDic = tempScreenshotInformationStruct.dataDictionary["ApplicationInformation"] as! [[String : Any]]
    let rowCount = tempDic.count ?? 0
    return rowCount
  }

}


extension CapturedViewWiondow: NSTableViewDelegate {

  fileprivate enum CellIdentifiers {
    static let CheckBoxCell = "CheckboxCellID"
    static let ApplicationNameCell = "ApplicationnameCellID"

  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

    var image: NSImage?
    var appName: String = ""
    var cellIdentifier: String = ""

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .long
    
    // 1
    let item = tempScreenshotInformationStruct.capturedApplicationNameArray[row]

    // 2
    if tableColumn == tableView.tableColumns[1] {
        appName = item
        cellIdentifier = CellIdentifiers.ApplicationNameCell
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = appName
            return cell
        }
    // for checkbox column
    } else if tableColumn == tableView.tableColumns[0]{
        appName = "whatever"
        cellIdentifier = CellIdentifiers.CheckBoxCell
        // set the frame of each checkbox
        let checkBoxFrame = NSRect(x: 10, y: 8, width: 25, height: 25)
        let newCheckButton = NSButton.init(checkboxWithTitle: item, target: nil, action: #selector(CapturedViewWiondow.checkBoxInteractionMethod(_:)))
        // assign the frame to checkbox
        newCheckButton.frame = checkBoxFrame
        // initial statue is on
        newCheckButton.state = .on
        newCheckButton.title = item
        
        return newCheckButton
    }
        
    else{
        print("nothing here for the no-existed clomun currently")
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = appName
          return cell
        }
    }

    // 3
    return nil
  }

}
