//
//  CloudFileListViewController.swift
//  PWCloud
//
//  Created by mfuta1971 on 2016/04/06.
//  Copyright © 2016年 Paveway. All rights reserved.
//

import UIKit

class CloudFileListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, iCloudDelegate  {

    let kTitle = "iCloudファイル一覧"

    let kCellName = "Cell"

    let kRefreshTitle = "更新"

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var toolbar: UIToolbar!

    @IBOutlet weak var addToolbarButton: UIBarButtonItem!

    var refreshControl: UIRefreshControl?

    var fileList = NSMutableArray()

    var fileNameList = NSMutableArray()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = kTitle

        tableView.dataSource = self
        tableView.delegate = self

        createCellLogPressed()

//        createRefreshControl()

        initICloud()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let cloud = iCloud.sharedCloud()
        cloud.updateFiles()
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fileList.count
        return count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellName) as UITableViewCell?
        if (cell == nil) {
            cell = UITableViewCell()
        }

        cell!.textLabel?.text = ""
        cell!.accessoryType = .None

        let row = indexPath.row
        let count = fileList.count
        if row + 1 > count {
            return cell!
        }
        let fileName = fileNameList[row] as! String
        cell!.textLabel?.text = fileName

        let file = fileList[row]
        if (file.directory != nil) {
            cell!.accessoryType = .DisclosureIndicator
        } else {
            cell!.accessoryType = .DetailDisclosureButton
        }

        return cell!
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let row = indexPath.row
        let count = fileList.count
        if row + 1 > count {
            return
        }

        let file = fileList[row]
        let fileName = fileNameList[row] as! String
        if (file.directory != nil) {

        } else {
            let cloud = iCloud.sharedCloud()
            cloud.retrieveCloudDocumentWithName(fileName, completion: { (cloudDocument: UIDocument!, cloudData: NSData!, error: NSError!) -> Void in
                let fileData = String.init(data: cloudData, encoding: NSUTF8StringEncoding)
                let vc = EditCloudFileViewController(pathName: "", fileName: fileName, fileData: fileData!)
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }

    func createCellLogPressed() {
        let selector = #selector(cellLongPressed(_:))
        let cellLongPressedAction = selector
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: cellLongPressedAction)
        longPressRecognizer.delegate = self
        tableView.addGestureRecognizer(longPressRecognizer)
    }

    func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.locationInView(tableView)
        let indexPath = tableView!.indexPathForRowAtPoint(point)

        if indexPath == nil {
            return
        }

        if recognizer.state == UIGestureRecognizerState.Began {
            let row = indexPath!.row
            let count = fileList.count
            if row + 1 > count {
                return
            }

            let fileName = fileNameList[row] as! String
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            showActionSheet(fileName, index: row, cell: cell!)
        }
    }

    private func showActionSheet(name: String, index: Int, cell: UITableViewCell) {
        let alertTitle = "iCloudファイル操作"
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .ActionSheet)

        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = cell.frame

        let cancelButtonTitle = "キャンセル"
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        let deleteButtonTitle = "削除"
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            self.showDeleteFileConfirmAlert(name, index: index)
        })
        alert.addAction(deleteAction)

        self.presentViewController(alert, animated: true, completion: nil)
    }

    private func showDeleteFileConfirmAlert(name: String, index: Int) {
        let alertTitle = "確認"
        let alertMessage = "\(name)を削除しますか？"
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)

        let cancelButtonTitle = "キャンセル"
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        let deleteButtonTitle = "削除"
        let okAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            self.deleteFile(name, index: index)
        })
        alert.addAction(okAction)

        self.presentViewController(alert, animated: true, completion: nil)
    }

    private func deleteFile(name: String, index: Int) {
        let cloud = iCloud.sharedCloud()
        cloud.deleteDocumentWithName(name, completion: { (error: NSError!) -> Void in
            cloud.updateFiles()
            self.fileList.removeObjectAtIndex(index)
            self.fileNameList.removeObjectAtIndex(index)
            self.tableView.reloadData()
        })
    }

    // MARK: - iCloud

    func initICloud() {
        let cloud = iCloud.sharedCloud()

        cloud.delegate = self
        cloud.verboseLogging = true
        cloud.setupiCloudDocumentSyncWithUbiquityContainer(nil)

        let cloudAvailable = cloud.checkCloudAvailability()
        if !cloudAvailable {
            NSLog("iCloud not avaiable.")
            return
        }
    }

    // MARK: - iCloudDelegate

    func iCloudAvailabilityDidChangeToState(cloudIsAvailable: Bool, withUbiquityToken ubiquityToken: AnyObject!, withUbiquityContainer ubiquityContainer: NSURL!) {
        NSLog("iCloudAvailabilityDidChangeToState")
    }

    func iCloudDidFinishInitializingWitUbiquityToken(cloudToken: AnyObject!, withUbiquityContainer ubiquityContainer: NSURL!) {
        NSLog("iCloudDidFinishInitializingWitUbiquityToken")
    }

    func iCloudFilesDidChange(files: NSMutableArray!, withNewFileNames fileNames: NSMutableArray!) {
        NSLog("iCloudFilesDidChange")
        
        fileList = files
        fileNameList = fileNames
        
        tableView.reloadData()
    }

    // MARK: - Button

    @IBAction func addToolbarButtonPressed(sender: AnyObject) {
        let vc = AddCloudFileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Refresh controller

    func createRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: kRefreshTitle)
        let action = #selector(refresh)
        refreshControl!.addTarget(self, action: action, forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl!)
    }

    func refresh() {
        tableView.reloadData()
    }
}
