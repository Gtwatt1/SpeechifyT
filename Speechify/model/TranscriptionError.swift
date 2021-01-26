//
//  TranscriptionError.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 25/01/2021.
//

/**
 Errors that can be thrown while transcribing speech to text.
 */
import Foundation

enum TranscriptionError: Error {
    case parsing(description: String)
    case network(description: String)
}

extension TranscriptionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .network(let description),
             .parsing(let description):
            return description
        }
    }
}
