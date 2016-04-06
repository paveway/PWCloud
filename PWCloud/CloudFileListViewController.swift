//
//  CloudFileListViewController.swift
//  PWCloud
//
//  Created by mfuta1971 on 2016/04/06.
//  Copyright © 2016年 Paveway. All rights reserved.
//

import UIKit

class CloudFileListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, iCloudDelegate  {

    let kTitle = "iCloudファイル一覧"

    let kCellName = "Cell"

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var toolbar: UIToolbar!

    @IBOutlet weak var addToolbarButton: UIBarButtonItem!

    var fileList = NSMutableArray()

    var fileNameList = NSMutableArray()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = kTitle

        tableView.dataSource = self
        tableView.delegate = self

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

        return cell!
    }

    // MARK: - UITableViewDelegate

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
    }
}
