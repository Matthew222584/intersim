//
//  QuestionView.swift
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

    var body: some View {
        VStack {
            if isPreviewReady, let previewLayer = videoRecorder.previewLayer {
                PreviewView(previewLayer: previewLayer)
            }
            
            Button {
                isRecording ? videoRecorder.stopRecording() : videoRecorder.startRecording()
                isRecording.toggle()
            } label: {
                Text(isRecording ? "Stop recording" : "Start recording")
            }
            .disabled(!isPreviewReady)
        }
        .onReceive(videoRecorder.$isSetupFinished) { isSetupFinished in
            if isSetupFinished {
                isPreviewReady = true
            }
        }
    }
}

class VideoRecorder: NSObject, AVCaptureFileOutputRecordingDelegate, ObservableObject {
    private var captureSession: AVCaptureSession?
    private let fileOutput = AVCaptureMovieFileOutput()
    private var outputFileURL: URL?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isSetupFinished = false
    
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
                let videoInput = try AVCaptureDeviceInput(device: frontCamera)
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                
                session.addInput(videoInput)
                session.addInput(audioInput)
                session.addOutput(self.fileOutput)

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
            self.outputFileURL = fileURL
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
}

struct PreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let screenBounds = UIScreen.main.bounds
        let previewWidth = screenBounds.width * 0.5
        let previewHeight = screenBounds.height * 0.5
        let centerX = screenBounds.width / 2
        let centerY = screenBounds.height / 2
        
        let view = UIView()
        view.frame.size = CGSize(width: previewWidth, height: previewHeight)
        previewLayer.frame = view.bounds
        previewLayer.position = CGPoint(x: centerX, y: centerY)
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
