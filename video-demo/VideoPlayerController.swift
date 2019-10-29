import UIKit
import AVKit
import AVFoundation
import MUXSDKStats

class VideoPlayerController: AVPlayerViewController {
    var video: Dictionary<String, String>! = nil
    var timeObserverToken: Any! = nil
    var playComplete: Any! = nil
    var controller: AVPlayerViewController! = nil

    let playName = "iOS AVPlayer"

    override func viewDidLoad() {
        super.viewDidLoad()

        let videoUrl = video["url"]!
        let url = URL(string: videoUrl)
        player = AVPlayer(url: url!)
//        player = AVPlayer()

        let cpd = MUXSDKCustomerPlayerData(environmentKey: "img");
        cpd?.playerName = "AVPlayer"
        cpd?.environmentKey = "cqtqt2jfbq235huvso0djbn56"
        let cvd = MUXSDKCustomerVideoData();
        cvd.videoIsLive = false;
        cvd.videoTitle = video["title"]!
        cvd.videoStreamType = "mp4"
//        let asset = AVAsset(url: url!)
//        player!.currentItem = AVPlayerItem(asset: asset)
        let _ = MUXSDKStats.monitorAVPlayerViewController(self, withPlayerName: playName, playerData: cpd!, videoData: cvd);
        timeObserverToken = player!.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5,
                                                                               preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                                           queue: DispatchQueue.main) { time in
                                                            let timeElapsed = Float(CMTimeGetSeconds(time))
                                                            print ("current time " + timeElapsed.description)
        }
        playComplete = NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        player!.play()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
////            MUXSDKStats.videoChange(forPlayer: self.playName, with: cvd)
//            let avPlayerItem = AVPlayerItem(url: url!)
//            self.player?.replaceCurrentItem(with: avPlayerItem)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        cleanUp()
        super.viewWillDisappear(animated)
    }

    func cleanUp() {
        player!.removeTimeObserver(timeObserverToken)
        NotificationCenter.default.removeObserver(playComplete)
        MUXSDKStats.destroyPlayer(playName);
        player = nil
    }
}
