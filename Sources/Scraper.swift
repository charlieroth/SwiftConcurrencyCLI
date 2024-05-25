//
//  Scraper.swift
//  SwiftConcurrencyCLI
//
//  Created by Charles Roth on 2024-05-22.
//

import Foundation

func online(url: String) async throws -> Bool {
    try await work()
    let isOnline = [true, true, true, true, false].randomElement()!
    if isOnline == false {
        print("\(url) is offline")
    }
    
    return isOnline
}

func work() async throws -> Void {
    let randomSeconds = Int.random(in: 1...5)
    try await Task.sleep(for: .seconds(randomSeconds))
}

actor PageProducer {
    var pages: [String]
    
    init() {
        self.pages = []
        print("PageProducer init")
    }
    
    func produce(pages: [String]) -> Void {
        self.pages.append(contentsOf: pages)
    }
    
    func request(numPages: Int) -> [String] {
        print("PageProducer received request for \(numPages) pages")
        if self.pages.count == 0 {
            return self.pages
        }
        
        // Return all pages, reset the pages property
        if numPages >= pages.count {
            var requestedPages: [String] = []
            while !self.pages.isEmpty {
                let page = self.pages.removeFirst()
                requestedPages.append(page)
            }
            return requestedPages
        }
        
        var requestedPages: [String] = []
        for _ in 0..<numPages {
            let page = self.pages.removeFirst()
            requestedPages.append(page)
        }
        return requestedPages
    }
}

actor PageConsumer {
    var demand: Int
    
    init(demand: Int = 3) {
        print("PageConsumer init")
        self.demand = demand
    }
    
    func consume(pages: [String]) async throws {
        print("PageConsumer received: \(pages)")
        // Do "work" for each page
        for page in pages {
            print("scraping \(page)")
            try await work()
        }
    }
}

//actor PageConsumerSupervisor {
//    
//}
//
//actor OnlinePageProducerConsumer {
//    
//}
