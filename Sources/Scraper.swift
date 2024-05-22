//
//  Scraper.swift
//  SwiftConcurrencyCLI
//
//  Created by Charles Roth on 2024-05-22.
//

import Foundation

@available(macOS 10.15, *)
func online(url: String) async throws -> Bool {
    try await work()
    let isOnline = [true, true, true, true, false].randomElement()!
    if isOnline == false {
        print("\(url) is offline")
    }
    
    return isOnline
}

@available(macOS 10.15, *)
func work() async throws -> Void {
    let randomSeconds = Int.random(in: 1...5)
    try await Task.sleep(nanoseconds: UInt64(Double(randomSeconds) * Double(NSEC_PER_SEC)))
}


actor PageProducer {
    func scrapePages(pages: [String]) -> Void {
        
    }
}

actor PageConsumer {
    
}

actor PageConsumerSupervisor {
    
}

actor OnlinePageProducerConsumer {
    
}
