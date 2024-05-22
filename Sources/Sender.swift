//
//  Sender.swift
//  SwiftConcurrencyCLI
//
//  Created by Charles Roth on 2024-05-22.
//

import Foundation

enum SendEmailResult {
    case sent(email: String)
    case failed(email: String)
}

@available(macOS 10.15, *)
func sendEmail(to email: String) async throws -> SendEmailResult {
    if email == "konnichiwa@world.com" {
        return SendEmailResult.failed(email: email)
    }
    
    try await Task.sleep(nanoseconds: UInt64(3 * Double(NSEC_PER_SEC)))
    print("Email to \(email) sent")
    return SendEmailResult.sent(email: email)
}

@available(macOS 10.15, *)
func notify(emails : [String]) async throws -> [SendEmailResult] {
    return try await withThrowingTaskGroup(of: SendEmailResult.self) { taskGroup in
        for email in emails {
            taskGroup.addTask {
                try await sendEmail(to: email)
            }
        }
        
        return try await taskGroup.reduce(into: []) { results, result in
            results.append(result)
        }
    }
    
}
