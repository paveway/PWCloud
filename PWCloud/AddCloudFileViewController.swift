//
//  AddCloudFileViewController.swift
//  PWCloud
//
//  Created by mfuta1971 on 2016/04/06.
//  Copyright © 2016年 Paveway. All rights reserved.
//

import UIKit

class AddCloudFileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {

    let kTitle = "iCloudファイル追加"

    let kCellName = "Cell"

    let kLineDataCellName = "LineDataCell"

    let kSectionTitleList = [
        "ファイル名",
        "ファイルタイプ"
    ]

    let kFileTypeCellTitleList = [
        "ファイル",
        "ディレクトリ"
    ]

    enum SectionIndex: Int {
        case FileName
        case FileType
    }

    enum FileTypeCellIndex: Int {
        case File
        case Dir
    }

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = kTitle

        let action = #selector(rightBarButtonPressed(_:))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: action)

        tableView.dataSource = self
        tableView.delegate = self

        let nib  = UINib(nibName: "EnterLineDataTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: kLineDataCellName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return kSectionTitleList.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return kSectionTitleList[section] as String
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count: Int
        switch section {
        case SectionIndex.FileName.rawValue:
            count = 1
            break

        case SectionIndex.FileType.rawValue:
            count = kFileTypeCellTitleList.count
            break

        default:
            count = 0
            break
        }
        return count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell: UITableViewCell?

        let section = indexPath.section
        let row = indexPath.row

        switch section {
        case SectionIndex.FileName.rawValue:
            var lineDataCell = tableView.dequeueReusableCellWithIdentifier(kLineDataCellName) as? EnterLineDataTableViewCell
            if (lineDataCell == nil) {
                lineDataCell = EnterLineDataTableViewCell()
            }

            let textField = lineDataCell?.textField
            textField?.delegate = self
            textField?.keyboardType = .ASCIICapable
            textField?.returnKeyType = .Done
            cell = lineDataCell! as UITableViewCell
            break

        case SectionIndex.FileType.rawValue:
            cell = tableView.dequeueReusableCellWithIdentifier(kCellName) as UITableViewCell?
            if (cell == nil) {
                cell = UITableViewCell()
            }

            let title = kFileTypeCellTitleList[row]
            cell!.textLabel?.text = title

            if row == FileTypeCellIndex.File.rawValue {
                cell?.accessoryType = .Checkmark
            } else {
                cell?.accessoryType = .None
            }
            break

        default:
            break
        }
        
        return cell!
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let section = indexPath.section
        let row = indexPath.row

        switch section {
        case SectionIndex.FileType.rawValue:
            let cell = tableView.cellForRowAtIndexPath(indexPath)

            cell?.accessoryType = .Checkmark

            let valuesNum = kFileTypeCellTitleList.count
            for i in 0 ..< valuesNum {
                if i != row {
                    let unselectedIndexPath = NSIndexPath(forRow: i, inSection: section)
                    let unselectedCell = tableView.cellForRowAtIndexPath(unselectedIndexPath)
                    unselectedCell?.accessoryType = .None
                }
            }
            break

        default:
            break
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    func screenTapped(sender: AnyObject) {
        view.endEditing(true)
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool{
        let result = textField.resignFirstResponder()
        return result
    }

    // MARK: - Button

    func rightBarButtonPressed(sender: UIButton) {
        let section = SectionIndex.FileName.rawValue
        let indexPath = NSIndexPath(forItem: 0, inSection: section)
        let cell = tableView?.cellForRowAtIndexPath(indexPath) as! EnterLineDataTableViewCell
        let textField = cell.textField
        textField.resignFirstResponder()

        let name = textField.text!
        if name.isEmpty {
            let title = "エラー"
            let message = "ファイル名が入力されていません。"
            let okButtonTitle = "閉じる"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: okButtonTitle, style: .Default, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
            return
        }

        var fileType = -1
        let fileTypeSection = SectionIndex.FileType.rawValue
        let fileTypeRowNum = tableView?.numberOfRowsInSection(fileTypeSection)
        for var i = 0; i < fileTypeRowNum; i++ {
            let indexPath = NSIndexPath(forItem: i, inSection: fileTypeSection)
            let cell = tableView?.cellForRowAtIndexPath(indexPath)
            let check = cell?.accessoryType

            if check == UITableViewCellAccessoryType.Checkmark {
                fileType = indexPath.row
                break
            }
        }
        if fileType == -1 {
            return
        }

        switch fileType {
        case FileTypeCellIndex.File.rawValue:
            let cloud = iCloud.sharedCloud()
            let fileData = "".dataUsingEncoding(NSUTF8StringEncoding)
            cloud.saveAndCloseDocumentWithName(name, withContent: fileData!, completion: { (cloudDocument: UIDocument!, cloudData: NSData!, error: NSError!) -> Void in
            })
            navigationController?.popViewControllerAnimated(true)
            break

        case FileTypeCellIndex.Dir.rawValue:
            break

        default:
            return
        }
    }
}
