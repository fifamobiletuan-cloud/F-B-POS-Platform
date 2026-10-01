import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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

class _FruitTile {
  int type; // 0: Dâu tây, 1: Xoài, 2: Kiwi, 3: Chuối

  _FruitTile({required this.type});
}

class _FruitMatchGameState extends State<FruitMatchGame> {
  static const int kRows = 6;
  static const int kCols = 6;
  static const int kInitialMoves = 18;
  static const int _targetStrawberry = 10;
  static const int _targetKiwi = 10;

  int _movesLeft = kInitialMoves;
  int _score = 0;
  int _collectedStrawberry = 0;
  int _collectedKiwi = 0;

  bool _isGameOver = false;
  int? _selectedRow;
  int? _selectedCol;
  bool _isProcessing = false;

  final Random _rand = Random();
  late List<List<_FruitTile>> _grid;

  final List<String> _fruitAssets = [
    'assets/images/minigame/icon_dau_tay.png', // 0: Dâu tây
    'assets/images/minigame/icon_xoai.png',    // 1: Xoài
    'assets/images/minigame/icon_kiwi.png',    // 2: Kiwi
    'assets/images/minigame/icon_chuoi.png',   // 3: Chuối
  ];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _movesLeft = kInitialMoves;
    _score = 0;
    _collectedStrawberry = 0;
    _collectedKiwi = 0;
    _isGameOver = false;
    _selectedRow = null;
    _selectedCol = null;
    _isProcessing = false;

    // Tạo bảng không có sẵn match 3
    _grid = List.generate(kRows, (r) {
      return List.generate(kCols, (c) {
        int t;
        do {
          t = _rand.nextInt(_fruitAssets.length);
        } while ((c >= 2 && _grid[r][c - 1].type == t && _grid[r][c - 2].type == t) ||
                 (r >= 2 && _grid[r - 1][c].type == t && _grid[r - 2][c].type == t));
        return _FruitTile(type: t);
      });
    });

    setState(() {});
  }

  // Người chơi chạm vào 1 ô trong lưới
  void _onTileTap(int r, int c) async {
    if (_isProcessing || _isGameOver) return;

    if (_selectedRow == null || _selectedCol == null) {
      // Chọn ô thứ nhất
      setState(() {
        _selectedRow = r;
        _selectedCol = c;
      });
      return;
    }

    final int sr = _selectedRow!;
    final int sc = _selectedCol!;

    // Chạm lại chính nó -> hủy chọn
    if (sr == r && sc == c) {
      setState(() {
        _selectedRow = null;
        _selectedCol = null;
      });
      return;
    }

    // Kiểm tra có phải ô liền kề không (trên, dưới, trái, phải)
    final bool isAdjacent = (sr == r && (sc - c).abs() == 1) || (sc == c && (sr - r).abs() == 1);

    if (!isAdjacent) {
      // Chọn ô mới
      setState(() {
        _selectedRow = r;
        _selectedCol = c;
      });
      return;
    }

    // Thực hiện tráo đổi (Swap)
    _isProcessing = true;
    setState(() {
      _swap(sr, sc, r, c);
      _selectedRow = null;
      _selectedCol = null;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    // Kiểm tra có match không
    final matches = _findMatches();
    if (matches.isNotEmpty) {
      _movesLeft--;
      await _processMatches(matches);
    } else {
      // Không match -> Đổi lại chỗ cũ
      setState(() {
        _swap(sr, sc, r, c);
      });
    }

    // Kiểm tra hết lượt hoặc thắng
    if (_movesLeft <= 0 || (_collectedStrawberry >= _targetStrawberry && _collectedKiwi >= _targetKiwi)) {
      setState(() {
        _isGameOver = true;
      });
    }

    _isProcessing = false;
  }

  void _swap(int r1, int c1, int r2, int c2) {
    final temp = _grid[r1][c1];
    _grid[r1][c1] = _grid[r2][c2];
    _grid[r2][c2] = temp;
  }

  // Tìm tất cả các cụm Match >= 3
  Set<Point<int>> _findMatches() {
    final Set<Point<int>> matches = {};

    // Kiểm tra hàng ngang
    for (int r = 0; r < kRows; r++) {
      for (int c = 0; c < kCols - 2; c++) {
        final t = _grid[r][c].type;
        if (t != -1 && t == _grid[r][c + 1].type && t == _grid[r][c + 2].type) {
          matches.add(Point(r, c));
          matches.add(Point(r, c + 1));
          matches.add(Point(r, c + 2));
        }
      }
    }

    // Kiểm tra hàng dọc
    for (int c = 0; c < kCols; c++) {
      for (int r = 0; r < kRows - 2; r++) {
        final t = _grid[r][c].type;
        if (t != -1 && t == _grid[r + 1][c].type && t == _grid[r + 2][c].type) {
          matches.add(Point(r, c));
          matches.add(Point(r + 1, c));
          matches.add(Point(r + 2, c));
        }
      }
    }

    return matches;
  }

  Future<void> _processMatches(Set<Point<int>> matches) async {
    while (matches.isNotEmpty) {
      // Nổ điểm và thu thập mục tiêu
      for (final p in matches) {
        final t = _grid[p.x][p.y].type;
        if (t == 0) _collectedStrawberry++;
        if (t == 2) _collectedKiwi++;
        _score += 50;
      }

      setState(() {
        for (final p in matches) {
          _grid[p.x][p.y].type = -1; // Đánh dấu nổ
        }
      });

      await Future.delayed(const Duration(milliseconds: 250));

      // Trái cây phía trên rơi xuống (Cascade)
      setState(() {
        for (int c = 0; c < kCols; c++) {
          int writeRow = kRows - 1;
          for (int r = kRows - 1; r >= 0; r--) {
            if (_grid[r][c].type != -1) {
              if (writeRow != r) {
                _grid[writeRow][c].type = _grid[r][c].type;
                _grid[r][c].type = -1;
              }
              writeRow--;
            }
          }
          // Sinh trái cây mới ở hàng trên
          for (int r = writeRow; r >= 0; r--) {
            _grid[r][c].type = _rand.nextInt(_fruitAssets.length);
          }
        }
      });

      await Future.delayed(const Duration(milliseconds: 250));
      matches = _findMatches(); // Tìm tiếp combo liên hoàn
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9), // Xanh pastel ngọt ngào
        image: DecorationImage(
          image: AssetImage('assets/images/minigame/fruit_match_preview.jpg'),
          fit: BoxFit.cover,
          opacity: 0.16,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR: TIÊU ĐỀ + LƯỢT ĐI + ĐIỂM SỐ ──
            _buildTopBar(),

            // ── KHUNG CHƠI LƯỚI TRÁI CÂY MATCH-3 ──
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF81C784),
                          width: 3,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: kCols,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemCount: kRows * kCols,
                          itemBuilder: (context, index) {
                            final r = index ~/ kCols;
                            final c = index % kCols;
                            final tile = _grid[r][c];
                            final bool isSelected = (_selectedRow == r && _selectedCol == c);

                            if (tile.type == -1) {
                              return const SizedBox.shrink();
                            }

                            return GestureDetector(
                              onTap: () => _onTileTap(r, c),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFFF9C4)
                                      : const Color(0xFFF1F8E9),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFFFB300)
                                        : const Color(0xFFC8E6C9),
                                    width: isSelected ? 3 : 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          const BoxShadow(
                                            color: Color(0x66FFB300),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: Image.asset(
                                  _fruitAssets[tile.type],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Màn hình kết thúc hiển thị phần thưởng
                  if (_isGameOver) _buildGameOverOverlay(),
                ],
              ),
            ),

            // ── BOTTOM CONTROLS: MỤC TIÊU THU THẬP + NÚT CHƠI ──
            _buildBottomTarget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2E7D32)),
                onPressed: widget.onBackToHub,
              ),
              const Expanded(
                child: Text(
                  'CHOUXCHIN FRUIT MATCH!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E7D32),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 6),
          // Bảng Lượt di chuyển & Điểm số
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'LƯỢT DI CHUYỂN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF757575),
                        ),
                      ),
                      Text(
                        '$_movesLeft',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _movesLeft <= 3 ? Colors.red : const Color(0xFF1B5E20),
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
                    border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
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
                          color: Color(0xFFE65100),
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

  Widget _buildBottomTarget() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFC8E6C9), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'MỤC TIÊU:',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                // Mục tiêu Dâu tây
                Row(
                  children: [
                    Image.asset(
                      'assets/images/minigame/icon_dau_tay.png',
                      width: 26,
                      height: 26,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_collectedStrawberry/$_targetStrawberry',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _collectedStrawberry >= _targetStrawberry
                            ? Colors.green
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
                // Mục tiêu Kiwi
                Row(
                  children: [
                    Image.asset(
                      'assets/images/minigame/icon_kiwi.png',
                      width: 26,
                      height: 26,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_collectedKiwi/$_targetKiwi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _collectedKiwi >= _targetKiwi
                            ? Colors.green
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Chạm 2 ô cạnh nhau để tráo đổi và nổ 3 trái cây giống nhau',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final bool isWon =
        _collectedStrawberry >= _targetStrawberry && _collectedKiwi >= _targetKiwi;

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
                Text(isWon ? '🏆' : '👏', style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 6),
                Text(
                  isWon ? 'TUYỆT VỜI! CHIẾN THẮNG!' : 'HOÀN THÀNH LƯỢT CHƠI!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tổng điểm đạt được: $_score Điểm!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
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
                            color: Color(0xFF1B5E20),
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
                        onPressed: _startNewGame,
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
