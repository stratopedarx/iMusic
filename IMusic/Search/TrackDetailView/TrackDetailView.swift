//
//  TrackDetailView.swift
//  IMusic
//
//  Created by Sergey Lobanov on 01.11.2021.
//

import UIKit

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
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
        
        
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
    }
    
    @IBAction private func playPauseAction(_ sender: UIButton) {
    }

    @IBAction private func nextTrack(_ sender: UIButton) {
    }
    
}
