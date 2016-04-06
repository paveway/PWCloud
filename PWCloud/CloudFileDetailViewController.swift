//
//  CloudFileDetailViewController.swift
//  PWCloud
//
//  Created by mfuta1971 on 2016/04/06.
//  Copyright © 2016年 Paveway. All rights reserved.
//

import UIKit

class CloudFileDetailViewController: UIViewController {

    let kTitle = "iCloudファイル詳細"

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = kTitle

//        tableView.dataSource = self
//        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
