import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicService {
  static final MusicService instance = MusicService._internal();
  MusicService._internal();

  final AudioPlayer _player = AudioPlayer();
  final List<String> _tracks = [
    'audio/nhac1.mp3',
    'audio/nhac2.mp3',
    'audio/nhac3.mp3',
    'audio/nhac4.mp3',
    'audio/nhac5.mp3',
    'audio/nhac6.mp3',
  ];

  // Mặc định luôn là TRUE (luôn phát nhạc khi khách quét mã vào app)
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<int> currentTrackIndexNotifier = ValueNotifier<int>(1);

  bool _isInitialized = false;
  bool _userExplicitlyMuted = false;
  bool _audioActuallyPlaying = false;
  int _currentIndex = 0;

  Source _resolveSource(String trackPath) {
    if (kIsWeb) {
      // Trên Flutter Web, assets được đóng gói tại assets/assets/
      return UrlSource('assets/assets/$trackPath');
    }
    return AssetSource(trackPath);
  }

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _player.onPlayerStateChanged.listen((state) {
      _audioActuallyPlaying = (state == PlayerState.playing);
      if (_userExplicitlyMuted) {
        isPlayingNotifier.value = false;
      } else {
        isPlayingNotifier.value = true;
      }
    });

    // Khi phát hết 1 bài, tự động chuyển ngẫu nhiên sang bài khác trong 6 bài
    _player.onPlayerComplete.listen((_) {
      if (!_userExplicitlyMuted && isPlayingNotifier.value) {
        playRandom();
      }
    });

    // Thử phát ngẫu nhiên 1 trong 6 bài
    await playRandom();
  }

  /// Phát ngẫu nhiên 1 trong 6 bài nhạc
  Future<void> playRandom() async {
    if (_userExplicitlyMuted) return;
    try {
      final rand = Random();
      int nextIndex;
      if (_tracks.length > 1) {
        do {
          nextIndex = rand.nextInt(_tracks.length);
        } while (nextIndex == _currentIndex);
      } else {
        nextIndex = 0;
      }
      _currentIndex = nextIndex;
      currentTrackIndexNotifier.value = _currentIndex + 1;

      final trackPath = _tracks[_currentIndex];
      await _player.stop();
      await _player.setVolume(0.7); // Âm lượng êm dịu chuẩn quán
      await _player.play(_resolveSource(trackPath));
      _audioActuallyPlaying = true;
      isPlayingNotifier.value = true;
    } catch (e) {
      if (kDebugMode) {
        print('Music autoplay waiting for user interaction: $e');
      }
      // Giữ cờ true để khi người dùng chạm màn hình là nhạc phát ngay
      isPlayingNotifier.value = true;
    }
  }

  /// Kích hoạt phát nhạc khi người dùng tương tác lần đầu (vượt qua Autoplay Policy của trình duyệt)
  Future<void> triggerOnUserInteraction() async {
    if (_userExplicitlyMuted || !isPlayingNotifier.value) return;
    if (!_audioActuallyPlaying) {
      try {
        if (_player.state == PlayerState.paused) {
          await _player.resume();
          _audioActuallyPlaying = true;
        } else {
          await playRandom();
        }
      } catch (_) {}
    }
  }

  /// Bật / Tắt nhạc theo ý muốn của khách hàng
  Future<bool> toggleMusic() async {
    try {
      if (isPlayingNotifier.value && _audioActuallyPlaying) {
        // Khách chủ động bấm TẮT nhạc
        _userExplicitlyMuted = true;
        await _player.pause();
        _audioActuallyPlaying = false;
        isPlayingNotifier.value = false;
        return false;
      } else {
        // Khách chủ động bấm BẬT lại nhạc
        _userExplicitlyMuted = false;
        isPlayingNotifier.value = true;
        if (_player.state == PlayerState.paused) {
          await _player.resume();
          _audioActuallyPlaying = true;
        } else {
          await playRandom();
        }
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling music: $e');
      }
      return false;
    }
  }

  void dispose() {
    _player.dispose();
  }
}
