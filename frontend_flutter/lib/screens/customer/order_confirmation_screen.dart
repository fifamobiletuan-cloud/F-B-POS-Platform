import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/models.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onDone;

  const OrderConfirmationScreen({
    super.key,
    required this.order,
    required this.onDone,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  static const kRed = Color(0xFFA81E22);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _vietQRUrl {
    final amount = widget.order.totalAmount.toInt();
    final info = Uri.encodeComponent(
        '${widget.order.id} ${widget.order.tableNumber}');
    // Sử dụng VietQR public API (thay bank/account nếu cần)
    return 'https://api.vietqr.io/image/970422-0348705001-compact2.png?amount=$amount&addInfo=$info';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, _) {
        final bg = isDark ? const Color(0xFF080808) : const Color(0xFFF8F8F8);
        final cardBg =
            isDark ? const Color(0xFF1A1A1A) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF080808);
        final subColor =
            isDark ? const Color(0xFF9E9E9E) : const Color(0xFF767676);

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // ── Success Icon ──
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 60),
                    ),
                  ),

                  const SizedBox(height: 24),

                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        Text(
                          'Đặt hàng thành công! 🎉',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đơn hàng của bạn đã được gửi tới bếp.\nVui lòng thanh toán qua QR bên dưới.',
                          style: TextStyle(
                              color: subColor, fontSize: 14, height: 1.6),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Order Info Card ──
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: isDark
                                ? const Color(0xFF2B2B2B)
                                : const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        children: [
                          _infoRow('Mã đơn', widget.order.id,
                              textColor, subColor),
                          const Divider(height: 20),
                          _infoRow(
                              'Bàn',
                              widget.order.tableNumber,
                              textColor,
                              subColor),
                          const Divider(height: 20),
                          _infoRow(
                              'Số lượng',
                              '${widget.order.items.fold(0, (s, i) => s + i.quantity)} món',
                              textColor,
                              subColor),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tổng cộng',
                                  style: TextStyle(
                                      color: subColor,
                                      fontSize: 14)),
                              Text(
                                '${widget.order.totalAmount.toStringAsFixed(0)} đ',
                                style: const TextStyle(
                                  color: kRed,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── VietQR Payment ──
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: isDark
                                ? const Color(0xFF2B2B2B)
                                : const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code_rounded,
                                  color: kRed, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Thanh toán VietQR',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // QR Code
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x15000000),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Image.network(
                              _vietQRUrl,
                              width: 220,
                              height: 220,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  width: 220,
                                  height: 220,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: kRed,
                                      value: loadingProgress
                                                  .expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 220,
                                height: 220,
                                color: Colors.grey.shade100,
                                child: const Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.qr_code_2_rounded,
                                        size: 80, color: kRed),
                                    SizedBox(height: 8),
                                    Text('QR không tải được.\nThanh toán tiền mặt',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),
                          Text(
                            'Quét mã bằng app ngân hàng hoặc MoMo\nđể hoàn tất thanh toán',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: subColor,
                                fontSize: 13,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Order Items Summary ──
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: isDark
                                ? const Color(0xFF2B2B2B)
                                : const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chi tiết đơn hàng',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...widget.order.items.map((item) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: kRed.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${item.quantity}x',
                                          style: const TextStyle(
                                            color: kRed,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item.productName,
                                        style: TextStyle(
                                            color: textColor,
                                            fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      '${(item.unitPrice * item.quantity).toStringAsFixed(0)}đ',
                                      style: TextStyle(
                                          color: subColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Done Button ──
                  GestureDetector(
                    onTap: widget.onDone,
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: kRed,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40A81E22),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Đã thanh toán xong — Quay về Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cash payment option
                  GestureDetector(
                    onTap: widget.onDone,
                    child: Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isDark
                                ? const Color(0xFF2B2B2B)
                                : const Color(0xFFDDDDDD)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          'Thanh toán tiền mặt khi nhân viên đến',
                          style: TextStyle(
                              color: subColor,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(
      String label, String value, Color textColor, Color subColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: subColor, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
