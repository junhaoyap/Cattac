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
    private var milkSoundPlayer: AVAudioPlayer!
    private var ballSoundPlayer: AVAudioPlayer!
    private var poopArmSoundPlayer: AVAudioPlayer!
    private var fartSoundPlayer: AVAudioPlayer!
    private var puiSoundPlayer: AVAudioPlayer!
    private var poopSoundPlayer: AVAudioPlayer!
    private var nukeSoundPlayer: AVAudioPlayer!
    
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
        
        // Milk
        let milkSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("milk", ofType: "wav")!)
        
        milkSoundPlayer = AVAudioPlayer(
            contentsOfURL: milkSoundFile, error: nil
        )
        
        milkSoundPlayer.numberOfLoops = 0
        milkSoundPlayer.prepareToPlay()
        
        // Ball
        let ballSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("ball", ofType: "aiff")!)
        
        ballSoundPlayer = AVAudioPlayer(
            contentsOfURL: ballSoundFile, error: nil
        )
        
        ballSoundPlayer.numberOfLoops = 0
        ballSoundPlayer.prepareToPlay()
        
        // Pooparm
        let poopArmSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("poopArm", ofType: "wav")!)
        
        poopArmSoundPlayer = AVAudioPlayer(
            contentsOfURL: poopArmSoundFile, error: nil
        )
        
        poopArmSoundPlayer.volume = 0.05
        poopArmSoundPlayer.numberOfLoops = 0
        poopArmSoundPlayer.prepareToPlay()
        
        // Fart
        let fartSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("fart", ofType: "wav")!)
        
        fartSoundPlayer = AVAudioPlayer(
            contentsOfURL: fartSoundFile, error: nil
        )
        
        fartSoundPlayer.volume = 0.5
        fartSoundPlayer.numberOfLoops = 0
        fartSoundPlayer.prepareToPlay()
        
        // Pui
        let puiSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("pui", ofType: "wav")!)
        
        puiSoundPlayer = AVAudioPlayer(
            contentsOfURL: puiSoundFile, error: nil
        )
        
        puiSoundPlayer.numberOfLoops = 0
        puiSoundPlayer.prepareToPlay()
        
        // Poop
        let poopSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("poop", ofType: "wav")!)
        
        poopSoundPlayer = AVAudioPlayer(
            contentsOfURL: poopSoundFile, error: nil
        )
        
        poopSoundPlayer.numberOfLoops = 0
        poopSoundPlayer.prepareToPlay()
        
        // Nuke
        let nukeSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("nuke", ofType: "wav")!)
        
        nukeSoundPlayer = AVAudioPlayer(
            contentsOfURL: nukeSoundFile, error: nil
        )
        
        nukeSoundPlayer.numberOfLoops = 0
        nukeSoundPlayer.prepareToPlay()
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
    
    func playMilk() {
        milkSoundPlayer.play()
    }
    
    func playBall() {
        ballSoundPlayer.play()
    }
    
    func playPoopArm() {
        poopArmSoundPlayer.play()
    }
    
    func playFart() {
        fartSoundPlayer.play()
    }
    
    func playPui() {
        puiSoundPlayer.play()
    }
    
    func playPoop() {
        poopSoundPlayer.play()
    }
    
    func playNuke() {
        nukeSoundPlayer.play()
    }
}