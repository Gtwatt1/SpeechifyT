//
//  TranscriberService.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 24/01/2021.
//

import Foundation
import Combine

/**
 This class makes network call to Google Speech to text api to transcribe speech.
 */
class TranscriberApiService {
    
    func transcribeSpeech(recordedAudioURL: URL) -> AnyPublisher<GoogleSpeechToText.Transcription, TranscriptionError> {
        if let request = generateRequestData(recordedAudioURL: recordedAudioURL) {
            return URLSession.shared.dataTaskPublisher(for: request)
                .mapError{ (error) in
                    TranscriptionError.network(description: error.localizedDescription)
                }.tryMap{ result in
                    result.data
                }
                .decode(type: GoogleSpeechToText.Transcription.self, decoder: JSONDecoder())
                .mapError{ error in
                    .network(description: error.localizedDescription)
                }
                .eraseToAnyPublisher()
        }
        return Fail(error: .network(description: "Bad request")).eraseToAnyPublisher()
    }
    
}


extension TranscriberApiService {
    
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
    
    private func audioUrlToBase64String(recordedAudioURL: URL) -> String? {
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


