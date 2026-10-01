import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DropItem {
  double x; // 0.0 -> 1.0 (chiều ngang)
  double y; // 0.0 -> 1.0 (chiều dọc)
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

class _SnackDropGameState extends State<SnackDropGame> {
  static const int kGameDuration = 30; // 30 giây
  int _timeLeft = kGameDuration;
  int _score = 0;
  int _combo = 0;
  bool _isPlaying = true;

  double _basketX = 0.5; // Vị trí giỏ hứng (0.0 -> 1.0)
  Timer? _gameLoopTimer;
  Timer? _countdownTimer;

  final List<DropItem> _activeItems = [];
  final List<FloatingScore> _floatingScores = [];
  final Random _rand = Random();

  final List<Map<String, dynamic>> _itemCatalog = [
    {
      'path': 'assets/images/minigame/icon_tra_sua.png',
      'label': 'Trà sữa',
      'pts': 20,
    },
    {
      'path': 'assets/images/minigame/icon_snack.png',
      'label': 'Snack',
      'pts': 15,
    },
    {
      'path': 'assets/images/minigame/icon_banh_quy.png',
      'label': 'Bánh quy',
      'pts': 10,
    },
    {
      'path': 'assets/images/minigame/icon_keo.png',
      'label': 'Kẹo ngọt',
      'pts': 10,
    },
    {
      'path': 'assets/images/minigame/icon_dau_tay.png',
      'label': 'Dâu tây',
      'pts': 25,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _combo = 0;
    _timeLeft = kGameDuration;
    _isPlaying = true;
    _activeItems.clear();
    _floatingScores.clear();

    // Spawn 3 món đầu tiên
    for (int i = 0; i < 3; i++) {
      _spawnItem(initialY: -0.15 * (i + 1));
    }

    // Timer đếm ngược giây
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame();
        }
      });
    });

    // Game loop ~ 60 FPS (16ms)
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!mounted || !_isPlaying) return;
      _updateGamePhysics();
    });
  }

  void _spawnItem({double initialY = -0.05}) {
    final cat = _itemCatalog[_rand.nextInt(_itemCatalog.length)];
    _activeItems.add(DropItem(
      x: 0.1 + _rand.nextDouble() * 0.8,
      y: initialY,
      speed: 0.006 + _rand.nextDouble() * 0.005,
      assetPath: cat['path'] as String,
      label: cat['label'] as String,
      points: cat['pts'] as int,
    ));
  }

  void _updateGamePhysics() {
    setState(() {
      // 1. Cập nhật vị trí đồ ăn rơi
      for (int i = _activeItems.length - 1; i >= 0; i--) {
        final item = _activeItems[i];
        item.y += item.speed;

        // Va chạm giỏ hứng (ở đáy y: 0.80 -> 0.88)
        if (item.y >= 0.80 && item.y <= 0.88) {
          if ((item.x - _basketX).abs() < 0.12) {
            // Hứng trúng!
            _score += item.points;
            _combo = min(_combo + 1, 5);

            _floatingScores.add(FloatingScore(
              x: item.x,
              y: 0.78,
              text: '+${item.points} Pts',
            ));

            _activeItems.removeAt(i);
            _spawnItem();
            continue;
          }
        }

        // Rơi khỏi đáy màn hình
        if (item.y > 1.05) {
          _activeItems.removeAt(i);
          _combo = 0; // Hụt đồ ăn, reset combo
          _spawnItem();
        }
      }

      // Giữ tối thiểu 3 đồ ăn rơi cùng lúc
      while (_activeItems.length < 3) {
        _spawnItem();
      }

      // 2. Cập nhật hiệu ứng chữ điểm nổi
      for (int i = _floatingScores.length - 1; i >= 0; i--) {
        final fs = _floatingScores[i];
        fs.opacity -= 0.04;
        if (fs.opacity <= 0) {
          _floatingScores.removeAt(i);
        }
      }
    });
  }

  void _endGame() {
    _isPlaying = false;
    _gameLoopTimer?.cancel();
    _countdownTimer?.cancel();
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _moveBasket(double delta) {
    if (!_isPlaying) return;
    setState(() {
      _basketX = (_basketX + delta).clamp(0.08, 0.92);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0F5), // Hồng phấn pastel chuẩn phong cách chibi
        image: DecorationImage(
          image: AssetImage('assets/images/minigame/snack_drop_preview.jpg'),
          fit: BoxFit.cover,
          opacity: 0.18,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR: TIÊU ĐỀ + THỜI GIAN + ĐIỂM SỐ ──
            _buildTopBar(),

            // ── KHUNG CHƠI GAME RƠI ĐỒ ĂN ──
            Expanded(
              child: Stack(
                children: [
                  // Lưới sọc pastel nền game
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFFFB6C1),
                          width: 3,
                        ),
                      ),
                    ),
                  ),

                  // Đồ ăn đang rơi
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragUpdate: (details) {
                            if (!_isPlaying) return;
                            setState(() {
                              _basketX = (details.localPosition.dx / w).clamp(0.08, 0.92);
                            });
                          },
                          onTapDown: (details) {
                            if (!_isPlaying) return;
                            setState(() {
                              _basketX = (details.localPosition.dx / w).clamp(0.08, 0.92);
                            });
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // 1. Render từng đồ ăn rơi
                              ..._activeItems.map((item) {
                                return Positioned(
                                  left: item.x * w - 24,
                                  top: item.y * h,
                                  child: Image.asset(
                                    item.assetPath,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              }),

                              // 2. Chữ điểm nổi "+10 Pts"
                              ..._floatingScores.map((fs) {
                                return Positioned(
                                  left: fs.x * w - 30,
                                  top: fs.y * h - (1.0 - fs.opacity) * 40,
                                  child: Opacity(
                                    opacity: fs.opacity.clamp(0.0, 1.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF4081),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        fs.text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              // 3. Giỏ hứng đồ ăn + Nhân vật chibi ở đáy
                              Positioned(
                                left: _basketX * w - 50,
                                top: 0.80 * h,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Giỏ đựng kẹo/bánh
                                    Image.asset(
                                      'assets/images/minigame/gio_hung_do.png',
                                      width: 90,
                                      height: 65,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFE2C55),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'HỨNG ĐỒ ĂN',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Màn hình kết thúc trò chơi (Game Over)
                  if (!_isPlaying) _buildGameOverOverlay(),
                ],
              ),
            ),

            // ── BOTTOM CONTROLS: D-PAD + THANH COMBO TIM ──
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  // Header trên cùng
  Widget _buildTopBar() {
    final String timeStr =
        '00:${_timeLeft.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD81B60)),
                onPressed: widget.onBackToHub,
              ),
              const Expanded(
                child: Text(
                  'CHOUXCHIN SNACK DROP!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB71C1C),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 6),
          // Bảng Điểm số & Thời gian
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFCDD2), width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ĐIỂM SỐ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF757575),
                        ),
                      ),
                      Text(
                        '$_score',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFCDD2), width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'THỜI GIAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF757575),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _timeLeft <= 5 ? Colors.red : const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Cụm điều khiển dưới cùng
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Column(
        children: [
          // Thanh Combo trái tim
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'COMBO: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFFC2185B),
                ),
              ),
              Row(
                children: List.generate(5, (idx) {
                  return Icon(
                    Icons.favorite,
                    size: 20,
                    color: idx < _combo ? const Color(0xFFFF4081) : Colors.grey.shade300,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // D-Pad điều hướng trái/phải
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildArrowButton(
                icon: Icons.chevron_left,
                onPressed: () => _moveBasket(-0.12),
                label: 'Trái',
              ),
              const SizedBox(width: 24),
              Text(
                'Vuốt màn hình hoặc bấm nút để di chuyển',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(width: 24),
              _buildArrowButton(
                icon: Icons.chevron_right,
                onPressed: () => _moveBasket(0.12),
                label: 'Phải',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD1DC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF8DA1), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 34, color: const Color(0xFFB71C1C)),
      ),
    );
  }

  // Màn hình kết thúc hiển thị phần thưởng
  Widget _buildGameOverOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 16),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 6),
                const Text(
                  'HẾT GIỜ RỒI!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB71C1C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn đã xuất sắc đạt: $_score Điểm!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935),
                  ),
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
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC2185B),
                          ),
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
                        onPressed: _startGame,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF757575),
                          side: const BorderSide(color: Color(0xFFBDBDBD)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'QUAY NGAY',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
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
