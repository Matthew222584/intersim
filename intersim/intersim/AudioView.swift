//
//  AudioView.swift
//  intersim
//
//  Created by Kyle on 3/21/24.
//

import SwiftUI
import AVFoundation

struct AudioView: View {
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder!
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioURL: URL?

    var body: some View {
        VStack {
            Button(action: {
                if isRecording {
                    audioRecorder.stop()
                    startPlayback()
                } else {
                    startRecording()
                }
                isRecording.toggle()
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
            }
        }
        .padding()
        .onAppear(perform: requestPermission)
    }

    func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied")
            }
        }
    }

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            let audioFilename = FileManager.default.temporaryDirectory.appendingPathComponent("recording.wav")
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ])
            audioRecorder.record()
            audioURL = audioFilename
        } catch {
            print("Error recording audio: \(error.localizedDescription)")
        }
    }

    func startPlayback() {
        print("audio is playing")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL!)
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}
