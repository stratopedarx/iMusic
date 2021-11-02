//
//  CMTime + Extension.swift
//  IMusic
//
//  Created by Sergey Lobanov on 02.11.2021.
//

import AVKit


// вспомогательная функция, которая конвертирует CMTime to String
extension CMTime {
    func toDisplayString() -> String {
        guard !CMTimeGetSeconds(self).isNaN else { return "" }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
        return timeFormatString
    }
}
