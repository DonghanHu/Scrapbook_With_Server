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
    @IBOutlet weak var tableViewStatusLabel: NSTextField!
    
    
    @IBOutlet weak var applicationNameFixedLabel: NSTextField!
    @IBOutlet weak var applicationCategoryFixedLabel: NSTextField!
    @IBOutlet weak var firstMetaDataFixedLabel: NSTextField!
    @IBOutlet weak var secondMetaDataFixedLabel: NSTextField!
    
    
    
    var receivedScreenshotInfor = [String : Any]()
    var checkBoxButtonsIdentifierWithStatus = [String : Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        applicationNameFixedLabel.stringValue = "Application Name"
        applicationCategoryFixedLabel.stringValue = "Application Category"
        
           
        tableView.delegate = self
        tableView.dataSource = self
        tableView.action = #selector(tableViewSingleClick(_:))
        
        self.title = "Captured View"
        
        // all data here
        receivedScreenshotInfor = tempScreenshotInformationStruct.dataDictionary
        
//        print(receivedScreenshotInfor)
//        print(type(of: receivedScreenshotInfor))
        // Dictionary<String, Any>
        
        // set the screenshot
        displayLatestScreenshot(data : receivedScreenshotInfor)
        
        // set placeholder for title and text
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        let dateString = dateFormatter.string(from: date)
        memoTitle.placeholderString = dateString
        memoText.placeholderString = "This is your memo..."
        
        // save & delete button
        saveScreenshotButton.title = "Save"
        deleteScreenshotButton.title = "Delete"
        
        
        // check code here
        
        
    }
    
    // code here
    
    @objc func checkBoxInteractionMethod(_ sender: NSButton){
        // print("checkbox interaction function")
        // print(type(of: sender.state))
        
        let IntegerSenderState = sender.state.rawValue
        // print(sender.state)
        // 1 is on and 0 is off
        if(IntegerSenderState == 0){
            checkBoxButtonsIdentifierWithStatus[sender.identifier!.rawValue as String] = 0
        }
        else{
            checkBoxButtonsIdentifierWithStatus[sender.identifier!.rawValue as String] = 1
        }
        
        // print (tempScreenshotInformationStruct.capturedApplicationNameArray[tableView.selectedRow])
        
    }
    
    
    
    func displayLatestScreenshot(data : [String : Any]) {
        displayScreenshot.imageScaling = .scaleProportionallyUpOrDown
        let fileManager = FileManager.default
        let screenshotPathString = data["ImagePath"] as! String
        if fileManager.fileExists(atPath: screenshotPathString){
            print("imgae existed")
        }
        else {
            print("image not existed")
        }
        let currentScreenshot = NSImage(contentsOfFile: screenshotPathString)
        displayScreenshot.image = currentScreenshot
        
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        // save title and text into array
        if(memoTitle.stringValue == ""){
            tempScreenshotInformationStruct.dataDictionary["ScreenshotTitle"] = memoTitle.placeholderString
        }else{
            tempScreenshotInformationStruct.dataDictionary["ScreenshotTitle"] = memoTitle.stringValue
        }
        
        if(memoText.stringValue == ""){
            tempScreenshotInformationStruct.dataDictionary["ScreenshotText"] = memoText.placeholderString
        }else{
            tempScreenshotInformationStruct.dataDictionary["ScreenshotText"] = memoText.stringValue
        }
        print("save button clicked")
        
        var allApplicationsDataDic = tempScreenshotInformationStruct.dataDictionary["ApplicationInformation"] as! [[String : Any]]

        for key in checkBoxButtonsIdentifierWithStatus.keys{
            if(checkBoxButtonsIdentifierWithStatus[key] == 0){
                let strs = key.components(separatedBy: "@")
                let appName = strs[0]
                
                for (index, element) in allApplicationsDataDic.enumerated(){
                    let tempName = element["ApplicationName"] as! String
                    if (appName == tempName){
                        allApplicationsDataDic.remove(at: index)
                    }
                }
                
            }
            else{
                continue
            }
        }
        tempScreenshotInformationStruct.dataDictionary["ApplicationInformation"] = allApplicationsDataDic
        print(tempScreenshotInformationStruct.dataDictionary)
        print(type(of: tempScreenshotInformationStruct.dataDictionary))
        
        // save data into json file
        // writeAndReadMetaDataInformaionIntoJsonFileTest(metaData: tempScreenshotInformationStruct.dataDictionary)
        writeDataIntoJson(metaData: tempScreenshotInformationStruct.dataDictionary)
        
        let dialogReuslt = dialogOK(question: "This recording has been saved successfully.", text: "Click OK to continue")
        
        self.view.window?.close()
        
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        // delete the screenshot from forder
        let filePathString = receivedScreenshotInfor["ImagePath"] as! String
        let fileURL = URL(fileURLWithPath: filePathString)
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("delete successfully!")
        } catch {
            print("delete screenshot error:", error)
        }
        let dialogReuslt = dialogOK(question: "This recording has been deleted successfully.", text: "Click OK to continue.")
       
        // reset values, struct, variables
        // here
        tempScreenshotInformationStruct.capturedApplicationNameArray = [String]()
        tempScreenshotInformationStruct.dataDictionary = [String : Any]()
        
        self.view.window?.close()
    }
    
    // func for pupping up a alert window for saving and deleting
    func dialogOK(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    // function for update tableView status
    func updateStatus() {
        let tempDic = tempScreenshotInformationStruct.dataDictionary["ApplicationInformation"] as! [[String : Any]]
        let rowCount = tempDic.count ?? 0
        let text: String
        // 1
        let itemsSelected = tableView.selectedRowIndexes.count
        // 2
        if(itemsSelected == 0) {
            text = "\(rowCount) items"
        }
        else {
            text = "\(itemsSelected) of \(rowCount) selected"
        }
        // 3
        tableViewStatusLabel.stringValue = text
        tableViewStatusLabel.isHidden = true
        
    }

    // single click in tableView
    @objc func tableViewSingleClick(_ sender:AnyObject){
        if (tableView.selectedRowIndexes.count == 1){
            
            let tableRowIndex = tableView.selectedRow
            print("table row Index for clicking:", tableRowIndex)
            
            let allApplicationsDataDic = tempScreenshotInformationStruct.dataDictionary["ApplicationInformation"] as! [[String : Any]]
            
            let singleApplicationInforDic = allApplicationsDataDic[tableRowIndex]
            
            let applicationName = tempScreenshotInformationStruct.capturedApplicationNameArray[tableView.selectedRow]
            
            applicationNameLabel.stringValue = applicationName
            
            let categoryIdentify = singleApplicationInforDic["Category"] as! String
            
            if (categoryIdentify == "Safari" || categoryIdentify == "Google Chrome"){
                applicationCategoryLabel.stringValue = "Borwser"
                firstMetaDataFixedLabel.stringValue = "Webpage Title"
                secondMetaDataFixedLabel.stringValue = "Wbepage URL"
            }
            else if(categoryIdentify == "Undefined"){
                applicationCategoryLabel.stringValue = "Undefined"
                firstMetaDataFixedLabel.stringValue = "Unavaliable data"
                secondMetaDataFixedLabel.stringValue = "Unavaliable data"
            }
            else if (categoryIdentify == "Finder"){
                applicationCategoryLabel.stringValue = "Finder"
                firstMetaDataFixedLabel.stringValue = "Folder Name"
                secondMetaDataFixedLabel.stringValue = "Folder Local Path"
            }
            else {
                applicationCategoryLabel.stringValue = "Productivity"
                firstMetaDataFixedLabel.stringValue = "File/Document Name"
                secondMetaDataFixedLabel.stringValue = "File/Document Local Path"
            }
            
        
            applicationCategoryLabel.stringValue = singleApplicationInforDic["Category"] as! String
            metadataOneLabel.stringValue = singleApplicationInforDic["FirstMetaData"] as! String
            metadataTwoLabel.stringValue = singleApplicationInforDic["SecondMetaData"] as! String
            
            
//            for appInfor in allApplicationsDataDic{
//                let tempName = appInfor["ApplicationName"] as! String
//                if (applicationName == tempName){
//                    applicationCategoryLabel.stringValue = appInfor["Category"] as! String
//                    metadataOneLabel.stringValue = appInfor["FirstMetaData"] as! String
//                    metadataTwoLabel.stringValue = appInfor["SecondMetaData"] as! String
//                }
//            }
        }
    }
    
    func writeDataIntoJson(metaData : Dictionary<String , Any>){
        let path = basicInformation.jsonFilePathString
        
            do {
                let originalData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                
                do{
                    var rawJsonData = try JSONSerialization.jsonObject(with : originalData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Array<Dictionary<String, Any>>
                    // print(type(of: rawJsonData))
                    rawJsonData?.append(metaData)
                    let jsonData = try JSONSerialization.data(withJSONObject: rawJsonData, options: [])
                    if let file = FileHandle(forWritingAtPath : basicInformation.jsonFilePathString) {
                        file.write(jsonData)
                        file.closeFile()
                    }
                    
                    
                }
                catch{
                     print("Unexpected error: \(error).")
                }

                
              } catch {
                   // handle error
              }
    }
    
    func stringArrayToData(stringArray: [String]) -> Data? {
      return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
    }
    
    func writeAndReadMetaDataInformaionIntoJsonFileTest (metaData : Dictionary<String, Any>){
        
        let jsonFilePathURL = basicInformation.jsonFilePathURL as! URL
        print(jsonFilePathURL)
        // /Users/donghanhu/Documents/ScrapbookServer/Scrapbook.json
        var fileSize : UInt64
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: basicInformation.jsonFilePathString)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            if fileSize == 0{
                print("json file is empty")
                let jsonData = try! JSONSerialization.data(withJSONObject: metaData, options: JSONSerialization.WritingOptions.prettyPrinted)
                try jsonData.write(to: jsonFilePathURL, options : .atomic)
            }
            else{
                
                let rawData : NSData = try! NSData(contentsOf: basicInformation.jsonFilePathURL!)
                do{

                    var rawJsonData = try JSONSerialization.jsonObject(with : rawData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Array<Dictionary<String, Any>>
                    
                    rawJsonData?.append(metaData)
                    
                    let jsonData = try! JSONSerialization.data(withJSONObject : rawJsonData!, options: JSONSerialization.WritingOptions.prettyPrinted)
                    if let file = FileHandle(forWritingAtPath : basicInformation.jsonFilePathString) {
                        file.write(jsonData)
                        file.closeFile()
                    }
                }catch {print(error)}
            }
        } catch {
            print("preview Error: \(error)")
            }
    }
    
    // end of the class: ViewController
}


extension CapturedViewWiondow: NSTableViewDataSource {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    
    let tempDic = tempScreenshotInformationStruct.dataDictionary["ApplicationInformation"] as! [[String : Any]]
    let rowCount = tempDic.count ?? 0
    print("row count", rowCount)
    return rowCount
  }

}


extension CapturedViewWiondow: NSTableViewDelegate {

  fileprivate enum CellIdentifiers {
    static let CheckBoxCell = "CheckboxCellID"
    static let ApplicationNameCell = "ApplicationnameCellID"

  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

    var appName: String = ""
    var cellIdentifier: String = ""

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .long
    
    // 1
    // sanity check here, gate keeper
    if (row >= tempScreenshotInformationStruct.capturedApplicationNameArray.count){
//        dialogOK(question: "Sanity Check error", text: "Sanity Check error: the tableView's row value is greater than acutal applications couont.")
        print("Sanity Check error: the tableView's row value is greater than acutal applications couont.")
        print("row value:", row)
        print("tempScreenshotInformationStruct.capturedApplicationNameArray:", tempScreenshotInformationStruct.capturedApplicationNameArray)
        return nil
    }
    
    // print("row index", row)
    
    let item = tempScreenshotInformationStruct.capturedApplicationNameArray[row]
    
    let allApplicationsDataDic = tempScreenshotInformationStruct.dataDictionary["ApplicationInformation"] as! [[String : Any]]
    var rankValue = String()
    
    // print(allApplicationsDataDic)
    let tempName = allApplicationsDataDic[row]["ApplicationName"] as! String
    rankValue = allApplicationsDataDic[row]["Rank"] as! String
    print("rank value:", rankValue)
//    for appInfor in allApplicationsDataDic{
//        let tempName = appInfor["ApplicationName"] as! String
//        if (item == tempName){
//            rankValue = appInfor["Rank"] as! String
//            break
//        }
//    }

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
        let xCoordinate = tableView.tableColumns[0].width / 3.0
        let checkBoxFrame = NSRect(x: xCoordinate, y: 8, width: 25, height: 25)
        let newCheckButton = NSButton.init(checkboxWithTitle: item, target: nil, action: #selector(CapturedViewWiondow.checkBoxInteractionMethod(_:)))
        // assign the frame to checkbox
        newCheckButton.frame = checkBoxFrame
        // initial statue is on
        let buttonIdentifierString = item + "@" + rankValue
        newCheckButton.identifier = NSUserInterfaceItemIdentifier(rawValue: buttonIdentifierString)
        checkBoxButtonsIdentifierWithStatus[buttonIdentifierString] = 1
        newCheckButton.state = .on
        newCheckButton.title = ""
        
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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
    }


}
