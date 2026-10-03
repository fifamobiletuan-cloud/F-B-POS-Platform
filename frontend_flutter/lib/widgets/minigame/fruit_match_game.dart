import 'dart:async';
import 'package:flutter/material.dart';

class FlipCardItem {
  final int id;
  final String fruitKey;
  final String assetPath;
  final String name;
  bool isFlipped;
  bool isMatched;

  FlipCardItem({
    required this.id,
    required this.fruitKey,
    required this.assetPath,
    required this.name,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class FruitMatchGame extends StatefulWidget {
  final VoidCallback onFinishAndOpenWheel;
  final VoidCallback onBackToHub;

  const FruitMatchGame({
    super.key,
    required this.onFinishAndOpenWheel,
    required this.onBackToHub,
  });

  @override
  State<FruitMatchGame> createState() => _FruitMatchGameState();
}

class _FruitMatchGameState extends State<FruitMatchGame> {
  static const int kTotalTime = 90; // 01:30
  final ValueNotifier<int> _timeLeftNotifier = ValueNotifier<int>(kTotalTime);
  final ValueNotifier<int> _matchedPairsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isGameOverNotifier = ValueNotifier<bool>(false);

  bool _isProcessing = false;
  Timer? _countdownTimer;
  List<FlipCardItem> _cards = [];
  int? _firstSelectedIndex;

  final List<Map<String, String>> _fruitCatalog = [
    {'key': 'dau_tay', 'name': 'Dâu tây', 'path': 'assets/images/minigame2/game_2_lat_the_trai_cay/dau_tay_1.jpg'},
    {'key': 'tao', 'name': 'Táo đỏ', 'path': 'assets/images/minigame2/game_2_lat_the_trai_cay/tao.jpg'},
    {'key': 'nho_tim', 'name': 'Nho tím', 'path': 'assets/images/minigame2/game_2_lat_the_trai_cay/nho_tim_1.jpg'},
    {'key': 'chuoi', 'name': 'Chuối', 'path': 'assets/images/minigame2/game_2_lat_the_trai_cay/chuoi.jpg'},
    {'key': 'cam', 'name': 'Cam tươi', 'path': 'assets/images/minigame2/game_2_lat_the_trai_cay/cam_1.jpg'},
    {'key': 'dua_hau', 'name': 'Dưa hấu', 'path': 'assets/images/minigame2/game_2_lat_the_trai_cay/dua_hau.jpg'},
    {'key': 'dua', 'name': 'Dứa', 'path': 'assets/images/minigame2/game_2_lat_the_trai_cay/dua.jpg'},
    {'key': 'quyt', 'name': 'Quýt ngọt', 'path': 'assets/images/minigame2/game_2_lat_the_trai_cay/quyt.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _matchedPairsNotifier.value = 0;
    _timeLeftNotifier.value = kTotalTime;
    _isGameOverNotifier.value = false;
    _firstSelectedIndex = null;
    _isProcessing = false;

    final List<FlipCardItem> cardList = [];
    int idCounter = 0;
    for (final f in _fruitCatalog) {
      cardList.add(FlipCardItem(
        id: idCounter++,
        fruitKey: f['key']!,
        assetPath: f['path']!,
        name: f['name']!,
      ));
      cardList.add(FlipCardItem(
        id: idCounter++,
        fruitKey: f['key']!,
        assetPath: f['path']!,
        name: f['name']!,
      ));
    }

    cardList.shuffle();
    _cards = cardList;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timeLeftNotifier.value > 0) {
        _timeLeftNotifier.value--;
      } else {
        _isGameOverNotifier.value = true;
        _countdownTimer?.cancel();
      }
    });

    setState(() {});
  }

  void _onCardTap(int index) async {
    if (_isProcessing || _isGameOverNotifier.value) return;
    final card = _cards[index];
    if (card.isMatched || card.isFlipped) return;

    setState(() {
      card.isFlipped = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      final firstIndex = _firstSelectedIndex!;
      final firstCard = _cards[firstIndex];
      _firstSelectedIndex = null;
      _isProcessing = true;

      if (firstCard.fruitKey == card.fruitKey) {
        await Future.delayed(const Duration(milliseconds: 250));
        if (!mounted) return;
        setState(() {
          firstCard.isMatched = true;
          card.isMatched = true;
          _matchedPairsNotifier.value++;
          _isProcessing = false;

          if (_matchedPairsNotifier.value >= 8) {
            _isGameOverNotifier.value = true;
            _countdownTimer?.cancel();
          }
        });
      } else {
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) {
          setState(() {
            firstCard.isFlipped = false;
            card.isFlipped = false;
            _isProcessing = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _timeLeftNotifier.dispose();
    _matchedPairsNotifier.dispose();
    _isGameOverNotifier.dispose();
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
            // ── TOP HEADER ──
            RepaintBoundary(
              child: _buildTopHeader(),
            ),

            // ── 16 CARDS GRID ──
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 460, maxHeight: 460),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFFFFB6C1), width: 3),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _cards.length,
                        itemBuilder: (context, index) {
                          final card = _cards[index];
                          final bool isVisible = card.isFlipped || card.isMatched;

                          return RepaintBoundary(
                            child: GestureDetector(
                              onTap: () => _onCardTap(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isVisible ? Colors.white : const Color(0xFFFFE4E1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: card.isMatched
                                        ? const Color(0xFF4CAF50)
                                        : (isVisible ? const Color(0xFFFF4081) : const Color(0xFFFFB6C1)),
                                    width: card.isMatched ? 2.5 : 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: isVisible
                                      ? Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Image.asset(
                                            card.assetPath,
                                            fit: BoxFit.contain,
                                            cacheWidth: 140,
                                            cacheHeight: 140,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/minigame2/card_back.png',
                                          fit: BoxFit.cover,
                                          cacheWidth: 140,
                                          cacheHeight: 140,
                                          errorBuilder: (_, __, ___) => const Center(
                                            child: Text('🐻', style: TextStyle(fontSize: 28)),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Màn hình Game Over
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

            // ── BOTTOM BAR ──
            RepaintBoundary(
              child: _buildBottomBar(),
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
          GestureDetector(
            onTap: widget.onBackToHub,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4081),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.home_rounded, color: Colors.white, size: 26),
            ),
          ),
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
                        final int min = tLeft ~/ 60;
                        final int sec = tLeft % 60;
                        final timeStr = '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
                        return Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: tLeft <= 15 ? Colors.red : const Color(0xFFD32F2F),
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

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Text('🐰', style: TextStyle(fontSize: 26)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFF4081), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Color(0xFFFE2C55), size: 22),
                const SizedBox(width: 8),
                ValueListenableBuilder<int>(
                  valueListenable: _matchedPairsNotifier,
                  builder: (context, mp, _) {
                    return Text(
                      'Cặp giống nhau: $mp/8',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFC2185B),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFB74D)),
            ),
            child: const Row(
              children: [
                Text('🧋', style: TextStyle(fontSize: 20)),
                SizedBox(width: 4),
                Text(
                  'Ăn vặt ngon~',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final bool isWon = _matchedPairsNotifier.value >= 8;

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
                Text(isWon ? '🏆' : '⏰', style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 6),
                Text(
                  isWon ? 'TUYỆT VỜI! CHIẾN THẮNG!' : 'HẾT GIỜ RỒI!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isWon ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isWon
                      ? 'Bạn đã tìm được đủ 8/8 cặp trái cây!'
                      : 'Bạn đã tìm được ${_matchedPairsNotifier.value}/8 cặp trái cây!',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFC2185B)),
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
