import 'package:flutter/material.dart';
import 'snack_drop_game.dart';
import 'fruit_match_game.dart';

enum MinigameScreen { hub, snackDrop, fruitMatch }

class MinigameHubModal extends StatefulWidget {
  final void Function(int discountPercent) onWonReward;

  const MinigameHubModal({
    super.key,
    required this.onWonReward,
  });

  @override
  State<MinigameHubModal> createState() => _MinigameHubModalState();
}

class _MinigameHubModalState extends State<MinigameHubModal> {
  MinigameScreen _currentScreen = MinigameScreen.hub;

  void _openSnackDrop() {
    setState(() => _currentScreen = MinigameScreen.snackDrop);
  }

  void _openFruitMatch() {
    setState(() => _currentScreen = MinigameScreen.fruitMatch);
  }

  void _backToHub() {
    setState(() => _currentScreen = MinigameScreen.hub);
  }

  void _finishAndTriggerWheel(BuildContext context) {
    // Đóng Hub modal và trả cờ mở vòng quay TikTok
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 850, maxHeight: 720),
          color: Colors.white,
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_currentScreen) {
      case MinigameScreen.snackDrop:
        return SnackDropGame(
          onFinishAndOpenWheel: () => _finishAndTriggerWheel(context),
          onBackToHub: _backToHub,
        );
      case MinigameScreen.fruitMatch:
        return FruitMatchGame(
          onFinishAndOpenWheel: () => _finishAndTriggerWheel(context),
          onBackToHub: _backToHub,
        );
      case MinigameScreen.hub:
        return _buildHubView(context);
    }
  }

  Widget _buildHubView(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF0F5), Color(0xFFFFFFFF), Color(0xFFE8F5E9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // ── HEADER MODAL ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/minigame/header_logo.png',
                  height: 48,
                  errorBuilder: (context, error, stackTrace) => const Text('🎮', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MINIGAME CHOUXCHIN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB71C1C),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Chơi game nhận 1 lượt quay voucher giảm giá!',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close_rounded, size: 28, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── 2 NỬA MÀN HÌNH CHỌN TRÒ CHƠI ──
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth >= 600;

                final card1 = _buildGameChoiceCard(
                  title: 'CHOUXCHIN SNACK DROP!',
                  subtitle: 'Trò 1: Hứng Đồ Ăn Rơi 🍬',
                  desc: 'Kéo giỏ hứng trà sữa, bánh snack, kẹo ngọt rơi xuống để tích điểm trước khi hết giờ!',
                  previewAsset: 'assets/images/minigame/snack_drop_preview.jpg',
                  themeColor: const Color(0xFFFE2C55),
                  btnBg: const Color(0xFFFE2C55),
                  tag: 'HỨNG ĐỒ ĂN',
                  onTap: _openSnackDrop,
                );

                final card2 = _buildGameChoiceCard(
                  title: 'CHOUXCHIN FRUIT MATCH!',
                  subtitle: 'Trò 2: Ghép Trái Cây Candy 🍓',
                  desc: 'Tráo đổi & nổ 3 trái cây giống nhau để ghi điểm combo và hoàn thành mục tiêu!',
                  previewAsset: 'assets/images/minigame/fruit_match_preview.jpg',
                  themeColor: const Color(0xFF2E7D32),
                  btnBg: const Color(0xFF2E7D32),
                  tag: 'GHÉP TRÁI CÂY',
                  onTap: _openFruitMatch,
                );

                if (isWide) {
                  // Màn hình ngang: chia 2 nửa bằng nhau (50% - 50%)
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: card1),
                        const SizedBox(width: 16),
                        Expanded(child: card2),
                      ],
                    ),
                  );
                } else {
                  // Màn hình dọc trên điện thoại: 2 thẻ cuộn mượt mà
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        card1,
                        const SizedBox(height: 16),
                        card2,
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameChoiceCard({
    required String title,
    required String subtitle,
    required String desc,
    required String previewAsset,
    required Color themeColor,
    required Color btnBg,
    required String tag,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: themeColor.withValues(alpha: 0.35), width: 2),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner ảnh xem trước của game
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    previewAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: themeColor.withValues(alpha: 0.1),
                      child: Icon(Icons.videogame_asset, size: 48, color: themeColor),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nội dung giới thiệu trò chơi
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: themeColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11.5, color: Colors.black54, height: 1.3),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnBg,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'CHƠI NGAY',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text('🎮', style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
