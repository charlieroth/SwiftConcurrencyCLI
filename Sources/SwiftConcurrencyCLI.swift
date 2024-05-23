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
        try? await jobber(numJobs: 10, inspectEvery: .seconds(1))
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
        let jobber = Jobber(jobSupervisor: jobSupervisor)
        
        // Start supervisor to receive work
        Task {
            await jobSupervisor.start()
        }
        
        // Start some jobs
        for i in 0..<numJobs {
            if i == 5 {
                await jobber.startJob(workType: .doomed)
            } else {
                if i.isMultiple(of: 2) {
                    await jobber.startJob(workType: .good)
                } else {
                    await jobber.startJob(workType: .bad)
                }
            }
        }
        
        // Every `interval` seconds, query the running jobs
        var runningJobs = await jobber.running()
        while runningJobs.count > 0 {
            print("Running jobs: \(runningJobs)")
            try await Task.sleep(for: interval)
            runningJobs = await jobber.running()
        }
        
        // View final results
        print("~~~~ Final Job Results ~~~~")
        for (id, jobResult) in await jobSupervisor.jobs {
            print("[\(id)]: \(jobResult)")
        }
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    }
}
