//
//  DataAnalyzer.swift
//  Step Tracker
//
//  Created by Arseny Prostakov on 10/11/2025.
//

import Foundation
import FoundationModels
import Playgrounds

@available(iOS 26, *)
@Observable
final class DataAnalyzer {
    static let shared = DataAnalyzer()
    let model: SystemLanguageModel = .default
    
    private init() {
        
    }
}

@available(iOS 26, *)
#Playground {
    let session = LanguageModelSession()
    
    let prompt = "What are the number of recommended steps per day for a 30 year old male?"
    do {
        let response = try await session.respond(to: prompt)
        print(response.content)
    } catch {
        print(error)
    }
}
