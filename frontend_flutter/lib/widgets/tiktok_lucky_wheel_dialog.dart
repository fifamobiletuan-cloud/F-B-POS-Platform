import 'dart:math';
import 'package:flutter/material.dart';

class WheelReward {
  final String label;
  final int discountPercent;
  final Color bgColor;
  final Color textColor;

  const WheelReward({
    required this.label,
    required this.discountPercent,
    required this.bgColor,
    required this.textColor,
  });
}

const List<WheelReward> kWheelRewards = [
  WheelReward(
    label: 'Giảm 20%',
    discountPercent: 20,
    bgColor: Color(0xFFFFF0F3),
    textColor: Color(0xFFFE2C55),
  ),
  WheelReward(
    label: 'Giảm 30%',
    discountPercent: 30,
    bgColor: Color(0xFFFFFFFF),
    textColor: Color(0xFFE53935),
  ),
  WheelReward(
    label: 'Giảm 50%',
    discountPercent: 50,
    bgColor: Color(0xFFFFEBEE),
    textColor: Color(0xFFB71C1C),
  ),
  WheelReward(
    label: 'Giảm 15%',
    discountPercent: 15,
    bgColor: Color(0xFFFFFFFF),
    textColor: Color(0xFFFE2C55),
  ),
  WheelReward(
    label: 'Giảm 40%',
    discountPercent: 40,
    bgColor: Color(0xFFFFF0F3),
    textColor: Color(0xFFD81B60),
  ),
  WheelReward(
    label: 'Giảm 25%',
    discountPercent: 25,
    bgColor: Color(0xFFFFFFFF),
    textColor: Color(0xFFE53935),
  ),
];

/// TikTok Shop Style Lucky Wheel Dialog
class TikTokLuckyWheelDialog extends StatefulWidget {
  final void Function(int discountPercent) onWonReward;

  const TikTokLuckyWheelDialog({
    super.key,
    required this.onWonReward,
  });

  @override
  State<TikTokLuckyWheelDialog> createState() => _TikTokLuckyWheelDialogState();
}

class _TikTokLuckyWheelDialogState extends State<TikTokLuckyWheelDialog>
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _confettiController;
  late Animation<double> _spinAnimation;

  bool _isSpinning = false;
  WheelReward? _wonReward;
  double _currentAngle = 0.0;
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _wonReward = null;
    });

    // Chọn giải thưởng ngẫu nhiên (ưu tiên 20%, 30%, 40%, 50%)
    final chosenIndex = _rand.nextInt(kWheelRewards.length);
    final reward = kWheelRewards[chosenIndex];

    final int sectorCount = kWheelRewards.length;
    final double sectorAngle = 2 * pi / sectorCount;

    // Kim chỉ nằm ở đỉnh trên (góc -pi/2 tương ứng 270°)
    // Góc giữa của sector mục tiêu
    final double targetCenter = (chosenIndex + 0.5) * sectorAngle;
    // Góc cần quay để sector đó nằm ở đỉnh trên (-pi/2)
    final double targetOffset = (3 * pi / 2) - targetCenter;

    // Quay thêm 5-7 vòng đầy đủ tạo cảm giác kịch tính
    final int extraTurns = 5 + _rand.nextInt(3);
    final double finalTarget = extraTurns * 2 * pi + targetOffset;

    _spinAnimation = Tween<double>(
      begin: _currentAngle,
      end: _currentAngle + finalTarget,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ));

    _spinController.reset();
    _spinController.forward().whenComplete(() {
      _currentAngle = _spinAnimation.value % (2 * pi);
      setState(() {
        _isSpinning = false;
        _wonReward = reward;
      });
      _confettiController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Khung popup chính
              Container(
                width: 360,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A0815), Color(0xFF16040B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFFE2C55).withValues(alpha: 0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFE2C55).withValues(alpha: 0.35),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 28),
                        const Column(
                          children: [
                            Text(
                              'Nhận Voucher Giảm Đến 50%',
                              style: TextStyle(
                                color: Color(0xFFFFD54F),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Để nhận voucher, hãy quay và áp dụng',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white70, size: 16),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Vòng quay may mắn
                    _buildWheelContainer(),

                    const SizedBox(height: 24),

                    // Nút Quay
                    _buildSpinButton(),

                    const SizedBox(height: 10),
                    const Text(
                      '⚡ 100% cơ hội trúng voucher cho tất cả món ăn',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),

              // Hiệu ứng pháo hoa & Thông báo chúc mừng khi trúng thưởng
              if (_wonReward != null)
                _buildWinnerPopup(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWheelContainer() {
    return SizedBox(
      width: 270,
      height: 270,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Viền phát sáng ngoài cùng
          Container(
            width: 270,
            height: 270,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFE2C55).withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),

          // Vòng quay xoay được
          AnimatedBuilder(
            animation: _spinController,
            builder: (context, _) {
              final angle = _isSpinning ? _spinAnimation.value : _currentAngle;
              return Transform.rotate(
                angle: angle,
                child: CustomPaint(
                  size: const Size(260, 260),
                  painter: _WheelPainter(rewards: kWheelRewards),
                ),
              );
            },
          ),

          // Kim chỉ cố định ở đỉnh trên cùng (chỉ thẳng xuống tâm)
          Positioned(
            top: 2,
            child: _buildPointer(),
          ),

          // Tâm tròn "GO"
          GestureDetector(
            onTap: _startSpin,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFF5252), Color(0xFFC2185B)],
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'GO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointer() {
    return CustomPaint(
      size: const Size(28, 34),
      painter: _PointerPainter(),
    );
  }

  Widget _buildSpinButton() {
    return GestureDetector(
      onTap: _startSpin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFE2C55), Color(0xFFFF5252)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFE2C55).withValues(alpha: 0.5),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isSpinning ? 'Đang quay...' : 'Quay ngay',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _isSpinning ? '🎡' : '👆',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerPopup() {
    final reward = _wonReward!;
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎉 CHÚC MỪNG BẠN! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFD54F),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFE2C55), Color(0xFFFF5252)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFE2C55).withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Text(
                'VOUCHER ${reward.label.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tất cả 84+ món ăn trong thực đơn đã được áp dụng mức giá giảm ưu đãi!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.5,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                widget.onWonReward(reward.discountPercent);
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66FFB300),
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Áp Dụng & Gọi Món Ngay 🚀',
                    style: TextStyle(
                      color: Color(0xFF4A148C),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter vẽ Vòng Quay TikTok Shop
class _WheelPainter extends CustomPainter {
  final List<WheelReward> rewards;

  _WheelPainter({required this.rewards});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double sectorAngle = 2 * pi / rewards.length;

    // 1. Viền ngoài tròn đậm
    final Paint outerBorderPaint = Paint()
      ..color = const Color(0xFFC2185B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerBorderPaint);

    final Paint innerRimPaint = Paint()
      ..color = const Color(0xFFFE2C55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(center, radius - 4, innerRimPaint);

    // 2. Vẽ từng nan quạt
    final Rect wheelBounds = Rect.fromCircle(center: center, radius: radius - 8);

    for (int i = 0; i < rewards.length; i++) {
      final reward = rewards[i];
      final double startAngle = i * sectorAngle;

      final Paint sectorPaint = Paint()
        ..color = reward.bgColor
        ..style = PaintingStyle.fill;

      canvas.drawArc(wheelBounds, startAngle, sectorAngle, true, sectorPaint);

      // Đường kẻ phân chia các nan quạt
      final Paint linePaint = Paint()
        ..color = const Color(0xFFE0E0E0)
        ..strokeWidth = 1.5;
      final double lineX = center.dx + (radius - 8) * cos(startAngle);
      final double lineY = center.dy + (radius - 8) * sin(startAngle);
      canvas.drawLine(center, Offset(lineX, lineY), linePaint);

      // Vẽ chữ nhãn bên trong nan quạt
      final double textAngle = startAngle + sectorAngle / 2;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(textAngle);

      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: reward.label,
          style: TextStyle(
            color: reward.textColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Đặt chữ ở vị trí 62% bán kính
      final double textRadius = radius * 0.62;
      tp.paint(canvas, Offset(textRadius - tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // 3. Các bóng đèn tròn vàng/trắng viền ngoài
    const int bulbCount = 24;
    final double bulbRadius = radius - 4;
    for (int i = 0; i < bulbCount; i++) {
      final double bAngle = (i * 2 * pi) / bulbCount;
      final double bx = center.dx + bulbRadius * cos(bAngle);
      final double by = center.dy + bulbRadius * sin(bAngle);

      final Paint bulbPaint = Paint()
        ..color = i % 2 == 0 ? const Color(0xFFFFD54F) : Colors.white;
      canvas.drawCircle(Offset(bx, by), 2.5, bulbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}

/// CustomPainter vẽ Mũi tên kim chỉ ở đỉnh trên
class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    // Bóng đổ
    final Paint shadowPaint = Paint()
      ..color = Colors.black45
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);

    // Mũi tên trắng viền đỏ
    final Paint fillPaint = Paint()..color = Colors.white;
    canvas.drawPath(path, fillPaint);

    final Paint borderPaint = Paint()
      ..color = const Color(0xFFC2185B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) => false;
}
