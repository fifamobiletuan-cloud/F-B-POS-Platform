import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DropItem {
  double x; // 0.0 -> 1.0 (vị trí ngang)
  double y; // 0.0 -> 1.0 (vị trí dọc)
  double vx; // Tốc độ trôi ngang (rơi từ nhiều phía)
  final double speed; // Tốc độ rơi
  final double waveFreq;
  final double wavePhase;
  final String assetPath;
  final String label;
  final int points;

  DropItem({
    required this.x,
    required this.y,
    required this.vx,
    required this.speed,
    required this.waveFreq,
    required this.wavePhase,
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
  static const int kInitialTime = 45; // 45 giây đếm ngược chuẩn theo game.png
  final ValueNotifier<int> _timeLeftNotifier = ValueNotifier<int>(kInitialTime);
  final ValueNotifier<int> _scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _comboNotifier = ValueNotifier<int>(1);
  final ValueNotifier<bool> _isGameOverNotifier = ValueNotifier<bool>(false);

  bool _isPlaying = true;
  bool _isPaused = false;
  double _basketX = 0.5; // Tọa độ rổ hứng (0.0 -> 1.0)

  Ticker? _ticker;
  Duration _lastDuration = Duration.zero;
  double _accumulatedSeconds = 0;

  final List<DropItem> _activeItems = [];
  final List<FloatingScore> _floatingScores = [];
  final Random _rand = Random();

  // 12 món ăn vặt từ D:\Doantotnghiep\minigame2\game_1_hung_do_an_vat
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

    // Rải sẵn 6 món rơi từ các phía khác nhau trên màn hình
    for (int i = 0; i < 6; i++) {
      _spawnItem(initialY: -0.12 * (i + 1));
    }

    _ticker?.dispose();
    _lastDuration = Duration.zero;
    _ticker = createTicker(_onTick)..start();
  }

  // Đồ ăn rơi từ nhiều vị trí ngang khác nhau (từ trái, giữa đến phải)
  void _spawnItem({double initialY = -0.06}) {
    final cat = _itemCatalog[_rand.nextInt(_itemCatalog.length)];
    // Tọa độ X trải đều từ 0.05 (mép trái) đến 0.95 (mép phải)
    final double spawnX = 0.06 + _rand.nextDouble() * 0.88;
    // Tốc độ ngang vx tạo độ rơi xiên từ các phía
    final double spawnVx = (_rand.nextDouble() - 0.5) * 0.003;

    _activeItems.add(DropItem(
      x: spawnX,
      y: initialY,
      vx: spawnVx,
      speed: 0.005 + _rand.nextDouble() * 0.004,
      waveFreq: 2.0 + _rand.nextDouble() * 2.0,
      wavePhase: _rand.nextDouble() * 2 * pi,
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

    if (dt <= 0 || dt > 0.1) return;

    // 1. Đếm ngược thời gian
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

    // 2. Vật lý rơi đa hướng: rơi thẳng kết hợp trôi ngang
    final double speedFactor = dt * 60.0;
    for (int i = _activeItems.length - 1; i >= 0; i--) {
      final item = _activeItems[i];
      item.y += item.speed * speedFactor;
      // Trôi ngang đung đưa nhẹ nhàng từ nhiều phía
      item.x += (item.vx + sin((item.y * item.waveFreq * pi) + item.wavePhase) * 0.0015) * speedFactor;
      item.x = item.x.clamp(0.04, 0.96);

      // Bắt va chạm với xô hứng (phạm vi hứng thoải mái, dễ ăn điểm)
      if (item.y >= 0.70 && item.y <= 0.88) {
        if ((item.x - _basketX).abs() < 0.18) {
          final pts = item.points * _comboNotifier.value;
          _scoreNotifier.value += pts;
          _comboNotifier.value = min(_comboNotifier.value + 1, 5);

          _floatingScores.add(FloatingScore(
            x: item.x,
            y: 0.72,
            text: '+$pts Pts',
          ));

          _activeItems.removeAt(i);
          _spawnItem();
          continue;
        }
      }

      // Rơi khỏi đáy màn hình
      if (item.y > 1.05) {
        _activeItems.removeAt(i);
        _comboNotifier.value = 1;
        _spawnItem();
      }
    }

    // Luôn duy trì 6 món ăn rơi liên tục trên màn hình
    while (_activeItems.length < 6) {
      _spawnItem();
    }

    // 3. Hiệu ứng điểm nổi bay lên
    for (int i = _floatingScores.length - 1; i >= 0; i--) {
      final fs = _floatingScores[i];
      fs.opacity -= 0.035 * speedFactor;
      if (fs.opacity <= 0) {
        _floatingScores.removeAt(i);
      }
    }

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

  // Điều khiển xô hứng di chuyển
  void _setBasketPosition(double normX) {
    if (!_isPlaying || _isPaused) return;
    _basketX = normX.clamp(0.12, 0.88);
    _playfieldTickNotifier.value++;
  }

  void _moveBasketByDelta(double delta) {
    if (!_isPlaying || _isPaused) return;
    _basketX = (_basketX + delta).clamp(0.12, 0.88);
    _playfieldTickNotifier.value++;
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
            // ── TOP HEADER (Bảng thời gian, Logo ChouxChin, Điểm số) ──
            RepaintBoundary(
              child: _buildTopHeader(),
            ),

            // ── SÂN CHƠI CHÍNH: HỖ TRỢ CẢ CHẠM, KÉO, CLICK CHUỘT ──
            Expanded(
              child: RepaintBoundary(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;

                    return Listener(
                      behavior: HitTestBehavior.translucent,
                      // Hỗ trợ chuột và cảm ứng mọi lúc mọi nơi trên màn hình
                      onPointerDown: (e) {
                        _setBasketPosition(e.localPosition.dx / w);
                      },
                      onPointerMove: (e) {
                        _setBasketPosition(e.localPosition.dx / w);
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanDown: (details) {
                          _setBasketPosition(details.localPosition.dx / w);
                        },
                        onPanUpdate: (details) {
                          _setBasketPosition(details.localPosition.dx / w);
                        },
                        onTapDown: (details) {
                          _setBasketPosition(details.localPosition.dx / w);
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Biển hiệu gỗ dễ thương 2 bên
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

                            // Các vật thể chuyển động (Đồ ăn rơi + Xô hứng + Điểm nổi)
                            AnimatedBuilder(
                              animation: _playfieldTickNotifier,
                              builder: (context, _) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // 1. Đồ ăn rơi từ nhiều hướng
                                    ..._activeItems.map((item) {
                                      return Positioned(
                                        left: item.x * w - 26,
                                        top: item.y * h,
                                        child: Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.pink.withValues(alpha: 0.25),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(26),
                                            child: Image.asset(
                                              item.assetPath,
                                              fit: BoxFit.cover,
                                              cacheWidth: 105,
                                              cacheHeight: 105,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),

                                    // 2. Chữ điểm nổi "+30 Pts"
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
                                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
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

                                    // 3. Nhân vật chibi cầm xô hứng đồ ăn ở đáy
                                    Positioned(
                                      left: _basketX * w - 85,
                                      top: 0.70 * h,
                                      child: Image.asset(
                                        'assets/images/minigame2/chibi_catchers.png',
                                        width: 170,
                                        height: 130,
                                        fit: BoxFit.contain,
                                        cacheWidth: 340,
                                        errorBuilder: (_, __, ___) => const Text('🧺', style: TextStyle(fontSize: 60)),
                                      ),
                                    ),
                                  ],
                                );
                              },
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
                    );
                  },
                ),
              ),
            ),

            // ── BOTTOM BAR: CÓ NÚT MŨI TÊN TRÁI/PHẢI + COMBO + NÚT TẠM DỪNG ──
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

          // Logo trung tâm ChouxChin
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút mũi tên TRÁI ◀
          GestureDetector(
            onTap: () => _moveBasketByDelta(-0.12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD1DC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFF8DA1), width: 2),
              ),
              child: const Icon(Icons.arrow_left_rounded, size: 38, color: Color(0xFFB71C1C)),
            ),
          ),

          // Badge Combo
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
                    const Text('🍟', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      'x $combo Combo',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFC2185B),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Nút mũi tên PHẢI ▶
          GestureDetector(
            onTap: () => _moveBasketByDelta(0.12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD1DC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFF8DA1), width: 2),
              ),
              child: const Icon(Icons.arrow_right_rounded, size: 38, color: Color(0xFFB71C1C)),
            ),
          ),

          // Nút tạm dừng ⏸
          GestureDetector(
            onTap: _togglePause,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4081),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: Colors.white,
                size: 24,
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
