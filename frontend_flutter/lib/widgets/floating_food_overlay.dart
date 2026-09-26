import 'dart:math';
import 'package:flutter/material.dart';

/// 18 icon đồ ăn, thức uống, bánh ngọt siêu cute
const List<String> kCuteFoodEmojis = [
  '🧋', '🍰', '🍟', '🍕', '🍩', '🍦', '🍣', '🥟', '🍡', '🥞',
  '🍓', '🍉', '🍪', '🍜', '🌮', '🍤', '🍫', '🧁',
];

class _FoodSpec {
  final int emojiIndex;
  final double normX; // 0.0 -> 1.0
  final double initialY; // 0.0 -> 1.0
  final double speed; // Tốc độ trôi từ 0.75 -> 1.25
  final double driftAmp; // Biên độ đung đưa ngang
  final double driftFreq; // Tần số đung đưa
  final double phase; // Pha dao động
  final double rotAmp; // Góc nghiêng

  const _FoodSpec({
    required this.emojiIndex,
    required this.normX,
    required this.initialY,
    required this.speed,
    required this.driftAmp,
    required this.driftFreq,
    required this.phase,
    required this.rotAmp,
  });
}

/// GlobalFloatingFoodOverlay — Render an toàn 100%
/// Tích hợp WidgetsBindingObserver: Tự động phục hồi khi thoát ra vào lại app
/// Xử lý clamp an toàn: Không bao giờ bị ArgumentError gây đen màn hình
class GlobalFloatingFoodOverlay extends StatefulWidget {
  const GlobalFloatingFoodOverlay({super.key});

  @override
  State<GlobalFloatingFoodOverlay> createState() => _GlobalFloatingFoodOverlayState();
}

class _GlobalFloatingFoodOverlayState extends State<GlobalFloatingFoodOverlay>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late final List<_FoodSpec> _specs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final rand = Random(2026);
    const int count = 18;

    // 1. Tạo thông số cho 18 hạt đồ ăn
    _specs = List.generate(count, (i) {
      return _FoodSpec(
        emojiIndex: i % kCuteFoodEmojis.length,
        normX: (i + 0.5) / count + (-0.03 + rand.nextDouble() * 0.06),
        initialY: rand.nextDouble(), // Rải đều khắp màn hình ngay từ đầu
        speed: 0.75 + rand.nextDouble() * 0.5, // Bay chậm rãi, êm ái
        driftAmp: 8.0 + rand.nextDouble() * 10.0, // Đung đưa nhẹ 8-18px
        driftFreq: 1.0 + rand.nextDouble() * 1.5,
        phase: rand.nextDouble() * 2 * pi,
        rotAmp: 0.15 + rand.nextDouble() * 0.15,
      );
    }, growable: false);

    // 2. AnimationController bay êm ả lặp lại liên tục trong 20 giây
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Khi người dùng quay lại app, đảm bảo controller tiếp tục chạy êm ru
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else if (state == AppLifecycleState.paused) {
      // Khi thoát ra ngoài, tạm dừng để tiết kiệm pin
      _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          if (w < 40 || h < 40) return const SizedBox.shrink();

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final progress = _controller.value;
              final totalHeight = h + 80.0;

              return Stack(
                clipBehavior: Clip.none,
                children: List.generate(_specs.length, (i) {
                  final spec = _specs[i];
                  final emoji = kCuteFoodEmojis[spec.emojiIndex];
                  final size = 20.0 + (i % 3) * 3.5;

                  // Tính toán Y bay từ dưới lên trên và lặp vô tận
                  double normY = (spec.initialY - progress * spec.speed) % 1.0;
                  if (normY < 0) normY += 1.0;
                  final posY = normY * totalHeight - 40.0;

                  // Tính toán X đung đưa sóng sin, kiểm tra an toàn tuyệt đối
                  final wave = sin((progress * spec.driftFreq * 2 * pi) + spec.phase) * spec.driftAmp;
                  const minX = 8.0;
                  final maxX = max(minX, w - 32.0);
                  final posX = (spec.normX * w + wave).clamp(minX, maxX);

                  // Góc xoay nhẹ
                  final rot = sin((progress * 2 * pi) + spec.phase) * spec.rotAmp;

                  return Positioned(
                    key: ValueKey('food_particle_$i'),
                    left: posX,
                    top: posY,
                    child: Transform.rotate(
                      angle: rot,
                      child: Opacity(
                        opacity: 0.65,
                        child: Text(
                          emoji,
                          style: TextStyle(
                            fontSize: size,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          );
        },
      ),
    );
  }
}
