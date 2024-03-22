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
            }) { Text(isRecording ? "Stop Recording" : "Start Recording") }
        }
        .padding(EdgeInsets(top:10, leading:18, bottom:0, trailing:4))
        .navigationTitle("Audio Interview")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL!)
            audioPlayer?.play()
            print("audio is playing")
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}
