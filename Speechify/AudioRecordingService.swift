//
//  AudioRecordingService.swift
//  Speechify
//
//  Created by Olorunshola Godwin on 23/01/2021.
//

import Foundation
import AVFoundation

class AudioRecordingService: NSObject, AVAudioRecorderDelegate {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    var audioRecorderController = AudioRecorderConfigurationController()
    
    var recordedAudioFileURL: AnyPublisher<URL, Never> {
        return _recordedAudioFileURL.eraseToAnyPublisher()
    }
    var isRecordingState: AnyPublisher<Bool, Never> {
        return _isRecordingState.eraseToAnyPublisher()
    }
    
    private let _isRecordingState = PassthroughSubject<Bool, Never>()
    private let _recordedAudioFileURL = PassthroughSubject<URL, Never>()

    private var subscribers = Set<AnyCancellable>()

    override init() {
        audioRecorderController.checkAudioRecorderPermission()
    }
    
    func startStopAudioRecording() {
        if let _ = audioRecorder {
            stopAudioRecording()
        } else {
          startAudioRecording()
        }
    }
    
    func startAudioRecording() {
        audioRecorder = audioRecorderController.setUpRecorder()
        _isRecordingState.send(true)
        audioRecorder?.delegate = self
        audioRecorder?.record()
    }
    
    func stopAudioRecording() {
        audioRecorder?.stop()
//        try? audioRecorderController.audioRecordingSession.setActive(false)
        audioRecorder = nil
        _isRecordingState.send(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            _recordedAudioFileURL.send(recorder.url)
        } else {
            recorder.stop()
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print(error)
    }
}


import Combine
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
