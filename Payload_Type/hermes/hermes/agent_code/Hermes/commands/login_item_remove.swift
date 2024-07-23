//
//  login_item.swift
//  Hermes
//
//  Created by Offensive Security on 2/29/24.
//

import Foundation

func login_item_remove(job: Job) {
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
                LSSharedFileListItemRemove(loginItemsList, nextLoginItem)
                job.result = "Removed login item: \(path)"
                job.completed = true
                job.success = true
                return
            }
        }
    }
    

    // add new Login Item at the end of Login Items list
        job.result = "Failed to remove login item \(path)"
        job.completed = true
        job.success = false
        job.status = "error"
}
