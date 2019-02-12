//
//  AudioPlayer.swift
//  AudioPlayer
//
//  Created by haruta yamada on 2019/02/02.
//  Copyright © 2019 teranyan. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

protocol MediaPlayerInputQueueProtocol {
    func setQueue(query: MPMediaQuery,firstPlayIndex: Int?, isPlay: Bool)
    func updateQueue(index: Int, isPlay: Bool)
}
protocol MediaPlayerOutputQueueProtocol {
    var queue: [MPMediaItem] { get }
    var queueCount: Int { get }
    var currentQueue: MPMediaItem? { get }
    var indexOfCurrentQueue: Int { get }
}
protocol MediaPlayerStateProtocol {
    var isPlay: Bool { get }
    var currentTime: TimeInterval { get }
    var maximumMediaItemDuration: TimeInterval { get }
}
protocol MediaPlayerControlProtocol {
    func play()
    func pause()
    func skipToNext()
    func skipToPrevious()
    func skipToItem(index: Int, isPlay: Bool)
    func seek(time: TimeInterval)
}
protocol MediaPlayerArtworkProtocol {
    var image: UIImage? { get }
    var title: String { get }
    var artist: String { get }
}

class AudioPlayer: MediaPlayerControlProtocol, MediaPlayerArtworkProtocol, MediaPlayerInputQueueProtocol , MediaPlayerOutputQueueProtocol, MediaPlayerStateProtocol {
    
    private(set) static var shared = AudioPlayer()
    
    var isPlay: Bool {
        return (self.player.playbackState == .playing)
    }
    
    var queue: [MPMediaItem] {
        return self.currentQuery?.items ?? []
    }
    
    var queueCount: Int {
        return self.currentQuery?.items?.count ?? 0
    }
    
    var currentQueue: MPMediaItem? {
        return self.player.nowPlayingItem
    }
    var indexOfCurrentQueue: Int {
        return self.player.indexOfNowPlayingItem
    }
    
    var currentTime: TimeInterval {
        return self.player.currentPlaybackTime
    }
    var maximumMediaItemDuration: TimeInterval {
        return self.player.nowPlayingItem?.playbackDuration ?? 0
    }
    
    var image: UIImage? {
        return self.player.nowPlayingItem?.artwork?.image(at: MPMediaItem.albamJacketSize)
    }
    
    var title: String {
        return self.player.nowPlayingItem?.title ?? ""
    }
    
    var artist: String {
        return self.player.nowPlayingItem?.artist ?? ""
    }
    
    
    private var currentQuery: MPMediaQuery? {
        didSet {
            if currentQuery != nil {
                self.player.setQueue(with: self.currentQuery!)
            }
        }
    }
    
    private var player: MPMusicPlayerApplicationController
    
    init() {
        self.player = MPMusicPlayerApplicationController.applicationQueuePlayer
    }
    
    func play() {
        DispatchQueue.main.async {
            if !self.player.isPreparedToPlay {
                self.player.prepareToPlay()
            }
            self.player.play()
        }
    }
    
    func pause() {
        self.player.pause()
    }
    
    func skipToItem(index: Int, isPlay: Bool) {
        self.player.pause()
        self.player.nowPlayingItem = self.currentQuery?.items?[index]
        self.player.currentPlaybackTime = 0
        if isPlay {
            self.player.play()
        }
    }
    
    func skipToNext() {
        self.player.skipToNextItem()
    }
    
    func skipToPrevious() {
        self.player.skipToPreviousItem()
    }
    
    func seek(time: TimeInterval) {
        self.player.currentPlaybackTime = time
    }
    func setQueue(query: MPMediaQuery, firstPlayIndex index: Int?, isPlay: Bool) {
        self.player.stop()
        self.player.currentPlaybackTime = 0
        self.setQuery(query: query)
        self.setPlayingItem(index: index)
        if isPlay {
            self.play()
        }
    }
    func updateQueue(index: Int, isPlay: Bool) {
        self.player.stop()
        self.player.nowPlayingItem = self.currentQuery?.items?[index]
        if isPlay {
            self.play()
        }
    }
    private func setQuery(query: MPMediaQuery) {
        guard self.currentQuery != query else {
            return
        }
        self.currentQuery = query
    }
    private func setPlayingItem(index: Int?) {
        guard let index = index, 0 ..< (self.currentQuery?.items?.count ?? 0) ~= index else {
            self.player.nowPlayingItem = self.currentQuery?.items?[0]
            return
        }
        self.player.nowPlayingItem = self.currentQuery?.items?[index]
    }
}
