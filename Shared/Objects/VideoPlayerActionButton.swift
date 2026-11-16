//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2026 Jellyfin & Jellyfin Contributors
//

import Defaults

enum VideoPlayerActionButton: String, CaseIterable, Displayable, Equatable, Identifiable, Storable, SystemImageable {

    case aspectFill
    case audio
    case audioOffset
    case autoPlay
    case pictureInPicture
    case playbackSpeed
    case playbackSettings
    case playNextItem
    case playPreviousItem
    case nextChapter
    case previousChapter
    case sleepTimer
    case subtitles
    #if os(iOS)
    case gestureLock
    case playbackDestination
    #endif
    case subtitleOffset

    var displayTitle: String {
        switch self {
        case .aspectFill:
            L10n.aspectFill
        case .audio:
            L10n.audio
        case .audioOffset:
            L10n.audioOffset
        case .autoPlay:
            L10n.autoPlay
        case .pictureInPicture:
            L10n.pictureInPicture
        case .playbackSpeed:
            L10n.playbackSpeed
        case .playbackSettings:
            L10n.playback
        case .playNextItem:
            L10n.playNextItem
        case .playPreviousItem:
            L10n.playPreviousItem
        case .nextChapter:
            L10n.nextChapter
        case .previousChapter:
            L10n.previousChapter
        case .sleepTimer:
            L10n.sleepTimer
        case .subtitles:
            L10n.subtitles
        #if os(iOS)
        case .gestureLock:
            L10n.gestureLock
        case .playbackDestination:
            L10n.cast
        #endif
        case .subtitleOffset:
            L10n.subtitleOffset
        }
    }

    var id: String {
        rawValue
    }

    #if os(tvOS)
    var systemImage: String {
        switch self {
        case .aspectFill: "arrow.up.left.and.arrow.down.right"
        case .audio: "speaker.wave.2"
        case .audioOffset: "waveform.path"
        case .autoPlay: "play.fill"
        case .pictureInPicture: "pip.enter"
        case .playbackSpeed: "speedometer"
        case .playbackSettings: "tv"
        case .playNextItem: "forward.end.fill"
        case .playPreviousItem: "backward.end.fill"
        case .nextChapter: "forward.frame.fill"
        case .previousChapter: "backward.frame.fill"
        case .sleepTimer: "moon.zzz"
        case .subtitles: "captions.bubble.fill"
        case .subtitleOffset: "textformat.abc"
        }
    }

    var secondarySystemImage: String {
        switch self {
        case .aspectFill: "arrow.down.right.and.arrow.up.left"
        case .audio: "speaker.wave.2"
        case .autoPlay: "stop.fill"
        case .pictureInPicture: "pip.exit"
        case .sleepTimer: "moon.zzz.fill"
        case .subtitles: "captions.bubble"
        default:
            systemImage
        }
    }
    #else
    var systemImage: String {
        let usesLiquidGlassSymbols = if #available(iOS 26.0, *) {
            true
        } else {
            false
        }

        return switch self {
        case .aspectFill: "arrow.up.left.and.arrow.down.right"
        case .audio: "speaker.wave.2.fill"
        case .audioOffset: "waveform.path"
        case .autoPlay: usesLiquidGlassSymbols ? "play.fill" : "play.circle.fill"
        case .playbackDestination: "airplayvideo"
        case .gestureLock: usesLiquidGlassSymbols ? "lock.fill" : "lock.circle.fill"
        case .pictureInPicture: "pip.enter"
        case .playbackSpeed: "speedometer"
        case .playbackSettings: usesLiquidGlassSymbols ? "tv" : "tv.circle.fill"
        case .playNextItem: usesLiquidGlassSymbols ? "forward.end.fill" : "forward.end.circle.fill"
        case .playPreviousItem: usesLiquidGlassSymbols ? "backward.end.fill" : "backward.end.circle.fill"
        case .nextChapter: usesLiquidGlassSymbols ? "forward.frame.fill" : "forward.frame"
        case .previousChapter: usesLiquidGlassSymbols ? "backward.frame.fill" : "backward.frame"
        case .sleepTimer: "moon.zzz"
        case .subtitles: "captions.bubble.fill"
        case .subtitleOffset: "textformat.abc"
        }
    }

    var secondarySystemImage: String {
        switch self {
        case .aspectFill: "arrow.down.right.and.arrow.up.left"

        case .audio: "speaker.wave.2"

        case .autoPlay:
            if #available(iOS 26.0, *) {
                "stop"
            } else {
                "stop.circle"
            }

        case .gestureLock: "lock.open.fill"

        case .pictureInPicture: "pip.exit"

        case .sleepTimer: "moon.zzz.fill"

        case .subtitles: "captions.bubble"

        default:
            systemImage
        }
    }
    #endif

    static var supportedCases: [Self] {
        #if os(iOS)
        allCases.filter { $0 != .playbackDestination || Defaults[.Experimental.chromecast] }
        #elseif os(tvOS)
        allCases.filter { $0 != .pictureInPicture }
        #else
        allCases
        #endif
    }

    static let defaultBarActionButtons: [VideoPlayerActionButton] = {
        var buttons: [VideoPlayerActionButton] = [
            .aspectFill,
            .autoPlay,
            .playPreviousItem,
            .playNextItem,
        ]
        #if os(iOS)
        buttons.append(.playbackDestination)
        #endif
        return buttons
    }()

    static let defaultMenuActionButtons: [VideoPlayerActionButton] = [
        .audio,
        .audioOffset,
        .subtitles,
        .subtitleOffset,
        .playbackSpeed,
        .sleepTimer,
        .pictureInPicture,
        .playbackSettings,
    ].filter { supportedCases.contains($0) }
}

// MARK: - Defaults bridge

extension VideoPlayerActionButton {

    /// Persists the button selection as plain raw values.
    ///
    /// The enum conforms to both `Codable` and `RawRepresentable`, so the
    /// Defaults library would otherwise serialize it through its ambiguous
    /// JSON `Codable` bridge. `ArrayBridge` silently drops any element that
    /// fails to decode, so a stored value written in a format the current
    /// decode doesn't recognize loses that button from the preference with
    /// no warning. Storing plain raw values is the stable format; the
    /// legacy JSON format (a quoted raw value, e.g. `"\"nextChapter\""`) is
    /// still accepted on read so pins made before this change survive.
    struct DefaultsBridge: Defaults.Bridge {

        typealias Value = VideoPlayerActionButton
        typealias Serializable = String

        func serialize(_ value: Value?) -> String? {
            value?.rawValue
        }

        func deserialize(_ object: String?) -> Value? {
            guard let object else { return nil }

            if let value = Value(rawValue: object) {
                return value
            }

            // Legacy JSON format: the raw value wrapped in quotes.
            if object.count >= 2, object.hasPrefix("\""), object.hasSuffix("\"") {
                return Value(rawValue: String(object.dropFirst().dropLast()))
            }

            return nil
        }
    }

    static var bridge: DefaultsBridge { DefaultsBridge() }
}
