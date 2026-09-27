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

  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> currentTrackIndexNotifier = ValueNotifier<int>(1);

  bool _isInitialized = false;
  bool _userExplicitlyMuted = false;
  int _currentIndex = 0;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _player.onPlayerStateChanged.listen((state) {
      isPlayingNotifier.value = (state == PlayerState.playing);
    });

    // Khi phát hết 1 bài, tự động chuyển ngẫu nhiên sang bài khác
    _player.onPlayerComplete.listen((_) {
      if (!_userExplicitlyMuted) {
        playRandom();
      }
    });

    // Chọn ngẫu nhiên 1 trong 6 bài và phát khi mở quán
    await playRandom();
  }

  /// Phát ngẫu nhiên 1 trong 6 bài nhạc
  Future<void> playRandom() async {
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
      await _player.setVolume(0.7); // Âm lượng êm dịu chuẩn quán ăn
      await _player.play(AssetSource(trackPath));
      isPlayingNotifier.value = true;
      _userExplicitlyMuted = false;
    } catch (e) {
      if (kDebugMode) {
        print('Music autoplay waiting for user interaction: $e');
      }
      isPlayingNotifier.value = false;
    }
  }

  /// Kích hoạt phát nhạc khi người dùng tương tác lần đầu (vượt qua Autoplay Policy của trình duyệt)
  Future<void> triggerOnUserInteraction() async {
    if (_userExplicitlyMuted) return;
    if (_player.state != PlayerState.playing) {
      try {
        await _player.resume();
        isPlayingNotifier.value = true;
      } catch (_) {
        await playRandom();
      }
    }
  }

  /// Bật / Tắt nhạc theo ý muốn của khách hàng
  Future<bool> toggleMusic() async {
    try {
      if (isPlayingNotifier.value) {
        await _player.pause();
        _userExplicitlyMuted = true;
        isPlayingNotifier.value = false;
        return false;
      } else {
        _userExplicitlyMuted = false;
        if (_player.state == PlayerState.paused) {
          await _player.resume();
        } else {
          await playRandom();
        }
        isPlayingNotifier.value = true;
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
