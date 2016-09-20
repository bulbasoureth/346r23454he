//
//  AppDelegate.swift
//  Neighbors
//
//  Created by Diana Chen on 3/1/16.
//  Copyright © 2016 Pocoa. All rights reserved.
//
import UIKit
import MediaPlayer

class PlayViewController: UIViewController, InteractivePlayerViewDelegate {
    
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet var playPauseButtonView: UIView!
    @IBOutlet weak var currentPlayTime: UILabel!
    // Actually this should be the total duration of the song, lazy to change the label name... :|
    @IBOutlet weak var playBackTime: UILabel!

    @IBOutlet var blurBgImage: UIImageView!
    @IBOutlet var ipv: InteractivePlayerView!
    @IBOutlet var containerView: UIView!
    // Create a variable for systemMusicPlayer instance
    var musicPlayer:MPMusicPlayerController = MPMusicPlayerController.systemMusicPlayer()
    // Create a variable for current playing song media item
    // This is used for showing the title and song image later
    var currentPlayingSong = MPMediaItem()
    
    var isPlay = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.clear
        self.makeImageBlurry(self.blurBgImage)
        self.makeItRounded(self.playPauseButtonView, newSize: self.playPauseButtonView.frame.width)
        
        self.ipv!.delegate = self
        
        // Notification
        let notificationCenter = NotificationCenter.default
        // Notification for playing
        notificationCenter.addObserver(self, selector: #selector(PlayViewController.handlePlayingItemChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
        // Notification for playState
        notificationCenter.addObserver(self, selector: #selector(PlayViewController.handlePlayState), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer)
        musicPlayer.beginGeneratingPlaybackNotifications()
        
        if (musicPlayer.playbackState == MPMusicPlaybackState.playing) {
            playButton.setTitle("Pause", for: UIControlState())
            self.isPlay = true
        }
        //duration
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            let playBack = formattedPlayTime(nowPlayingItem.playbackDuration)
        
        self.ipv.progress = playBack
        }
    }
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        self.ipv.start()
        self.playButton.isHidden = true
        self.pauseButton.isHidden = false
        // Start to play songs
        musicPlayer.play()
    }
    @IBAction func pauseButtonAction(_ sender: UIButton) {
        self.ipv.stop()
        musicPlayer.pause()
        self.playButton.isHidden = false
        self.pauseButton.isHidden = true
    }
    
    @IBAction func nextSongButtonAction(_ sender: UIButton) {
        
        musicPlayer.skipToNextItem()
    }
    
    @IBAction func preSongButtonAction(_ sender: UIButton) {
        
        musicPlayer.skipToPreviousItem()
        
    }
    
    // Setup Media Item Info
    func setupCurrentMediaItem() {
        
        // When the song can be played, means we can set the current playing song
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
        currentPlayingSong = nowPlayingItem
        }
        songNameLabel.text = currentPlayingSong.title
        
        // For getting the image needs a few steps, it cannot be directly getted from the item
        if let artWork = currentPlayingSong.artwork {
        songImageView.image = artWork.image(at: songImageView.bounds.size)
        }
        // Get Current Play Time for the song
        let currentPlayTimeInterval = musicPlayer.currentPlaybackTime
        let playTime = formattedPlayTime(currentPlayTimeInterval)
        currentPlayTime.text = playTime
        
        // Get song duration
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
        let playBack = formattedPlayTime(nowPlayingItem.playbackDuration)
        playBackTime.text = ((playBack as! Int)-(playTime as! Int)) as! String;
        }
        // Fror the rest song duration, you could use total - current Interval
        // Then can get what u want ~:)
        
        
        // Setup repeat mode to All
/**        if (musicPlayer.repeatMode != MPMusicRepeatMode.One || musicPlayer.repeatMode != MPMusicRepeatMode.None) {
            musicPlayer.repeatMode = MPMusicRepeatMode.All
            repeatOneSongButton.setTitle("Repeat One Song - All", forState: UIControlState.Normal)
        }
**/
    }
    
/**    @IBAction func changePlayModeButtonAction(sender: UIButton) {
        
        // MPMusicShuffleModeOff, MPMusicShuffleModeSongs, MPMusicShuffleModeAlbums
        if musicPlayer.shuffleMode == MPMusicShuffleMode.Off {
            musicPlayer.shuffleMode = MPMusicShuffleMode.Songs
            changePlayModeButton.setTitle("Shuffle", forState: UIControlState.Normal)
        } else {
            musicPlayer.shuffleMode = MPMusicShuffleMode.Off
            changePlayModeButton.setTitle("Mode", forState: UIControlState.Normal)
        }
        
    }**/
    
/**    @IBAction func repeatOneSongButtonAction(sender: UIButton) {
        
        // MPMusicRepeatModeOne, MPMusicRepeatModeAll
        if (musicPlayer.repeatMode == MPMusicRepeatMode.One) {
            musicPlayer.repeatMode = MPMusicRepeatMode.All
            repeatOneSongButton.setTitle("Repeat One Song - All", forState: UIControlState.Normal)
        } else if (musicPlayer.repeatMode == MPMusicRepeatMode.All) {
            musicPlayer.repeatMode = MPMusicRepeatMode.None
            repeatOneSongButton.setTitle("Repeat One Song - Off", forState: UIControlState.Normal)
        } else {
            musicPlayer.repeatMode = MPMusicRepeatMode.One
            repeatOneSongButton.setTitle("Repeat One Song - One", forState: UIControlState.Normal)
        }
    }
 **/
    
    @IBAction func songListButtonAction(_ sender: UIButton) {
        
        // For log testing
        //println("-> Playlist VC")
        
    }
    
    
    
    // As function name, no more explain :)
    func formattedPlayTime(_ playTimeInterval:TimeInterval) -> String {
        
        let min = String(format: "%.0f", floor(playTimeInterval / 60))
        
        let sec = String(format: "%02.0f", fmod(playTimeInterval, 60))
        
        let playTime = "\(min):\(sec)"
        
        return playTime
    }
    

    
    // MARK: - Notification handlers
    func handlePlayingItemChanged() {
        setupCurrentMediaItem()
    }
    
    func handlePlayState() {
        var playbackState = musicPlayer.playbackState
  
        // If delete "self.isPlay == true", the Demo player may cause error when first time running with "Play" button
        // So that I cannot trust "MPMusicPlaybackState.Playing", that's the reason I add the variable for trigger the playing state
        let pause = UIImage(named: "Pause");
        let play = UIImage(named:"Play");
        if (musicPlayer.playbackState == MPMusicPlaybackState.paused) {
            playButton.setImage(play, for: UIControlState())
            self.isPlay = false
        } else if (self.isPlay == true || musicPlayer.playbackState == MPMusicPlaybackState.playing) {
            playButton.setImage(pause, for: UIControlState())
            self.isPlay = true
        } else {
            playButton.setImage(play, for: UIControlState())
            self.isPlay = false
        }
        
    }
}
