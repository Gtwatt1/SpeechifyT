//
//  TranscriptionError.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 25/01/2021.
//

import Foundation

/**
 Errors that can be thrown while transcribing speech to text.
 */
enum TranscriptionError: Error {
    case parsing(description: String)
    case network(description: String)
}
