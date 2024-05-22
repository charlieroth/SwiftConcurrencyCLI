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
}
