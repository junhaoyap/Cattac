/*
    Music Player is for things such as background music / winning congratulatory
    music e.t.c
*/

import Foundation
import AVFoundation

private let _musicPlayer: MusicPlayer = MusicPlayer()

class MusicPlayer {
    private var nyanBackgroundMusicPlayer: AVAudioPlayer!
    
    class var sharedInstance: MusicPlayer {
        return _musicPlayer
    }
    
    private init() {
        let nyanBackgroundMusic = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("NyanBackgroundMusic", ofType: "mp3")!)
        
        nyanBackgroundMusicPlayer = AVAudioPlayer(
            contentsOfURL: nyanBackgroundMusic, error: nil
        )
        
        nyanBackgroundMusicPlayer.volume = 0.025
        nyanBackgroundMusicPlayer.numberOfLoops = -1
        nyanBackgroundMusicPlayer.prepareToPlay()
    }
    
    func playBackgroundMusic() {
        nyanBackgroundMusicPlayer.play()
    }
    
    func stopBackgroundMusic() {
        nyanBackgroundMusicPlayer.stop()
    }
}