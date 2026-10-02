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
  static const int kTotalTime = 90; // 01:30 đếm ngược chuẩn theo ảnh game.png
  int _timeLeft = kTotalTime;
  int _matchedPairs = 0;
  bool _isProcessing = false;
  bool _isGameOver = false;

  Timer? _countdownTimer;
  List<FlipCardItem> _cards = [];
  int? _firstSelectedIndex;

  // 8 loại trái cây từ D:\Doantotnghiep\minigame2\game_2_lat_the_trai_cay
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
    _matchedPairs = 0;
    _timeLeft = kTotalTime;
    _isGameOver = false;
    _firstSelectedIndex = null;
    _isProcessing = false;

    // Tạo 8 cặp = 16 thẻ bài
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

    // Xáo trộn ngẫu nhiên vị trí
    cardList.shuffle();
    _cards = cardList;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _isGameOver = true;
          _countdownTimer?.cancel();
        }
      });
    });

    setState(() {});
  }

  void _onCardTap(int index) async {
    if (_isProcessing || _isGameOver) return;
    final card = _cards[index];
    if (card.isMatched || card.isFlipped) return;

    setState(() {
      card.isFlipped = true;
    });

    if (_firstSelectedIndex == null) {
      // Chọn thẻ đầu tiên
      _firstSelectedIndex = index;
    } else {
      // Chọn thẻ thứ hai -> Kiểm tra khớp
      final firstIndex = _firstSelectedIndex!;
      final firstCard = _cards[firstIndex];
      _firstSelectedIndex = null;
      _isProcessing = true;

      if (firstCard.fruitKey == card.fruitKey) {
        // TRÙNG KHỚP! Giữ nguyên thẻ
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          firstCard.isMatched = true;
          card.isMatched = true;
          _matchedPairs++;
          _isProcessing = false;

          // Nếu tìm đủ 8/8 cặp -> Thắng cuộc!
          if (_matchedPairs >= 8) {
            _isGameOver = true;
            _countdownTimer?.cancel();
          }
        });
      } else {
        // KHÁC NHAU: Đợi 0.8 giây rồi úp lại
        await Future.delayed(const Duration(milliseconds: 800));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0F5),
        image: DecorationImage(
          image: AssetImage('assets/images/minigame2/preview_game2.jpg'),
          fit: BoxFit.cover,
          opacity: 0.18,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── TOP HEADER: HOME + LOGO + TIMER ──
            _buildTopHeader(),

            // ── LƯỚI 4x4 = 16 THẺ BÀI TRÁI CÂY ──
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 480, maxHeight: 480),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFFFFB6C1), width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                        ],
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

                          return GestureDetector(
                            onTap: () => _onCardTap(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: isVisible ? Colors.white : const Color(0xFFFFE4E1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: card.isMatched
                                      ? const Color(0xFF4CAF50)
                                      : (isVisible ? const Color(0xFFFF4081) : const Color(0xFFFFB6C1)),
                                  width: card.isMatched ? 2.5 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: card.isMatched
                                        ? const Color(0x334CAF50)
                                        : Colors.pink.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: isVisible
                                    ? Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Image.asset(
                                          card.assetPath,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/images/minigame2/card_back.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Text('🐻', style: TextStyle(fontSize: 28)),
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Màn hình kết thúc trò chơi
                  if (_isGameOver) _buildGameOverOverlay(),
                ],
              ),
            ),

            // ── BOTTOM BAR: CẶP GIỐNG NHAU 0/8 + THỎ CON CHIBI ──
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    final int min = _timeLeft ~/ 60;
    final int sec = _timeLeft % 60;
    final String timeStr = '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút Home / Quay lại
          GestureDetector(
            onTap: widget.onBackToHub,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4081),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: const Icon(Icons.home_rounded, color: Colors.white, size: 26),
            ),
          ),

          // Logo trung tâm: ChouxChin Lật thẻ tìm cặp trái cây
          Image.asset(
            'assets/images/minigame2/header_logo.png',
            height: 62,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              'ChouxChin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFB71C1C)),
            ),
          ),

          // Badge Thời gian: 01:30
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
                        color: _timeLeft <= 15 ? Colors.red : const Color(0xFFD32F2F),
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

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Thỏ con dễ thương bên trái
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Text('🐰', style: TextStyle(fontSize: 26)),
          ),

          // Badge Đếm cặp giống nhau: 0/8
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFF4081), width: 2),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, color: Color(0xFFFE2C55), size: 22),
                const SizedBox(width: 8),
                Text(
                  'Cặp giống nhau: $_matchedPairs/8',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFC2185B),
                  ),
                ),
              ],
            ),
          ),

          // Ly trà sữa bên phải
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
    final bool isWon = _matchedPairs >= 8;

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
                      : 'Bạn đã tìm được $_matchedPairs/8 cặp trái cây!',
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
