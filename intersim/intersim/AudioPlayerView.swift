//
//  AudioPlayerView.swift
//  swiftUIChatter
//
//  Created by Isley Sepulveda on 2/20/24.
//

// import Foundation
import SwiftUI
import Observation

@Observable
final class PlayerUIState {

    @ObservationIgnored var recHidden = false
    var recDisabled = false
    var recColor = Color(.systemBlue)
    var recIcon = Image(systemName: "largecircle.fill.circle") // initial value

    var playCtlDisabled = true

    var playDisabled = true
    var playIcon = Image(systemName: "play")

    var doneDisabled = false
    var doneIcon = Image(systemName: "square.and.arrow.up") // initial value
 
    private func reset() {
        recHidden = false
        recDisabled = false
        recColor = Color(.systemBlue)
        recIcon = Image(systemName: "largecircle.fill.circle") // initial value

        playCtlDisabled = true

        playDisabled = true
        playIcon = Image(systemName: "play")

        doneDisabled = false
        doneIcon = Image(systemName: "square.and.arrow.up") // initial value

    }
    
    private func playCtlEnabled(_ enabled: Bool) {
        playCtlDisabled = !enabled
    }
    
    private func playEnabled(_ enabled: Bool) {
        playIcon = Image(systemName: "play")
        playDisabled = !enabled
    }
    
    private func pauseEnabled(_ enabled: Bool) {
        playIcon = Image(systemName: "pause")
        playDisabled = !enabled
    }
    
    private func recEnabled() {
        recIcon = Image(systemName: "largecircle.fill.circle")
        recDisabled = false
        recColor = Color(.systemBlue)
    }
    
    func propagate(_ playerState: PlayerState) {
        switch (playerState) {
        case .start(.play):
            recHidden = true
            playEnabled(true)
            playCtlEnabled(false)
            doneIcon = Image(systemName: "xmark.square")
        case .start(.standby):
            if !recHidden { recEnabled() }
            playEnabled(true)
            playCtlEnabled(false)
            doneDisabled = false
        case .start(.record):
            // initial values already set up for record start mode.
            reset()
        case .recording:
            recIcon = Image(systemName: "stop.circle")
            recColor = Color(.systemRed)
            playEnabled(false)
            playCtlEnabled(false)
            doneDisabled = true
        case .paused:
            if !recHidden { recEnabled() }
            playIcon = Image(systemName: "play")
        case .playing:
            if !recHidden {
                recDisabled = true
                recColor = Color(.systemGray6)
            }
            pauseEnabled(true)
            playCtlEnabled(true)
        }
    }
}

struct AudioPlayerView: View {
    @Binding var isPresented: Bool
    var autoPlay = false
    @Environment(AudioPlayer.self) private var audioPlayer

    var body: some View {
        VStack {
            // view to be defined
            Spacer()
            HStack {
                StopButton()
                Spacer()
                RwndButton()
                Spacer()
                PlayButton()
                Spacer()
                FfwdButton()
                Spacer()
                DoneButton(isPresented: $isPresented)
            }
            Spacer()
            RecButton()
        }
        .onAppear {
            if autoPlay {
                audioPlayer.playTapped()
            }
        }
        .onDisappear {
            audioPlayer.doneTapped()
        }
    }
}

struct RecButton: View {
    @Environment(AudioPlayer.self) private var audioPlayer

    var body: some View {
        if audioPlayer.playerUIState.recHidden {
            // if Button not laid out despite hidden, SwiftUI will not leave empty space
            Button(action: { }) {
                audioPlayer.playerUIState.recIcon
                    .scaleEffect(3.5)
                    .padding(.bottom, 80)
            }
            .hidden()
        } else {
            Button {
                audioPlayer.recTapped()
            } label: {
                audioPlayer.playerUIState.recIcon
                    .scaleEffect(3.5)
                    .padding(.bottom, 80)
                    .foregroundColor(audioPlayer.playerUIState.recColor)
            }
            .disabled(audioPlayer.playerUIState.recDisabled)
        }
    }
}

struct DoneButton: View {
    @Binding var isPresented: Bool
    @Environment(AudioPlayer.self) private var audioPlayer
    
    var body: some View {
        Button {
            audioPlayer.doneTapped()
            isPresented.toggle()
        } label: {
            audioPlayer.playerUIState.doneIcon.scaleEffect(2.0).padding(.trailing, 40)
        }
        .disabled(audioPlayer.playerUIState.doneDisabled)
    }
}

struct StopButton: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    
    var body: some View {
        Button {
            audioPlayer.stopTapped()
        } label: {
            Image(systemName: "stop")
        }
        .disabled(audioPlayer.playerUIState.playCtlDisabled)
    }
}

struct RwndButton: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    
    var body: some View {
        Button {
            audioPlayer.rwndTapped()
        } label: {
            Image(systemName: "gobackward.10")
        }
        .disabled(audioPlayer.playerUIState.playCtlDisabled)
    }
}

struct FfwdButton: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    
    var body: some View {
        Button {
            audioPlayer.ffwdTapped()
        } label: {
            Image(systemName: "goforward.10")
        }
        .disabled(audioPlayer.playerUIState.playCtlDisabled)
    }
}

struct PlayButton: View {
    @Environment(AudioPlayer.self) private var audioPlayer
    
    var body: some View {
        Button {
            audioPlayer.playTapped()
        } label: {
            audioPlayer.playerUIState.playIcon.scaleEffect(2.0).padding(.trailing, 40)
        }
        .disabled(audioPlayer.playerUIState.playDisabled)
    }
}
