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
    
    private var shouldPlay = true
    
    class var sharedInstance: SoundPlayer {
        return _soundPlayer
    }
    
    private init() {
        // Nyan
        let nyanCatSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("NyanCat", ofType: "wav")!)
        
        nyanCatSoundPlayer = try? AVAudioPlayer(
            contentsOfURL: nyanCatSoundFile)
        
        nyanCatSoundPlayer.numberOfLoops = 0
        nyanCatSoundPlayer.prepareToPlay()
        
        // Hello Kitty
        let helloKittySoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("HelloKitty", ofType: "wav")!)
        
        helloKittySoundPlayer = try? AVAudioPlayer(
            contentsOfURL: helloKittySoundFile)
        
        helloKittySoundPlayer.numberOfLoops = 0
        helloKittySoundPlayer.prepareToPlay()
        
        // Grumpy
        let grumpyCatSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("GrumpyCat", ofType: "wav")!)
        
        grumpyCatSoundPlayer = try? AVAudioPlayer(
            contentsOfURL: grumpyCatSoundFile)
        
        grumpyCatSoundPlayer.numberOfLoops = 0
        grumpyCatSoundPlayer.prepareToPlay()
        
        // Octo
        let octoCatSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("OctoCat", ofType: "wav")!)
        
        octoCatSoundPlayer = try? AVAudioPlayer(
            contentsOfURL: octoCatSoundFile)
        
        octoCatSoundPlayer.numberOfLoops = 0
        octoCatSoundPlayer.prepareToPlay()
        
        // Milk
        let milkSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("milk", ofType: "wav")!)
        
        milkSoundPlayer = try? AVAudioPlayer(
            contentsOfURL: milkSoundFile)
        
        milkSoundPlayer.numberOfLoops = 0
        milkSoundPlayer.prepareToPlay()
        
        // Ball
        let ballSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("ball", ofType: "aiff")!)
        
        ballSoundPlayer = try? AVAudioPlayer(
            contentsOfURL: ballSoundFile)
        
        ballSoundPlayer.numberOfLoops = 0
        ballSoundPlayer.prepareToPlay()
        
        // Pooparm
        let poopArmSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("poopArm", ofType: "wav")!)
        
        poopArmSoundPlayer = try? AVAudioPlayer(
            contentsOfURL: poopArmSoundFile)
        
        poopArmSoundPlayer.volume = 0.025
        poopArmSoundPlayer.numberOfLoops = 0
        poopArmSoundPlayer.prepareToPlay()
        
        // Fart
        let fartSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("fart", ofType: "wav")!)
        
        fartSoundPlayer = try? AVAudioPlayer(
            contentsOfURL: fartSoundFile)
        
        fartSoundPlayer.volume = 0.25
        fartSoundPlayer.numberOfLoops = 0
        fartSoundPlayer.prepareToPlay()
        
        // Pui
        let puiSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("pui", ofType: "wav")!)
        
        puiSoundPlayer = try? AVAudioPlayer(
            contentsOfURL: puiSoundFile)
        
        puiSoundPlayer.numberOfLoops = 0
        puiSoundPlayer.prepareToPlay()
        
        // Poop
        let poopSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("poop", ofType: "wav")!)
        
        poopSoundPlayer = try? AVAudioPlayer(
            contentsOfURL: poopSoundFile)
        
        poopSoundPlayer.numberOfLoops = 0
        poopSoundPlayer.prepareToPlay()
        
        // Nuke
        let nukeSoundFile = NSURL(fileURLWithPath: NSBundle.mainBundle()
            .pathForResource("nuke", ofType: "wav")!)
        
        nukeSoundPlayer = try? AVAudioPlayer(
            contentsOfURL: nukeSoundFile)
        
        nukeSoundPlayer.volume = 0.25
        nukeSoundPlayer.numberOfLoops = 0
        nukeSoundPlayer.prepareToPlay()
    }
    
    func playNyan() {
        if shouldPlay {
            nyanCatSoundPlayer.play()
        }
    }
    
    func playHelloKitty() {
        if shouldPlay {
            helloKittySoundPlayer.play()
        }
    }
    
    func playGrumpy() {
        if shouldPlay {
            grumpyCatSoundPlayer.play()
        }
    }
    
    func playOcto() {
        if shouldPlay {
            octoCatSoundPlayer.play()
        }
    }
    
    func playMilk() {
        if shouldPlay {
            milkSoundPlayer.play()
        }
    }
    
    func playBall() {
        if shouldPlay {
            ballSoundPlayer.play()
        }
    }
    
    func playPoopArm() {
        if shouldPlay {
            poopArmSoundPlayer.play()
        }
    }
    
    func playFart() {
        if shouldPlay {
            fartSoundPlayer.play()
        }
    }
    
    func playPui() {
        if shouldPlay {
            puiSoundPlayer.play()
        }
    }
    
    func playPoop() {
        if shouldPlay {
            poopSoundPlayer.play()
        }
    }
    
    func playNuke() {
        if shouldPlay {
            nukeSoundPlayer.play()
        }
    }
    
    func doPlaySound() {
        shouldPlay = true
    }
    
    func stopPlayingSound() {
        shouldPlay = false
    }
    
    func shouldPlaySound() -> Bool {
        return shouldPlay
    }
}