//
//  Jobber.swift
//  StructuredConcurrency
//
//  Created by Charlie Roth on 2024-05-22.
//

import Foundation
import AsyncAlgorithms

func goodJob() async throws -> JobWorkResult {
    let randomSeconds = Int.random(in: 1...3)
    try await Task.sleep(for: .seconds(randomSeconds))
    return JobWorkResult.success
}

func badJob() async throws -> JobWorkResult {
    let randomSeconds = Int.random(in: 3...6)
    try await Task.sleep(for: .seconds(randomSeconds))
    return JobWorkResult.failure
}

func doomedJob() async throws -> JobWorkResult {
    try await Task.sleep(for: .seconds(1))
    throw JobWorkResultError.doomed
}

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

enum WorkType {
    case good
    case bad
    case doomed
}

enum JobStatus {
    case new
    case errored
    case retryLimitReached
    case failed
    case done
}

enum JobState {
    case inProgress(Task<JobStatus, Never>)
    case completed(JobStatus)
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
    
    func run() async -> JobStatus {
        print("[\(self.id)]: started")
        var tries: Int = 0
        while tries < self.maxRetries {
            tries += 1
            guard let workResult = try? await self.work() else {
                print("[\(self.id)]: failed")
                self.status = .failed
                return .failed
            }
            
            if workResult == .success {
                self.status = JobStatus.done
                print("[\(self.id)]: done")
                return .done
            } else if workResult == .failure {
                if self.status == .new {
                    self.status = .errored
                    print("[\(self.id)]: errored")
                } else if self.status == .errored {
                    print("[\(self.id)]: retry failed")
                }
            }
        }
        
        print("[\(self.id)]: retry limit reached")
        self.status = .retryLimitReached
        return .retryLimitReached
    }
}

actor JobSupervisor {
    var workChannel: AsyncChannel<WorkType>
    var jobs: [String:JobState]
    
    init() {
        self.jobs = [:]
        self.workChannel = AsyncChannel<WorkType>()
    }
    
    func start() async {
        for await workType in self.workChannel {
            let work = switch workType  {
            case .good:
                goodJob
            case .bad:
                badJob
            case .doomed:
                doomedJob
            }

            Task {
                let id = randomId()
                let job = Job(id: id, maxRetries: 3, work: work)
                let workTask = Task<JobStatus, Never> {
                    let status = await job.run()
                    return status
                }
                self.jobs[id] = JobState.inProgress(workTask)
                let taskResult = await workTask.value
                self.jobs[id] = JobState.completed(taskResult)
            }
        }
    }
}

struct Jobber {
    var jobSupervisor: JobSupervisor
    
    init(jobSupervisor: JobSupervisor) {
        self.jobSupervisor = jobSupervisor
    }
    
    func startJob(workType: WorkType) async {
        await self.jobSupervisor.workChannel.send(workType)
    }
    
    func running() async -> [String] {
        var runningJobs: [String] = []
        for (id, jobTask) in await self.jobSupervisor.jobs {
            if case JobState.inProgress(_) = jobTask {
                runningJobs.append(id)
            }
        }
        return runningJobs
    }
}
