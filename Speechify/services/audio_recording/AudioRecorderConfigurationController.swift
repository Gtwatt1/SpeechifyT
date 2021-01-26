//
//  AudioRecorderConfigurationController.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 25/01/2021.
//

import Foundation
import Combine
import AVFoundation

/**
 This class wouild be used to set up the Audio Recorder configurations.
 */
class AudioRecorderConfigurationController {
    
    var audioRecordingSession: AVAudioSession!
    var _audioRecorderPermissionState = PassthroughSubject<AVAudioSession.RecordPermission, Never>()
    var audioRecorderPermissionState: AnyPublisher<AVAudioSession.RecordPermission, Never> {
        return _audioRecorderPermissionState.eraseToAnyPublisher()
    }
    
    func checkAudioRecorderPermission() {
        audioRecordingSession = AVAudioSession.sharedInstance()
        
        do {
            try audioRecordingSession.setCategory(.playAndRecord, mode: .default)
            try audioRecordingSession.setActive(true)
            audioRecordingSession.requestRecordPermission() { [unowned self]  allowed in
                if allowed {
                    _audioRecorderPermissionState.send(.granted)
                } else {
                    _audioRecorderPermissionState.send(.denied)
                }
            }
        } catch {
            _audioRecorderPermissionState.send(.denied)
        }
    }
    
    
    func setUpRecorder() -> AVAudioRecorder? {
        let fileName = UUID().uuidString
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(fileName).caf")
        
        let settings = [
            AVEncoderBitRateKey: 16,
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        return try? AVAudioRecorder(url: audioFilename, settings: settings)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
