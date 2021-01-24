//
//  TranscriberService.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 24/01/2021.
//

import Foundation
import Combine

class TranscriberService {
    
    func transcribeSpeech(recordedAudioURL: URL) throws -> AnyPublisher<Transcription, WeatherError> {
        if let request = generateRequestData(recordedAudioURL: recordedAudioURL) {
           return URLSession.shared.dataTaskPublisher(for: request)
            .mapError{ (error) in
                WeatherError.network(description: error.localizedDescription)
            }.tryMap{ result in
                return result.data
            }
            .decode(type: Transcription.self, decoder: JSONDecoder())
            .mapError{ error in
                WeatherError.network(description: error.localizedDescription)
            }
            .eraseToAnyPublisher()
        }
        throw WeatherError.network(description: "Bad request")
    }
    
}


extension TranscriberService {

    enum GoogleSpeechTextAPI {
        static let scheme = "https"
        static let host = "speech.googleapis.com"
        static let path = "/v1/speech:recognize"
        static let key = "<your key>"

        
        static let audioRequestConfig: [String: Any] =  [
            "encoding": "LINEAR16",
            "sampleRateHertz": 16000,
            "languageCode": "en-US",
            "enableWordTimeOffsets": false
        ]
    }
    
    private func makeGoogleTranscriberURLComponents() -> URLComponents {
      var components = URLComponents()
      components.scheme = GoogleSpeechTextAPI.scheme
      components.host = GoogleSpeechTextAPI.host
      components.path = GoogleSpeechTextAPI.path
        return components
    }
    
    func audioUrlToBase64String(recordedAudioURL: URL) -> String? {
        guard let data = try? Data(contentsOf: recordedAudioURL) else {
            return nil
        }
        return data.base64EncodedString()
    }
    
    private func generateRequestData(recordedAudioURL: URL) -> URLRequest? {
        let requestDictionary: [String: Any] = ["config": GoogleSpeechTextAPI.audioRequestConfig,
                                                "audio": audioUrlToBase64String(recordedAudioURL: recordedAudioURL) ?? ""]
        
        guard let requestData = try? JSONSerialization.data(withJSONObject: requestDictionary,
                                                            options: .sortedKeys) else {
            return nil
        }
        
        if let url = makeGoogleTranscriberURLComponents().url {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue( "Bearer \(GoogleSpeechTextAPI.key)", forHTTPHeaderField: "Authorization")
            request.httpBody = requestData
            request.httpMethod = "POST"
        }
        return nil
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
