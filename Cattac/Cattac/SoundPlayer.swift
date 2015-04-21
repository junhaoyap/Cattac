/*
    Sound Player is for playing sounds such as meow, shoot, fart or pui e.t.c.
*/

import Foundation
import AVFoundation

private let _soundPlayer: SoundPlayer = SoundPlayer()

class SoundPlayer {
    private var nyanCatSoundPlayer: AVAudioPlayer!
    private var helloKittySoundPlayer: AVAudioPlayer!
    private var grumpyCatSoundPlayer: AVAudioPlayer!
    private var octoCatSoundPlayer: AVAudioPlayer!
    
    class var sharedInstance: SoundPlayer {
        return _soundPlayer
    }
    
    private init() {
        // Nyan
        let nyanCatSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("NyanCat", ofType: "wav")!)
        
        nyanCatSoundPlayer = AVAudioPlayer(
            contentsOfURL: nyanCatSoundFile, error: nil
        )
        
        nyanCatSoundPlayer.numberOfLoops = 0
        nyanCatSoundPlayer.prepareToPlay()
        
        // Hello Kitty
        let helloKittySoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("HelloKitty", ofType: "wav")!)
        
        helloKittySoundPlayer = AVAudioPlayer(
            contentsOfURL: helloKittySoundFile, error: nil
        )
        
        helloKittySoundPlayer.numberOfLoops = 0
        helloKittySoundPlayer.prepareToPlay()
        
        // Grumpy
        let grumpyCatSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("GrumpyCat", ofType: "wav")!)
        
        grumpyCatSoundPlayer = AVAudioPlayer(
            contentsOfURL: grumpyCatSoundFile, error: nil
        )
        
        grumpyCatSoundPlayer.numberOfLoops = 0
        grumpyCatSoundPlayer.prepareToPlay()
        
        // Octo
        let octoCatSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("OctoCat", ofType: "wav")!)
        
        octoCatSoundPlayer = AVAudioPlayer(
            contentsOfURL: octoCatSoundFile, error: nil
        )
        
        octoCatSoundPlayer.numberOfLoops = 0
        octoCatSoundPlayer.prepareToPlay()
    }
    
    func playNyan() {
        nyanCatSoundPlayer.play()
    }
    
    func playHelloKitty() {
        helloKittySoundPlayer.play()
    }
    
    func playGrumpy() {
        grumpyCatSoundPlayer.play()
    }
    
    func playOcto() {
        octoCatSoundPlayer.play()
    }
}