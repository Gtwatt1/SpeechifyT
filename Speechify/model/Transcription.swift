//
//  Transcription.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 25/01/2021.
//

/**
 This file contains struct mapping of google speech to text json response
 */
import Foundation

enum  GoogleSpeechToText {
    struct Transcription: Codable {
        let results: [Result]
    }
    
    struct Result: Codable {
        let alternatives: [Alternative]
    }
    
    struct Alternative: Codable {
        let transcript: String
        let confidence: Double
        let words: [Word]?
    }
    
    struct Word: Codable {
        let startTime: String
        let endTime: String
        let word: String
    }
}
