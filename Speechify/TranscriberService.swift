//
//  TranscriberService.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 24/01/2021.
//

import Foundation
import Combine

class TranscriberService {
    
    func transcribeSpeech(recordedAudioURL: URL) -> AnyPublisher<Transcription, WeatherError> {
        if let request = generateRequestData(recordedAudioURL: recordedAudioURL) {
            return URLSession.shared.dataTaskPublisher(for: request)
                .mapError{ (error) in
                    WeatherError.network(description: error.localizedDescription)
                }.tryMap{ result in
                    result.data
                }
                .decode(type: Transcription.self, decoder: JSONDecoder())
                .mapError{ error in
                    WeatherError.network(description: error.localizedDescription)
                }
                .eraseToAnyPublisher()
        }
        return Fail(error: WeatherError.network(description: "Bad request")).eraseToAnyPublisher()
    }
    
}


extension TranscriberService {
    
    enum GoogleSpeechTextAPI {
        static let scheme = "https"
        static let host = "speech.googleapis.com"
        static let path = "/v1/speech:recognize"
        static let key = "AIzaSyCu5SMafahwM_CGlJv-DWMtS64zEcw0F-4"
        
        
        static let audioRequestConfig: [String: Any] =  [
            "encoding": "LINEAR16",
            "sampleRateHertz": 16000,
            "languageCode": "en-US",
            "enableWordTimeOffsets": true
        ]
    }
    
    private func makeGoogleTranscriberURLComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = GoogleSpeechTextAPI.scheme
        components.host = GoogleSpeechTextAPI.host
        components.path = GoogleSpeechTextAPI.path
        
        components.queryItems = [
          URLQueryItem(name: "key", value: GoogleSpeechTextAPI.key)
        ]
        return components
    }
    
    func audioUrlToBase64String(recordedAudioURL: URL) -> String? {
        guard let data = try? Data(contentsOf: recordedAudioURL) else {
            return nil
        }
        return data.base64EncodedString()
    }
    
    private func generateRequestData(recordedAudioURL: URL) -> URLRequest? {
        let requestDictionary: [String: Any] = [
            "config": GoogleSpeechTextAPI.audioRequestConfig,
            "audio": ["content":audioUrlToBase64String(recordedAudioURL: recordedAudioURL) ?? ""]
        ]
        
        guard let requestData = try? JSONSerialization.data(withJSONObject: requestDictionary,
                                                            options: .sortedKeys) else {
            return nil
        }
        
        guard let url = makeGoogleTranscriberURLComponents().url else  {
            return nil
        }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = requestData
        request.httpMethod = "POST"
        return request
    }
}

enum WeatherError: Error {
    case parsing(description: String)
    case network(description: String)
}

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
