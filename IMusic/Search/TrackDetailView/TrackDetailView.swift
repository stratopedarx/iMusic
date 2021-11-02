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
    
    static let scale: CGFloat = 0.8
    
    // MARK: - @IBOutlet
    
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
        
        setInitScaleForImage()
        trackImageView.layer.cornerRadius = 5
    }
    
    func set(viewModel: SearchViewModel.Cell) {
        trackTitleLabel.text = viewModel.trackName
        authorTitleLabel.text = viewModel.artistName
        playTrack(previewUrl: viewModel.previewUrl)
        monitorStartTime()
        observePlayerCurrentTime()  // для обновления лейблов currentTime and durationTime
        
        // меняет в строке 100х100 на 600х600
        let string600 = viewModel.iconUrlString.replacingOccurrences(of: "100x100", with: "600x600")
        
        guard let url = URL(string: string600) else { return }
        trackImageView.sd_setImage(with: url, completed: nil)
    }
    
    // MARK: - @IBAction
    
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
            enlargeTrackImageView()
        } else {
            player.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            reduceTrackImageView()
        }
    }
    
    @IBAction private func nextTrack(_ sender: UIButton) {
    }
    
    // для объяснения почему не освобождался объект вызовем deinit
    // речь про метод: monitorStartTime
    deinit {
        print("track detail view memory reclaimed")
    }
}


// MARK: - Helpers

private extension TrackDetailView {
    func playTrack(previewUrl: String?) {
        print("Try to play track: \(previewUrl ?? "No previewUrl")")
        
        guard let previewUrl = previewUrl else { return }
        guard let url = URL(string: previewUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    // MARK: - Time setup
    
    // эту функцию мы сделали для того, что бы при включении трека,
    // картинка из маленького квадрата вырастала в большой квадрат в самом начале
    func monitorStartTime() {
        // свойство ниже отслеживает самый начальный момент времени
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(
            forTimes: times,
            queue: .main) { [weak self] in
                // отвечает за то какое действие делать, когда трек только начнет проигрываться
                // это выполняется в асинхронном потоке, и если не делать [weak self] то память не освобождается
                // и даже при сворачивании экрана музыка продолжит играть. Если включим новую песню, то два трека параллельно будет играть
                guard let self = self else { return }
                // теперь музыка будет выключаться, потому что экран уходит из памяти. deinit позволяет это проверить
                self.enlargeTrackImageView()
            }
    }
    
    func observePlayerCurrentTime() {
        // эта функция позволяет обновлять экран
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main) { [weak self] time in
                // тут указываем что делать каждую секунду
                guard let self = self else { return }
                self.currentTimeLabel.text = time.toDisplayString()
                
                let durationTime = self.player.currentItem?.duration // сколько секунд идет аудио файл
                // отвечает за то сколько секунд осталось в текущий момент времени
                let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
                self.durationLabel.text = "-\(currentDurationText)"
        }
    }

    // MARK: - Animations

    // картинка будет отображаться не на весь экран
    func setInitScaleForImage() {
        trackImageView.transform = CGAffineTransform(scaleX: TrackDetailView.scale, y: TrackDetailView.scale)
    }

    func enlargeTrackImageView() {
        UIView.animate(withDuration: 1,  // сколько будет длиться данная анимация
                       delay: 0,  // без задержки
                       usingSpringWithDamping: 0.5,  // про резкость нашей анимации
                       initialSpringVelocity: 1,  //
                       options: .curveEaseOut,  // ускорение в каком нааправлении? с данным параметром ускорение под конец
                       animations: { self.trackImageView.transform = .identity },  // что делать во время анимации. в начальное состояние
                       completion: nil)  // никаих действий не делать после анимации
    }
    
    func reduceTrackImageView() {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: { self.setInitScaleForImage() },
                       completion: nil)
    }
}
