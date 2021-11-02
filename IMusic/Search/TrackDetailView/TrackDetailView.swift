//
//  TrackDetailView.swift
//  IMusic
//
//  Created by Sergey Lobanov on 01.11.2021.
//

import UIKit
import SDWebImage
import AVKit

class TrackDetailView: UIView {

    // Outlets
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var currentTimeSlider: UISlider!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var trackTitleLabel: UILabel!
    @IBOutlet private weak var authorTitleLabel: UILabel!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var volumeSlider: UISlider!
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        // что бы не было задержки при включении
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        trackImageView.backgroundColor = .gray
    }

    func set(viewModel: SearchViewModel.Cell) {
        trackTitleLabel.text = viewModel.trackName
        authorTitleLabel.text = viewModel.artistName
        playTrack(previewUrl: viewModel.previewUrl)
        
        // меняет в строке 100х100 на 600х600
        let string600 = viewModel.iconUrlString.replacingOccurrences(of: "100x100", with: "600x600")

        guard let url = URL(string: string600) else { return }
        trackImageView.sd_setImage(with: url, completed: nil)
    }
    
    private func playTrack(previewUrl: String?) {
        print("Try to play track: \(previewUrl ?? "No previewUrl")")
        
        guard let previewUrl = previewUrl else { return }
        guard let url = URL(string: previewUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    // Actions
    @IBAction private func dragDownButtonTapped(_ sender: UIButton) {
        // сворачиваем данное окошко с экрана
        self.removeFromSuperview()
    }
    
    @IBAction private func handleCurrentTimeSlider(_ sender: UISlider) {
    }
    
    
    @IBAction private func handleVolumeSlider(_ sender: UISlider) {
    }
    
    @IBAction private func previousTrack(_ sender: UIButton) {
        print("work")
    }
    
    @IBAction private func playPauseAction(_ sender: UIButton) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        } else {
            player.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        }
    }

    @IBAction private func nextTrack(_ sender: UIButton) {
    }
}
