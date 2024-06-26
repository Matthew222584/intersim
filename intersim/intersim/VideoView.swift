//
//  VideoView.swift
//  intersim
//
//  Created by Kyle on 4/1/24.
//

import SwiftUI
import AVFoundation
import Photos

struct VideoView: View {
    private var videoRecorder: VideoRecorder = VideoRecorder()
    @State private var isRecording = false
    @State private var isPreviewReady = false
    var speechRecognizer = SpeechRecognizer()
    var didFinishRecording: ((URL, String) -> Void)?
    
    init(didFinishRecording: ((URL, String) -> Void)? = nil) {
        self.didFinishRecording = didFinishRecording
    }
    
    var body: some View {
        VStack {
            if isPreviewReady, let previewLayer = videoRecorder.previewLayer {
                PreviewView(previewLayer: previewLayer)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 4)
                            .foregroundColor(.blue)
                    )
                    .clipShape(RoundedRectangle(cornerRadius:10))
            }
            Button {
                if isRecording {
                    speechRecognizer.stopTranscribing()
                    videoRecorder.stopRecording()
                } else {
                    speechRecognizer.startTranscribing()
                    videoRecorder.startRecording()
                }
                isRecording.toggle()
            } label: {
                Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                    .font(.system(size: 50))
                    .padding()
                    .foregroundColor(.red)
            }
            .disabled(!isPreviewReady)
        }
        .padding(EdgeInsets(top:10, leading:18, bottom:0, trailing:4))
        .navigationTitle("Video Interview")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(videoRecorder.$isSetupFinished) { isSetupFinished in
            if isSetupFinished {
                isPreviewReady = true
            }
        }
        .onReceive(videoRecorder.$videoURL) { videoURL in
            if let url = videoURL {
                didFinishRecording?(url, speechRecognizer.transcript)
            }
        }
        .onDisappear {
            videoRecorder.destroyCaptureSession()
        }
    }
}

class VideoRecorder: NSObject, AVCaptureFileOutputRecordingDelegate, ObservableObject {
    private var captureSession: AVCaptureSession?
    private let fileOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isSetupFinished = false
    @Published var videoURL: URL?

    override init() {
        super.init()
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                print("Error: Unable to access front camera")
                return
            }
            
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                print("Error: Unable to access audio device")
                return
            }

            do {
                let session = AVCaptureSession()
                session.addOutput(self.fileOutput)
                
                let videoInput = try AVCaptureDeviceInput(device: frontCamera)
                session.addInput(videoInput)
                
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                session.addInput(audioInput)

                self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
                self.previewLayer?.videoGravity = .resizeAspectFill
                
                self.captureSession = session
                session.startRunning()
                
                DispatchQueue.main.async {
                    self.isSetupFinished = true
                }
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func startRecording() {
        DispatchQueue.main.async {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
            self.fileOutput.startRecording(to: fileURL, recordingDelegate: self)
        }
    }

    func stopRecording() {
        DispatchQueue.main.async {
            self.fileOutput.stopRecording()
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            guard error == nil else {
                print("Error recording video: \(error!.localizedDescription)")
                return
            }
            self.videoURL = outputFileURL
            
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else { return }
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                } completionHandler: { success, error in
                    if success {
                        print("Video saved successfully")
                    } else if let error = error {
                        print("Error saving video: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func destroyCaptureSession() {
        captureSession?.stopRunning()
        captureSession = nil
        previewLayer = nil
    }
}

struct PreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    let borderWidth: CGFloat = 4
    
    func makeUIView(context: Context) -> UIView {
        let screenBounds = UIScreen.main.bounds
        let previewWidth = screenBounds.width
        let previewHeight = screenBounds.height
//        let centerX = screenBounds.width / 2
//        let centerY = screenBounds.height / 2
        
        let view = UIView()
        view.frame.size = CGSize(width: previewWidth, height: previewHeight)
        previewLayer.frame = view.bounds.insetBy(dx: borderWidth, dy: borderWidth)
        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.position = CGPoint(x: centerX, y: centerY)
        view.layer.addSublayer(previewLayer)
        
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = UIColor.blue.cgColor
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
//        if let previewLayer = uiView.layer.sublayers?.first(where: { $0 is AVCaptureVideoPreviewLayer
//        }) as? AVCaptureVideoPreviewLayer {
//            previewLayer.frame = uiView.bounds.insetBy(dx: borderWidth, dy: borderWidth)
//            previewLayer.position = CGPoint(
//                x: UIScreen.main.bounds.width / 2,
//                y: UIScreen.main.bounds.height / 2)
//        }
    }
}
