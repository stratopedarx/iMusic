//
//  TrackDetailView.swift
//  IMusic
//
//  Created by Sergey Lobanov on 01.11.2021.
//

import UIKit
import SDWebImage
import AVKit

// изначально так использовали, но после мы захотели использовать этот протокол для structur-ы Library
//protocol TrackMovingDelegate: AnyObject {
//    func moveBackForPreviousTrack() -> SearchViewModel.Cell?
//    func moveForwardForNextTrack() -> SearchViewModel.Cell?
//}

// убрали AnyObject. Так же нам придется убрать слово `weak` var delegate: TrackMovingDelegate?
protocol TrackMovingDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell?
    func moveForwardForNextTrack() -> SearchViewModel.Cell?
}

class TrackDetailView: UIView {
    
    // MARK: - Static default values
    
    static let scale: CGFloat = 0.8
    static let defaultCornerRadius: CGFloat = 5
    static let defaulVolumeSliderValue: Float = 0.6
    static let pauseImage = UIImage(named: "pause")
    static let playImage = UIImage(named: "play")
    
    // MARK: - @IBOutlet maximized view
    
    @IBOutlet private weak var trackImageView: UIImageView!
    @IBOutlet private weak var currentTimeSlider: UISlider!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var trackTitleLabel: UILabel!
    @IBOutlet private weak var authorTitleLabel: UILabel!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var volumeSlider: UISlider!
    @IBOutlet weak var maximizedStackView: UIStackView!
    
    
    // MARK: - @IBOutlet minimized view
    @IBOutlet weak var miniTrackView: UIView!
    @IBOutlet private weak var miniGoForwardButton: UIButton!
    @IBOutlet private weak var miniTrackImageView: UIImageView!
    @IBOutlet private weak var miniTrackTitleLabel: UILabel!
    @IBOutlet private weak var miniPlayPauseButton: UIButton!
    
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        // что бы не было задержки при включении
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    // использовалось так, пока протокол был подписан под AnyObject
//    weak var delegate: TrackMovingDelegate?
    
    var delegate: TrackMovingDelegate?
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setInitScaleForImage()
        trackImageView.layer.cornerRadius = TrackDetailView.defaultCornerRadius
        
        // set init volume
        volumeSlider.value = TrackDetailView.defaulVolumeSliderValue
        player.volume = volumeSlider.value
        
        // уменьшаем размер кнопки
        miniPlayPauseButton.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        setupGestures()
    }
    
    // MARK: - Set function
    
    func set(viewModel: SearchViewModel.Cell) {
        // устанавливаем значения и для большого и для маленького экранов
        miniTrackTitleLabel.text = viewModel.trackName
        
        trackTitleLabel.text = viewModel.trackName
        authorTitleLabel.text = viewModel.artistName
        playTrack(previewUrl: viewModel.previewUrl)
        monitorStartTime()
        observePlayerCurrentTime()  // для обновления лейблов currentTime and durationTime
        
        // test case: открыли трек, поставили паузу, свернули, поставили новый трек и там была неверная кнопка.
        
        playPauseButton.setImage(TrackDetailView.pauseImage, for: .normal)
        miniPlayPauseButton.setImage(TrackDetailView.pauseImage, for: .normal)
        
        
        // меняет в строке 100х100 на 600х600
        let string600 = viewModel.iconUrlString.replacingOccurrences(of: "100x100", with: "600x600")
        
        guard let url = URL(string: string600) else { return }
        miniTrackImageView.sd_setImage(with: url, completed: nil)
        trackImageView.sd_setImage(with: url, completed: nil)
    }
    
    private func setupGestures() {
        // добавим жесты. Сначала добавим нажатие на экран. Только к miniTrackView
        miniTrackView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTapMaximized)))
        
        // теперь добавим жест оттягивания вверх плеера
        // UIPanGestureRecognizer. есть несколько состояний: 1.только нажали (начали), 2.изменяем (двигаем). 3.отпустили палец от экрана
        miniTrackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        
        // теперь добавим смахивание вниз большого экрана
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    // MAR: - @IBAction maximized view
    
    @IBAction private func dragDownButtonTapped(_ sender: UIButton) {
        // сворачиваем данное окошко с экрана анимированно
        // логика будет в MainTabBarController, а вызываться будет здесь. Поэтому используем протокол.
        self.tabBarDelegate?.minimizedTrackDetailController()
        //        self.removeFromSuperview()
    }
    
    // обрабатываем передвижение слайдера
    @IBAction private func handleCurrentTimeSlider(_ sender: UISlider) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    
    @IBAction private func handleVolumeSlider(_ sender: UISlider) {
        player.volume = volumeSlider.value
    }
    
    @IBAction private func previousTrack(_ sender: UIButton) {
        // список со всеми ячейками хранится в SearchViewController
        // есть несколько способов. 1) Через делегат (это самый правильный способ)
        // 2) Создавать отдельные комплишен блоки, которые откуда забирают и куда передают информацию.
        // Важно понять, что этот экран подгружается с помощью функции set в SearchViewController
        // должно быть что-то типа того: self.set(viewModel: следующаяЯчейка/предыдущая).
        // с помощью делегатов будем отправлять запрос в SearchViewController и в качестве ответа получим информацию по требуемой ячейке
        // 1. Создаем протокол TrackMovingDelegate
        // 2. Создаем объект этого делегата. weak var delegate: TrackMovingDelegate?
        // 3. В функциях previousTrack, nextTrack используем этот делегат
        // 4. Эти функции moveBackForPreviousTrack будут отрабатывать в SearchViewController
        // 5. Надо назначить делегата, что бы методы отрабатывали, потому что не понятно кто их должен выполнять.
        // trackDetailsView.delegate = self
        let cellViewModel = delegate?.moveBackForPreviousTrack()
        if let cellViewModel = cellViewModel {
            self.set(viewModel: cellViewModel)
        }
    }
    
    @IBAction private func nextTrack(_ sender: UIButton) {
        let cellViewModel = delegate?.moveForwardForNextTrack()
        if let cellViewModel = cellViewModel {
            self.set(viewModel: cellViewModel)
        }
    }
    
    @IBAction private func playPauseAction(_ sender: UIButton) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(TrackDetailView.pauseImage, for: .normal)
            miniPlayPauseButton.setImage(TrackDetailView.pauseImage, for: .normal)
            
            enlargeTrackImageView()
        } else {
            player.pause()
            playPauseButton.setImage(TrackDetailView.playImage, for: .normal)
            miniPlayPauseButton.setImage(TrackDetailView.playImage, for: .normal)
            reduceTrackImageView()
        }
    }
    
    // для объяснения почему не освобождался объект вызовем deinit
    // речь про метод: monitorStartTime
    deinit {
        print("track detail view memory reclaimed")
    }
}


// MARK: - Minimizing and Maximizing gestures

private extension TrackDetailView {
    @objc func handleTapMaximized() {
        print("tap tap tap")
        // передаем nil так как мы не открываем новую ячейку
        self.tabBarDelegate?.maximizedTrackDetailController(viewModel: nil)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            // тут ничего не меняет
            print("began")
        case .changed:
            print("changed")
            handlePanChanged(gesture: gesture)
        case .ended:
            print("ended")
            handlePanEnded(gesture: gesture)
        default:
            print("default")
        }
    }
    
    func handlePanChanged(gesture: UIPanGestureRecognizer) {
        // тут логика, наш миниконтроллер двигается либо вверх либо вниз
        // translationX = 0, потому что мы хотим двигать либо вверх, либо вниз
        
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        // меняет прозрачность большого и миниплеера
        let newAlpha = 1 + translation.y / 200
        self.miniTrackView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.maximizedStackView.alpha = -translation.y / 200
    }
    
    func handlePanEnded(gesture: UIPanGestureRecognizer) {
        // если палец двигается быстро, значит надо быстрее открыть или закрыть экран
        // translation - фиксирует место где находится наш палец
        let translation = gesture.translation(in: self.superview)
        // velocity - скорость. фиксирует скорость
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: AnimationConfig.withDuration,
                       delay: AnimationConfig.delay,
                       usingSpringWithDamping: AnimationConfig.usingSpringWithDamping,
                       initialSpringVelocity: AnimationConfig.initialSpringVelocity,
                       options: AnimationConfig.options,
                       animations: {
            self.transform = .identity  // делаем для того, что бы правильно открывался экран
            if translation.y < -200 || velocity.y < -500 {
                self.tabBarDelegate?.maximizedTrackDetailController(viewModel: nil)
            } else {
                self.miniTrackView.alpha = 1.0
                self.maximizedStackView.alpha = 0
            }
        },
                       completion: nil)
    }
    
    // сворачиваем большой экран
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            handleDismissalPanChanged(gesture: gesture)
        case .ended:
            handleDismissalPanEnded(gesture: gesture)
        default:
            print("default")
        }
    }
    
    private func handleDismissalPanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
    }
    
    private func handleDismissalPanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)

        UIView.animate(withDuration: AnimationConfig.withDuration,
                       delay: AnimationConfig.delay,
                       usingSpringWithDamping: AnimationConfig.usingSpringWithDamping,
                       initialSpringVelocity: AnimationConfig.initialSpringVelocity,
                       options: AnimationConfig.options,
                       animations: {
            self.maximizedStackView.transform = .identity
            if translation.y > 50 {
                self.tabBarDelegate?.minimizedTrackDetailController()
            }
            
        },
                       completion: nil
        )
        
        
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
                
                self.updateCurrentTimeSlider() // обновляем slider
            }
    }
    
    // логика для слайдера песни
    func updateCurrentTimeSlider() {
        // текущая отметка
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        // CMTimeMake(value: 1, timescale: 1) - это дефолтное значение
        // длина всей песни
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
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
