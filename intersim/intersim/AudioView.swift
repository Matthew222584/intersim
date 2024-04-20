import SwiftUI
import AVFoundation
import Speech

struct AudioView: View {
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder!
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioURL: URL?
    var speechRecognizer = SpeechRecognizer()
    var didFinishRecording: ((URL, String) -> Void)?

    var body: some View {
        VStack {
            Button {
                if isRecording {
                    audioRecorder.stop()
                    speechRecognizer.stopTranscribing()
                    
                    if let url = audioURL {
                        didFinishRecording?(url, speechRecognizer.transcript)
                    }
                } else {
                    startRecording()
                    speechRecognizer.startTranscribing()
                }
                isRecording.toggle()
            } label: {
                isRecording ? Image(systemName: "stop.circle") : Image(systemName: "record.circle")
            }
            .imageScale(.medium)
        }
        .padding(EdgeInsets(top:10, leading:18, bottom:0, trailing:4))
        .navigationTitle("Audio Interview")
        .navigationBarTitleDisplayMode(.inline)
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
}
