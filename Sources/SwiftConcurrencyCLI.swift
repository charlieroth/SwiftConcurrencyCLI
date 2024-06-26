//
//  SwiftConcurrencyCLI.swift
//
//
//  Created by Charles Roth on 2024-05-22.
//

import Foundation
import AsyncAlgorithms

@main
struct SwiftConcurrencyCLI {
    static func main() async {
        // await sender()
        // try? await jobber(numJobs: 10, inspectEvery: .seconds(1))
        try? await scraper()
    }
    
    static func sender() async {
        do {
            let emails = [
                "hello@world.com",
                "hola@world.com",
                "konnichiwa@world.com",
                "bonjour@world.com"
            ]
            let notificationResults = try await notify(emails: emails)
            print(notificationResults)
        } catch {
            print(error)
        }
    }
    
    static func jobber(numJobs: Int, inspectEvery interval: Duration) async throws {
        let jobSupervisor = JobSupervisor()
        
        // Start some jobs
        for i in 0..<numJobs {
            if i == 5 {
                await jobSupervisor.startJob(workType: .doomed)
            } else {
                if i.isMultiple(of: 2) {
                    await jobSupervisor.startJob(workType: .good)
                } else {
                    await jobSupervisor.startJob(workType: .bad)
                }
            }
        }
        
        // Every `interval` seconds, query the running jobs
        var runningJobs = await jobSupervisor.running()
        while runningJobs.count > 0 {
            print("Running jobs: \(runningJobs)")
            try await Task.sleep(for: interval)
            runningJobs = await jobSupervisor.running()
        }
        
        // View final results
        print("~~~~ Final Job Results ~~~~")
        for (id, jobResult) in await jobSupervisor.jobs {
            print("[\(id)]: \(jobResult)")
        }
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    }
    
    static func scraper() async throws {
        let pageChannel = AsyncChannel<[String]>()
        let pageProducer
        let pageConsumer = PageConsumer()
        
        Task {
            for i in 1...5 {
                print("Scraping pages... \(i)")
                await pageChannel.send([
                    "https://google-\(i).com",
                    "https://x-\(i).com",
                    "https://facebook-\(i).com",
                    "https://openai-\(i).com",
                    "https://netflix-\(i).com",
                    "https://amazon-\(i).com",
                    "https://anthropic-\(i).ai",
                    "https://apple-\(i).com"
                ])
                try await Task.sleep(for: .seconds(5))
            }
        }
        
        for await pages in pageChannel {
            Task {
                try await pageConsumer.consume(pages: pages)
            }
        }
    }
}
