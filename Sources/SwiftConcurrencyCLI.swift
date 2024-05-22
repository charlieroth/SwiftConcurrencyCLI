//
//  SwiftConcurrencyCLI.swift
//
//
//  Created by Charles Roth on 2024-05-22.
//

import Foundation

@available(macOS 10.15, *)
@main
struct SwiftConcurrencyCLI {
    static func main() async {

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
    
    static func jobber() async {
        do {
            let jobSupervisor = JobSupervisor()
            try await jobSupervisor.startJob(maxRetries: 5, work: goodJob)
            try await jobSupervisor.startJob(maxRetries: 3, work: badJob)
            try await jobSupervisor.startJob(maxRetries: 4, work: badJob)
            try await jobSupervisor.startJob(maxRetries: 2, work: doomedJob)
            try await jobSupervisor.startJob(maxRetries: 1, work: goodJob)
    
            while (await jobSupervisor.finished() == false) {
                let runningJobs = await jobSupervisor.running()
                print("Running jobs: ", runningJobs)
                try await Task.sleep(nanoseconds: UInt64(0.3 * Double(NSEC_PER_SEC)))
            }
    
            let jobs = await jobSupervisor.jobs
            for (_, job) in jobs {
                print(await job.debug())
            }
        } catch {
            print(error)
        }
    }
}
