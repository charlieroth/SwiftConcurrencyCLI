//
//  Jobber.swift
//  StructuredConcurrency
//
//  Created by Charlie Roth on 2024-05-22.
//

import Foundation

func randomId() -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<12).map{ _ in letters.randomElement()! })
}

enum JobWorkResult {
    case success
    case failure
}

enum JobWorkResultError: Error {
    case doomed
}

enum JobStatus {
    case new
    case errored
    case failed
    case done
}

actor Job {
    var id: String
    var maxRetries: Int
    var status: JobStatus = .new
    var work: () async throws -> JobWorkResult
    
    init(id: String, maxRetries: Int, work: @escaping () async throws -> JobWorkResult) {
        self.work = work
        self.maxRetries = maxRetries
        self.id = id
    }
    
    func run() async {
        var tries: Int = 0
        while tries < self.maxRetries {
            tries += 1
            // If work throws an error, declare it failed and exit
            guard let workResult = try? await self.work() else {
                self.status = .failed
                return
            }
            
            if workResult == .success {
                self.status = JobStatus.done
                print("Job completed: \(self.id)")
                return
            } else if workResult == .failure {
                if self.status == .new {
                    self.status = .errored
                    print("Job errored: \(self.id)")
                } else if self.status == .errored {
                    print("Job retry failed: \(self.id)")
                }
            }
        }
        // If Job fails to succeed before maxRetries, declared it failed and exit
        self.status = .failed
    }
    
    func debug() -> String {
        return "id: \(id), status: \(status)"
    }
}

@available(macOS 10.15, *)
actor JobSupervisor {
    var jobs: [String:Job] = [:]
    
    func startJob(maxRetries: Int, work: @escaping () async throws -> JobWorkResult) throws -> Void {
        let id = randomId()
        let job = Job(id: id, maxRetries: maxRetries, work: work)
        self.jobs[id] = job
        Task.detached {
            await job.run()
        }
    }
    
    func finished() async -> Bool {
        var statuses: [JobStatus] = []

        for (_, job) in self.jobs {
            let status = await job.status
            statuses.append(status)
        }

        return statuses.allSatisfy { status in
            status == .done || status == .failed
        }
    }
    
    func running() async -> [(String, JobStatus)] {
        var jobs: [(String, JobStatus)] = []
        for (id, job) in self.jobs {
            let status = await job.status
            jobs.append((id, status))
        }
        return jobs
    }
}

@available(macOS 10.15, *)
func goodJob() async throws -> JobWorkResult {
    try await Task.sleep(nanoseconds: UInt64(4 * Double(NSEC_PER_SEC)))
    return JobWorkResult.success
}

@available(macOS 10.15, *)
func badJob() async throws -> JobWorkResult {
    try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
    return JobWorkResult.failure
}

@available(macOS 10.15, *)
func doomedJob() async throws -> JobWorkResult {
    try await Task.sleep(nanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))
    throw JobWorkResultError.doomed
}
