//
//  jxa_call.swift
//  Hermes
//
//  Created by Justin Bui on 8/6/21.
//

import Foundation
import OSAKit

func jxa_call(job: Job){
    do {
        // Convert json to source and destination
        let jsonParameters = try JSON(data: toData(string: job.parameters))
        let jxaCode = jsonParameters["command"].stringValue
        
        // Append jxaCode to script in memory
        let combinedCode = toString(data: fromBase64(data: jxaScript)) + "\n" + jxaCode
        
        // https://stackoverflow.com/questions/44209057/how-can-i-run-jxa-from-swift
        let script = OSAScript.init(source: combinedCode, language: OSALanguage.init(forName: "JavaScript"));
        var compileError : NSDictionary?
        script.compileAndReturnError(&compileError)
        if let compileError = compileError {
            job.result = "Compile Error: \(compileError)"
            job.completed = true
            job.success = false
            job.status = "error"
        }
        var scriptError : NSDictionary?
        let result = script.executeAndReturnError(&scriptError)
        if let scriptError = scriptError {
            job.result = "Script Error: \(scriptError)"
            job.completed = true
            job.success = false
            job.status = "error"
        }
        else if let result = result?.stringValue {
            job.result = result
        }
        
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
