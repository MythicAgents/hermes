//
//  list_tcc.swift
//  Hermes
//
//  Created by Justin Bui on 7/28/21.
//

import Foundation
import SQLite3

func listTCCDatabase(job: Job) {
    do {
        // Convert json to path
        let jsonParameters = try JSON(data: toData(string: job.parameters))
        var path = jsonParameters["db"].stringValue
        
        // Strip out quotes if they exist, concept from Apfell agent
        if (path.prefix(1) == "\"") {
            path.removeFirst()
            path.removeLast()
        }
        
        // Check if ~ to base search from user home directory
        if (path.prefix(1) == "~") {
            path = NSString(string: path).expandingTildeInPath
        }
        
        // Open db
        let fileURL = URL(fileURLWithPath: path)
        var db: OpaquePointer?
        guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
            sqlite3_close(db)
            db = nil
            
            job.result = "Exception caught: Could not open \(fileURL.path)"
            job.completed = true
            job.success = false
            job.status = "error"
            return
        }
        
        // Query schema
        var queryStatementString = "PRAGMA table_info(\"access\")"
        var queryStatement: OpaquePointer?
        if sqlite3_prepare_v2(
            db,
            queryStatementString,
            -1,
            &queryStatement,
            nil
        ) == SQLITE_OK {
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
                    return
                }
                let name = String(cString: queryResultCol1)
                job.result += "\(name) | "
            }
            job.result.removeLast()
            job.result.removeLast()
            job.result += "\n"
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            job.result = "Exception caught: \(errorMessage)"
            job.completed = true
            job.success = false
            job.status = "error"
            return
        }
        sqlite3_finalize(queryStatement)
        
        // Query access
        queryStatementString = "select * from access"
        if sqlite3_prepare_v2(
            db,
            queryStatementString,
            -1,
            &queryStatement,
            nil
        ) == SQLITE_OK {
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                var csreq: String
                var policy_id: String
                var indirect_object_identifier_type: String
                var indirect_object_code_identity: String
                var flags: String
                
                guard let queryService = sqlite3_column_text(queryStatement, 0) else {
                    return
                }
                guard let queryClient = sqlite3_column_text(queryStatement, 1) else {
                    return
                }
                guard let queryClientType = sqlite3_column_text(queryStatement, 2) else {
                    return
                }
                guard let queryAuthValue = sqlite3_column_text(queryStatement, 3) else {
                    return
                }
                guard let queryAuthReason = sqlite3_column_text(queryStatement, 4) else {
                    return
                }
                guard let queryAuthVersion = sqlite3_column_text(queryStatement, 5) else {
                    return
                }
                if let queryCsreq = sqlite3_column_blob(queryStatement, 6) {
                    let queryCsreqLength = sqlite3_column_bytes(queryStatement, 6)
                    let data = Data(bytes: queryCsreq, count: Int(queryCsreqLength))
                    csreq = toBase64(data: data)
                }
                else {
                    csreq = "<NULL>"
                }
                if let queryPolicyID = sqlite3_column_text(queryStatement, 7) {
                    policy_id = String(cString: queryPolicyID)
                }
                else {
                    policy_id = "<NULL>"
                }
                if let queryIndirectObjectIdentifierType = sqlite3_column_text(queryStatement, 8) {
                    indirect_object_identifier_type = String(cString: queryIndirectObjectIdentifierType)
                }
                else {
                    indirect_object_identifier_type = "<NULL>"
                }
                guard let queryIndirectObjectIdentifier = sqlite3_column_text(queryStatement, 9) else {
                    return
                }
                if let queryIndirectObjectCodeIdentity = sqlite3_column_blob(queryStatement, 10) {
                    let queryIndirectObjectCodeIdentityLength = sqlite3_column_bytes(queryStatement, 10)
                    let data = Data(bytes: queryIndirectObjectCodeIdentity, count: Int(queryIndirectObjectCodeIdentityLength))
                    indirect_object_code_identity = toBase64(data: data)
                }
                else {
                    indirect_object_code_identity = "<NULL>"
                }
                if let queryFlags = sqlite3_column_text(queryStatement, 11) {
                    flags = String(cString: queryFlags)
                }
                else {
                    flags = "<NULL>"
                }
                guard let queryLastModified = sqlite3_column_text(queryStatement, 12) else {
                    return
                }
                
                let service = String(cString: queryService)
                let client = String(cString: queryClient)
                
                var client_type = String(cString: queryClientType)
                if client_type == "0" {
                    client_type = "Bundle Identifier"
                }
                else if client_type == "1" {
                    client_type = "Absolute Path"
                }
                else {
                    client_type = "Unknown"
                }
                
                var auth_value = String(cString: queryAuthValue)
                if auth_value == "0" {
                    auth_value = "Access Denied"
                }
                else if auth_value == "1" {
                    auth_value = "Unknown"
                }
                else if auth_value == "2" {
                    auth_value = "Allowed"
                }
                else if auth_value == "3" {
                    auth_value = "Limited"
                }
                
                var auth_reason = String(cString: queryAuthReason)
                if auth_reason == "1" {
                    auth_reason = "Error"
                }
                else if auth_reason == "2" {
                    auth_reason = "User Content"
                }
                else if auth_reason == "3" {
                    auth_reason = "User Set"
                }
                else if auth_reason == "4" {
                    auth_reason = "System Set"
                }
                else if auth_reason == "5" {
                    auth_reason = "Service Policy"
                }
                else if auth_reason == "6" {
                    auth_reason = "MDM Policy"
                }
                else if auth_reason == "7" {
                    auth_reason = "Override Policy"
                }
                else if auth_reason == "8" {
                    auth_reason = "MIssing Usage String"
                }
                else if auth_reason == "9" {
                    auth_reason = "Prompt Timeout"
                }
                else if auth_reason == "10" {
                    auth_reason = "Preflight Unknown"
                }
                else if auth_reason == "11" {
                    auth_reason = "Entitled"
                }
                else if auth_reason == "12" {
                    auth_reason = "App Type Policy"
                }
                
                let auth_version = String(cString: queryAuthVersion)
                let indirect_object_identifier = String(cString: queryIndirectObjectIdentifier)
                
                var last_modified = String(cString: queryLastModified)
                let date = NSDate(timeIntervalSince1970: Double(last_modified) ?? 0.0)
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "MMM dd YYYY hh:mm a"
                last_modified = dayTimePeriodFormatter.string(from: date as Date)
                
                job.result += "\(service) | \(client) | \(client_type) | \(auth_value) | \(auth_reason) | \(auth_version) | \(csreq) | \(policy_id) | \(indirect_object_identifier_type) | \(indirect_object_identifier) | \(indirect_object_code_identity) | \(flags) | \(last_modified)\n"
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            job.result = "Exception caught: \(errorMessage)"
            job.completed = true
            job.success = false
            job.status = "error"
            return
        }
        sqlite3_finalize(queryStatement)
        job.completed = true
        job.success = true
    }
    catch {
        job.result = "Exception caught: \(error)"
        job.completed = true
        job.success = false
        job.status = "error"
    }
}
