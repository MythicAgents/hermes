//
//  exit.swift
//  Hermes
//
//  Created by Justin Bui on 6/6/21.
//

import Foundation

func exit(job: Job) {
    let randomInt = Int.random(in: 1..<5)
    
    switch randomInt {
    case 1:
        job.result = "Oh, you're going ... who will I make fun of now? Bye!"
    case 2:
        job.result = "Good luck finding better friends than me! Bye!"
    case 3:
        job.result = "Goodbye, don't cry! We won't!"
    case 4:
        job.result = "It will not be the same without you. It will actually be better!"
    default:
        job.result = "You'll never see this message. @slyd0g rulez!"
    }
    
    job.completed = true
    job.success = true
}
