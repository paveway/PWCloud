//
//  EditCloudFileViewController.swift
//  PWCloud
//
//  Created by mfuta1971 on 2016/04/07.
//  Copyright © 2016年 Paveway. All rights reserved.
//

import UIKit

class EditCloudFileViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!

    var pathName: String!

    var fileName: String!

    var fileData: String!

    var preOffset: CGPoint?

    // MARK: - Initializer

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(pathName: String, fileName: String, fileData: String) {
        self.pathName = pathName
        self.fileName = fileName
        self.fileData = fileData

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = fileName

        let action = #selector(rightBarButtonPressed(_:))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: action)

        textView.delegate = self
        textView.text = fileData

        let notificationCenter = NSNotificationCenter.defaultCenter()
        let keyboardWillShow = #selector(keyboardWillShow(_:))
        notificationCenter.addObserver(self, selector: keyboardWillShow, name: UIKeyboardWillShowNotification, object: nil)
        let keyboardWillHide = #selector(keyboardWillHide(_:))
        notificationCenter.addObserver(self, selector: keyboardWillHide, name: UIKeyboardWillHideNotification, object: nil)
        let keyboardDidHide = #selector(keyboardDidHide(_:))
        notificationCenter.addObserver(self, selector: keyboardDidHide, name: UIKeyboardDidHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillDisappear(animated: Bool) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)

        super.viewWillDisappear(animated)
    }

    // MARK: - Button

    func rightBarButtonPressed(sender: UIButton) {
        textView.resignFirstResponder()

        let cloud = iCloud.sharedCloud()
        let fileDataString = textView.text
        let fileData = fileDataString.dataUsingEncoding(NSUTF8StringEncoding)
        cloud.saveAndCloseDocumentWithName(fileName, withContent: fileData!, completion: { (cloudDocument: UIDocument!, cloudData: NSData!, error: NSError!) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        })
    }

    // MARK: - Notification

    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let size = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size

        var contentInsets = UIEdgeInsetsMake(0.0, 0.0, size.height, 0.0)
        contentInsets = textView.contentInset
        contentInsets.bottom = size.height

        textView.contentInset = contentInsets
        textView.scrollIndicatorInsets = contentInsets
    }

    func keyboardWillHide(notification: NSNotification) {
        var contentsInsets = textView.contentInset
        contentsInsets.bottom = 0
        textView.contentInset = contentsInsets
        textView.contentInset.bottom = 0
        preOffset = textView.contentOffset
    }

    func keyboardDidHide(notification: NSNotification) {
        if preOffset != nil {
            textView.setContentOffset(preOffset!, animated: true)
        }
    }
}
