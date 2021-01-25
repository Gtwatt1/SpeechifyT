//
//  Transcription.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 25/01/2021.
//

import Foundation

struct Transcription: Codable {
    let results: [Result]
}

struct Result: Codable {
    let alternatives: [Alternative]
}

struct Alternative: Codable {
    let transcript: String
    let confidence: Double
}
