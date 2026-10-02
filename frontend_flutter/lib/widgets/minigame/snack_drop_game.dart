import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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

class _SnackDropGameState extends State<SnackDropGame> {
  static const int kInitialTime = 45; // 45 giây đếm ngược theo ảnh game.png
  int _timeLeft = kInitialTime;
  int _score = 0;
  int _combo = 1;
  bool _isPlaying = true;
  bool _isPaused = false;

  double _basketX = 0.5; // Tọa độ rổ hứng (0.0 -> 1.0)
  Timer? _gameLoopTimer;
  Timer? _countdownTimer;

  final List<DropItem> _activeItems = [];
  final List<FloatingScore> _floatingScores = [];
  final Random _rand = Random();

  // Danh mục 12 món ăn vặt từ D:\Doantotnghiep\minigame2\game_1_hung_do_an_vat
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

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _score = 0;
    _combo = 1;
    _timeLeft = kInitialTime;
    _isPlaying = true;
    _isPaused = false;
    _activeItems.clear();
    _floatingScores.clear();

    for (int i = 0; i < 4; i++) {
      _spawnItem(initialY: -0.15 * (i + 1));
    }

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_isPaused) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame();
        }
      });
    });

    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!mounted || !_isPlaying || _isPaused) return;
      _updatePhysics();
    });
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

  void _updatePhysics() {
    setState(() {
      for (int i = _activeItems.length - 1; i >= 0; i--) {
        final item = _activeItems[i];
        item.y += item.speed;

        // Va chạm xô hứng (y: 0.76 -> 0.86)
        if (item.y >= 0.76 && item.y <= 0.86) {
          if ((item.x - _basketX).abs() < 0.14) {
            _score += item.points * _combo;
            _combo = min(_combo + 1, 5);

            _floatingScores.add(FloatingScore(
              x: item.x,
              y: 0.74,
              text: '+${item.points * _combo} Pts',
            ));

            _activeItems.removeAt(i);
            _spawnItem();
            continue;
          }
        }

        // Rơi khỏi đáy
        if (item.y > 1.05) {
          _activeItems.removeAt(i);
          _combo = 1; // Hụt đồ ăn, reset combo
          _spawnItem();
        }
      }

      while (_activeItems.length < 4) {
        _spawnItem();
      }

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

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0F5),
        image: DecorationImage(
          image: AssetImage('assets/images/minigame2/preview_game1.jpg'),
          fit: BoxFit.cover,
          opacity: 0.22,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── TOP HEADER CHUẨN THEO ẢNH GAME.PNG ──
            _buildTopHeader(),

            // ── KHU VỰC ĐỒ ĂN RƠI THEO THỜI GIAN THỰC ──
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Biển hiệu gỗ dễ thương bên trái & phải
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

                  // GestureDetector kéo rổ hứng
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragUpdate: (details) {
                            if (!_isPlaying || _isPaused) return;
                            setState(() {
                              _basketX = (details.localPosition.dx / w).clamp(0.12, 0.88);
                            });
                          },
                          onTapDown: (details) {
                            if (!_isPlaying || _isPaused) return;
                            setState(() {
                              _basketX = (details.localPosition.dx / w).clamp(0.12, 0.88);
                            });
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // 1. Các món ăn vặt đang rơi xuống
                              ..._activeItems.map((item) {
                                return Positioned(
                                  left: item.x * w - 28,
                                  top: item.y * h,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.pink.withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: Image.asset(
                                        item.assetPath,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              // 2. Chữ điểm nổi "+30 Pts"
                              ..._floatingScores.map((fs) {
                                return Positioned(
                                  left: fs.x * w - 30,
                                  top: fs.y * h - (1.0 - fs.opacity) * 40,
                                  child: Opacity(
                                    opacity: fs.opacity.clamp(0.0, 1.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFFF4081), Color(0xFFFE2C55)],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                      ),
                                      child: Text(
                                        fs.text,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              // 3. Hai bé chibi cầm xô hứng đồ ăn ở đáy (chibi_catchers.png)
                              Positioned(
                                left: _basketX * w - 85,
                                top: 0.72 * h,
                                child: Image.asset(
                                  'assets/images/minigame2/chibi_catchers.png',
                                  width: 170,
                                  height: 125,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Text('🧺', style: TextStyle(fontSize: 60)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Màn hình kết thúc trò chơi
                  if (!_isPlaying) _buildGameOverOverlay(),
                ],
              ),
            ),

            // ── BOTTOM BAR: COMBO CHIPS + NÚT TẠM DỪNG ──
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    final String timeStr = '00:${_timeLeft.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút quay lại & Badge Thời gian
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
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
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
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _timeLeft <= 10 ? Colors.red : const Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Logo trung tâm ChouxChin Cửa hàng ăn vặt
          Image.asset(
            'assets/images/minigame2/header_logo.png',
            height: 62,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              'ChouxChin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFB71C1C)),
            ),
          ),

          // Badge Điểm số
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF5252), width: 2),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
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
                    Text(
                      '$_score',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFD32F2F),
                      ),
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
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
          // Badge Combo x3
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFFF4081), width: 2),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(
              children: [
                const Text('🍟', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 6),
                Text(
                  'x $_combo Combo',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFC2185B),
                  ),
                ),
              ],
            ),
          ),

          const Text(
            'Kéo qua lại để hứng đồ ăn nhé~ ♡',
            style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic),
          ),

          // Nút tạm dừng ⏸
          GestureDetector(
            onTap: _togglePause,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4081),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Icon(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.white,
                size: 28,
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
                  'Bạn đã xuất sắc lụm được: $_score Điểm!',
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
