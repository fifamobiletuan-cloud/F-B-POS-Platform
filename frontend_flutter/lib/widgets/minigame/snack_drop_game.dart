import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DropItem {
  double x; // 0.0 -> 1.0
  double y; // 0.0 -> 1.0
  final double speed;
  final String assetPath;
  final String label;
  final int points;

  DropItem({
    required this.x,
    required this.y,
    required this.speed,
    required this.assetPath,
    required this.label,
    required this.points,
  });
}

class FloatingScore {
  final double x;
  final double y;
  final String text;
  double opacity;

  FloatingScore({
    required this.x,
    required this.y,
    required this.text,
    this.opacity = 1.0,
  });
}

class SnackDropGame extends StatefulWidget {
  final VoidCallback onFinishAndOpenWheel;
  final VoidCallback onBackToHub;

  const SnackDropGame({
    super.key,
    required this.onFinishAndOpenWheel,
    required this.onBackToHub,
  });

  @override
  State<SnackDropGame> createState() => _SnackDropGameState();
}

class _SnackDropGameState extends State<SnackDropGame>
    with SingleTickerProviderStateMixin {
  static const int kInitialTime = 45; // 45 giây đếm ngược
  final ValueNotifier<int> _timeLeftNotifier = ValueNotifier<int>(kInitialTime);
  final ValueNotifier<int> _scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _comboNotifier = ValueNotifier<int>(1);
  final ValueNotifier<bool> _isGameOverNotifier = ValueNotifier<bool>(false);

  bool _isPlaying = true;
  bool _isPaused = false;
  double _basketX = 0.5;

  Ticker? _ticker;
  Duration _lastDuration = Duration.zero;
  double _accumulatedSeconds = 0;

  final List<DropItem> _activeItems = [];
  final List<FloatingScore> _floatingScores = [];
  final Random _rand = Random();

  final List<Map<String, dynamic>> _itemCatalog = [
    {'path': 'assets/images/minigame2/game_1_hung_do_an_vat/tra_sua_1.jpg', 'label': 'Trà sữa', 'pts': 30},
    {'path': 'assets/images/minigame2/game_1_hung_do_an_vat/tra_sua_2.jpg', 'label': 'Trà sữa', 'pts': 30},
    {'path': 'assets/images/minigame2/game_1_hung_do_an_vat/khoai_tay_chien.jpg', 'label': 'Khoai tây chiên', 'pts': 20},
    {'path': 'assets/images/minigame2/game_1_hung_do_an_vat/combo_khoai_tay.jpg', 'label': 'Combo khoai tây', 'pts': 20},
    {'path': 'assets/images/minigame2/game_1_hung_do_an_vat/ga_ran_gion.jpg', 'label': 'Gà rán giòn', 'pts': 25},
    {'path': 'assets/images/minigame2/game_1_hung_do_an_vat/ga_chien.jpg', 'label': 'Gà chiên', 'pts': 25},
    {'path': 'assets/images/minigame2/game_1_hung_do_an_vat/xuc_xich_que.jpg', 'label': 'Xúc xích que', 'pts': 15},
    {'path': 'assets/images/minigame2/game_1_hung_do_an_vat/xien_nuong.jpg', 'label': 'Xiên nướng', 'pts': 15},
    {'path': 'assets/images/minigame2/game_1_hung_do_an_vat/snack_goi.jpg', 'label': 'Bánh snack', 'pts': 15},
    {'path': 'assets/images/minigame2/game_1_hung_do_an_vat/hotdog.jpg', 'label': 'Hotdog', 'pts': 20},
    {'path': 'assets/images/minigame2/game_1_hung_do_an_vat/ga_vien_xien.jpg', 'label': 'Gà viên xiên', 'pts': 15},
    {'path': 'assets/images/minigame2/game_1_hung_do_an_vat/keo_ngot.jpg', 'label': 'Kẹo ngọt', 'pts': 10},
  ];

  // ValueNotifier dành riêng cho vùng vẽ chuyển động (không rebuild cả màn hình)
  final ValueNotifier<int> _playfieldTickNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _scoreNotifier.value = 0;
    _comboNotifier.value = 1;
    _timeLeftNotifier.value = kInitialTime;
    _isGameOverNotifier.value = false;
    _isPlaying = true;
    _isPaused = false;
    _basketX = 0.5;
    _accumulatedSeconds = 0;
    _activeItems.clear();
    _floatingScores.clear();

    for (int i = 0; i < 4; i++) {
      _spawnItem(initialY: -0.15 * (i + 1));
    }

    _ticker?.dispose();
    _lastDuration = Duration.zero;
    _ticker = createTicker(_onTick)..start();
  }

  void _spawnItem({double initialY = -0.06}) {
    final cat = _itemCatalog[_rand.nextInt(_itemCatalog.length)];
    _activeItems.add(DropItem(
      x: 0.12 + _rand.nextDouble() * 0.76,
      y: initialY,
      speed: 0.0055 + _rand.nextDouble() * 0.0045,
      assetPath: cat['path'] as String,
      label: cat['label'] as String,
      points: cat['pts'] as int,
    ));
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !_isPlaying || _isPaused) return;

    if (_lastDuration == Duration.zero) {
      _lastDuration = elapsed;
      return;
    }

    final double dt = (elapsed - _lastDuration).inMilliseconds / 1000.0;
    _lastDuration = elapsed;

    if (dt <= 0 || dt > 0.1) return; // Bảo vệ khi giật frame

    // 1. Đếm ngược giây
    _accumulatedSeconds += dt;
    if (_accumulatedSeconds >= 1.0) {
      _accumulatedSeconds -= 1.0;
      if (_timeLeftNotifier.value > 0) {
        _timeLeftNotifier.value--;
      } else {
        _endGame();
        return;
      }
    }

    // 2. Cập nhật vật lý rơi đồ ăn
    final double speedFactor = dt * 60.0;
    for (int i = _activeItems.length - 1; i >= 0; i--) {
      final item = _activeItems[i];
      item.y += item.speed * speedFactor;

      // Bắt va chạm với xô hứng
      if (item.y >= 0.76 && item.y <= 0.86) {
        if ((item.x - _basketX).abs() < 0.14) {
          final pts = item.points * _comboNotifier.value;
          _scoreNotifier.value += pts;
          _comboNotifier.value = min(_comboNotifier.value + 1, 5);

          _floatingScores.add(FloatingScore(
            x: item.x,
            y: 0.74,
            text: '+$pts Pts',
          ));

          _activeItems.removeAt(i);
          _spawnItem();
          continue;
        }
      }

      // Rơi khỏi đáy
      if (item.y > 1.05) {
        _activeItems.removeAt(i);
        _comboNotifier.value = 1;
        _spawnItem();
      }
    }

    while (_activeItems.length < 4) {
      _spawnItem();
    }

    // 3. Hiệu ứng điểm nổi
    for (int i = _floatingScores.length - 1; i >= 0; i--) {
      final fs = _floatingScores[i];
      fs.opacity -= 0.035 * speedFactor;
      if (fs.opacity <= 0) {
        _floatingScores.removeAt(i);
      }
    }

    // Chỉ kích hoạt render lại đúng vùng sân chơi (Playfield)
    _playfieldTickNotifier.value++;
  }

  void _endGame() {
    _isPlaying = false;
    _ticker?.stop();
    _isGameOverNotifier.value = true;
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _timeLeftNotifier.dispose();
    _scoreNotifier.dispose();
    _comboNotifier.dispose();
    _isGameOverNotifier.dispose();
    _playfieldTickNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0F5),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── TOP HEADER (Được bọc RepaintBoundary, không bị re-render liên tục) ──
            RepaintBoundary(
              child: _buildTopHeader(),
            ),

            // ── SÂN CHƠI GAME RƠI ĐỒ ĂN (TỐI ƯU SIÊU MƯỢT) ──
            Expanded(
              child: RepaintBoundary(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Biển hiệu gỗ bên trái & phải
                    Positioned(
                      left: 12,
                      top: 15,
                      child: _buildWoodenSign('Lụm đồ ăn\nThật nhanh\nnhé~ ♡'),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 80,
                      child: _buildWoodenSign('Ăn vặt\nlà phải\nvui! ♡'),
                    ),

                    // Gesture + Render vật thể chuyển động
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;
                          final h = constraints.maxHeight;

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: (details) {
                              if (!_isPlaying || _isPaused) return;
                              _basketX = (details.localPosition.dx / w).clamp(0.12, 0.88);
                              _playfieldTickNotifier.value++;
                            },
                            onTapDown: (details) {
                              if (!_isPlaying || _isPaused) return;
                              _basketX = (details.localPosition.dx / w).clamp(0.12, 0.88);
                              _playfieldTickNotifier.value++;
                            },
                            child: AnimatedBuilder(
                              animation: _playfieldTickNotifier,
                              builder: (context, _) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // 1. Đồ ăn rơi
                                    ..._activeItems.map((item) {
                                      return Positioned(
                                        left: item.x * w - 27,
                                        top: item.y * h,
                                        child: Container(
                                          width: 54,
                                          height: 54,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.pink.withValues(alpha: 0.2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(27),
                                            child: Image.asset(
                                              item.assetPath,
                                              fit: BoxFit.cover,
                                              cacheWidth: 110,
                                              cacheHeight: 110,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),

                                    // 2. Chữ điểm nổi
                                    ..._floatingScores.map((fs) {
                                      return Positioned(
                                        left: fs.x * w - 30,
                                        top: fs.y * h - (1.0 - fs.opacity) * 35,
                                        child: Opacity(
                                          opacity: fs.opacity.clamp(0.0, 1.0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFE2C55),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              fs.text,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),

                                    // 3. Nhân vật chibi hứng đồ ăn ở đáy
                                    Positioned(
                                      left: _basketX * w - 85,
                                      top: 0.72 * h,
                                      child: Image.asset(
                                        'assets/images/minigame2/chibi_catchers.png',
                                        width: 170,
                                        height: 125,
                                        fit: BoxFit.contain,
                                        cacheWidth: 340,
                                        errorBuilder: (_, __, ___) => const Text('🧺', style: TextStyle(fontSize: 60)),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Màn hình kết thúc trò chơi
                    ValueListenableBuilder<bool>(
                      valueListenable: _isGameOverNotifier,
                      builder: (context, isOver, _) {
                        if (!isOver) return const SizedBox.shrink();
                        return _buildGameOverOverlay();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── BOTTOM CONTROLS ──
            RepaintBoundary(
              child: _buildBottomControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBackToHub,
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFB71C1C), size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF5252), width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm, color: Color(0xFFD32F2F), size: 20),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thời gian',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF757575)),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: _timeLeftNotifier,
                          builder: (context, tLeft, _) {
                            final timeStr = '00:${tLeft.toString().padLeft(2, '0')}';
                            return Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: tLeft <= 10 ? Colors.red : const Color(0xFFD32F2F),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Logo trung tâm
          Image.asset(
            'assets/images/minigame2/header_logo.png',
            height: 58,
            fit: BoxFit.contain,
            cacheHeight: 120,
            errorBuilder: (_, __, ___) => const Text(
              'ChouxChin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFB71C1C)),
            ),
          ),

          // Điểm số
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF5252), width: 2),
            ),
            child: Row(
              children: [
                const Text('👑', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Điểm',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF757575)),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: _scoreNotifier,
                      builder: (context, sc, _) {
                        return Text(
                          '$sc',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD32F2F),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWoodenSign(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFB74D), width: 2),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE65100),
          height: 1.25,
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _comboNotifier,
            builder: (context, combo, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFFF4081), width: 2),
                ),
                child: Row(
                  children: [
                    const Text('🍟', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 6),
                    Text(
                      'x $combo Combo',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFC2185B),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Text(
            'Kéo qua lại để hứng đồ ăn nhé~ ♡',
            style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic),
          ),
          GestureDetector(
            onTap: _togglePause,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4081),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: Icon(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 6),
                const Text(
                  'HẾT GIỜ RỒI!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFB71C1C)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn đã xuất sắc lụm được: ${_scoreNotifier.value} Điểm!',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFB6C1)),
                  ),
                  child: const Row(
                    children: [
                      Text('🎁', style: TextStyle(fontSize: 26)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Chúc mừng bạn nhận được 1 LƯỢT QUAY GIẢM GIÁ từ quán ChouxChin!',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFC2185B)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _startNewGame,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF757575),
                          side: const BorderSide(color: Color(0xFFBDBDBD)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Chơi lại 🔄'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: widget.onFinishAndOpenWheel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFE2C55),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('QUAY NGAY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                            SizedBox(width: 6),
                            Text('🎡', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
