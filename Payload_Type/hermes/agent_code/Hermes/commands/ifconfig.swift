//
//  ifconfig.swift
//  Hermes
//
//  Created by Justin Bui on 8/6/21.
//

import Foundation

func ifconfig(job: Job) {
    let addresses = Host.current().addresses
    for address in addresses {
        job.result += address + "\n"
    }
    
    job.completed = true
    job.success = true
}
