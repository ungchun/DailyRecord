//
//  SoundManager.swift
//  DailyRecord
//
//  Created by Kim SungHun on 1/15/25.
//

import AVFoundation

final class SoundManager {
  static let shared = SoundManager()
  
  private var audioPlayer: AVAudioPlayer?
  
  private init() {
    setupAudioSession()
  }
  
  // MARK: - Setup
  
  private func setupAudioSession() {
    do {
      try AVAudioSession.sharedInstance().setCategory(
        .playback,
        mode: .default,
        options: [.mixWithOthers]
      )
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      // 오디오 세션 설정 실패
    }
  }
  
  // MARK: - Public Methods
  
  /// 음악 재생 시작
  func play(fileName: String? = nil, fileExtension: String = "mp3") {
    let musicFileName: String
    if let fileName = fileName {
      musicFileName = fileName
    } else {
      musicFileName = UserDefaults.standard.string(
        forKey: "selectedMusicFileName"
      ) ?? "background_music_1"
    }
    
    // 이미 같은 음악이 재생 중이면 리턴
    if audioPlayer?.isPlaying == true,
       audioPlayer?.url?.lastPathComponent == "\(musicFileName).\(fileExtension)" {
      return
    }
    
    // 기존 재생 중지
    audioPlayer?.stop()
    audioPlayer = nil
    
    guard let url = Bundle.main.url(
      forResource: musicFileName,
      withExtension: fileExtension
    ) else {
      return
    }
    
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer?.numberOfLoops = -1
      audioPlayer?.volume = 0.3
      audioPlayer?.prepareToPlay()
      audioPlayer?.play()
    } catch {
      // 음악 재생 실패
    }
  }
  
  /// 음악 정지
  func stop() {
    audioPlayer?.stop()
    audioPlayer = nil
  }
  
  /// 일시 정지
  func pause() {
    audioPlayer?.pause()
  }
  
  /// 재개
  func resume() {
    audioPlayer?.play()
  }
  
  /// 볼륨 조절
  func setVolume(_ volume: Float) {
    audioPlayer?.volume = min(max(volume, 0.0), 1.0)
  }
  
  /// 재생 상태 확인
  var isPlaying: Bool {
    return audioPlayer?.isPlaying ?? false
  }
}
