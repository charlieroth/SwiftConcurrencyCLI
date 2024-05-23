//
//  SwiftConcurrencyCLI.swift
//
//
//  Created by Charles Roth on 2024-05-22.
//

import Foundation
import AsyncAlgorithms

@available(macOS 10.15, *)
@main
struct SwiftConcurrencyCLI {
    static func main() async {
        await jobber(for: .seconds(10))
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
    
    static func jobber(for duration: Duration) async {
        let channel = AsyncChannel<(String, JobStatus)>()
        let timer = AsyncTimerSequence(interval: .seconds(1), clock: .suspending)
        
        let t = Task {
            for await _ in timer {
                let randomJob = Int.random(in: 1...3)
                let randomMaxRetries = Int.random(in: 1...4)
                if randomJob == 1 {
                    _  = Job(
                        channel: channel,
                        id: randomId(),
                        maxRetries: randomMaxRetries,
                        work: goodJob
                    )
                } else if randomJob == 2 {
                    _  = Job(
                        channel: channel,
                        id: randomId(),
                        maxRetries: randomMaxRetries,
                        work: badJob
                    )
                } else {
                    _  = Job(
                        channel: channel,
                        id: randomId(),
                        maxRetries: randomMaxRetries,
                        work: doomedJob
                    )
                }
            }
        }
        
        Task {
            print("Begin!")
            try await Task.sleep(for: duration)
            print("Stop!")
            t.cancel()
            channel.finish()
        }
        
        for await (jobId, jobStatus) in channel {
            print("=== ID: \(jobId), Status: \(jobStatus)")
        }
        print("End!")
    }
}
